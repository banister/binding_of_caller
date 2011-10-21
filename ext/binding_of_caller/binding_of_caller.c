/* (c) 2011 John Mair (banisterfiend), MIT license */

# include <ruby.h>

#ifdef RUBY_192
# include "vm_core.h"
# include "gc.h"
#elif defined(RUBY_187)
# include "re.h"
# include "env.h"
# include "node.h"
# include "rubysig.h"
# include "rubyio.h"
#endif

typedef enum { false, true } bool;


static int scope_vmode;
#define SCOPE_PUBLIC    0
#define SCOPE_PRIVATE   1
#define SCOPE_PROTECTED 2
#define SCOPE_MODFUNC   5
#define SCOPE_MASK      7
#define SCOPE_SET(f)  (scope_vmode=(f))
#define SCOPE_TEST(f) (scope_vmode&(f))

#define ITER_NOT 0
#define ITER_PRE 1
#define ITER_CUR 2
#define ITER_PAS 3

struct BLOCK {
  NODE *var;
  NODE *body;
  VALUE self;
  struct FRAME frame;
  struct SCOPE *scope;
  VALUE klass;
  NODE *cref;
  int iter;
  int vmode;
  int flags;
  int uniq;
  struct RVarmap *dyna_vars;
  VALUE orig_thread;
  VALUE wrapper;
  VALUE block_obj;
  struct BLOCK *outer;
  struct BLOCK *prev;
};

#define BLOCK_D_SCOPE 1
#define BLOCK_LAMBDA  2

static struct BLOCK *ruby_block;
static unsigned long block_unique = 1;

static VALUE ruby_wrapper;
static struct tag *prot_tag;

#define PUSH_BLOCK(v,b) do {                    \
  struct BLOCK _block;                          \
  _block.var = (v);                             \
  _block.body = (b);                            \
  _block.self = self;                           \
  _block.frame = *ruby_frame;                   \
  _block.klass = ruby_class;                    \
  _block.cref = ruby_cref;                      \
  _block.frame.node = ruby_current_node;        \
  _block.scope = ruby_scope;                    \
  _block.prev = ruby_block;                     \
  _block.outer = ruby_block;                    \
  _block.iter = ruby_iter->iter;                \
  _block.vmode = scope_vmode;                   \
  _block.flags = BLOCK_D_SCOPE;                 \
  _block.dyna_vars = ruby_dyna_vars;            \
  _block.wrapper = ruby_wrapper;                \
  _block.block_obj = 0;                         \
  _block.uniq = (b)?block_unique++:0;           \
  if (b) {                                      \
    prot_tag->blkid = _block.uniq;              \
  }                                             \
  ruby_block = &_block

#define POP_BLOCK()                             \
  ruby_block = _block.prev;                     \
  } while (0)

#define DVAR_DONT_RECYCLE FL_USER2

struct iter {
  int iter;
  struct iter *prev;
};
static struct iter *ruby_iter;

static VALUE
rb_f_block_given_p()
{
  if (ruby_frame->prev && ruby_frame->prev->iter == ITER_CUR && ruby_block)
    return Qtrue;
  return Qfalse;
}


static void
scope_dup(scope)
    struct SCOPE *scope;
{
    ID *tbl;
    VALUE *vars;

    scope->flags |= SCOPE_DONT_RECYCLE;
    if (scope->flags & SCOPE_MALLOC) return;

    if (scope->local_tbl) {
	tbl = scope->local_tbl;
	vars = ALLOC_N(VALUE, tbl[0]+1);
	*vars++ = scope->local_vars[-1];
	MEMCPY(vars, scope->local_vars, VALUE, tbl[0]);
	scope->local_vars = vars;
	scope->flags |= SCOPE_MALLOC;
    }
}

static void
blk_mark(data)
    struct BLOCK *data;
{
    while (data) {
	rb_gc_mark_frame(&data->frame);
	rb_gc_mark((VALUE)data->scope);
	rb_gc_mark((VALUE)data->var);
	rb_gc_mark((VALUE)data->body);
	rb_gc_mark((VALUE)data->self);
	rb_gc_mark((VALUE)data->dyna_vars);
	rb_gc_mark((VALUE)data->cref);
	rb_gc_mark(data->wrapper);
	rb_gc_mark(data->block_obj);
	data = data->prev;
    }
}

static void
frame_free(frame)
    struct FRAME *frame;
{
    struct FRAME *tmp;

    frame = frame->prev;
    while (frame) {
	tmp = frame;
	frame = frame->prev;
	free(tmp);
    }
}

static void
blk_free(data)
    struct BLOCK *data;
{
    void *tmp;

    while (data) {
	frame_free(&data->frame);
	tmp = data;
	data = data->prev;
	free(tmp);
    }
}

static void
frame_dup(frame)
    struct FRAME *frame;
{
    struct FRAME *tmp;

    for (;;) {
	frame->tmp = 0;		/* should not preserve tmp */
	if (!frame->prev) break;
	tmp = ALLOC(struct FRAME);
	*tmp = *frame->prev;
	frame->prev = tmp;
	frame = tmp;
    }
}


static void
blk_copy_prev(block)
    struct BLOCK *block;
{
    struct BLOCK *tmp;
    struct RVarmap* vars;

    while (block->prev) {
	tmp = ALLOC_N(struct BLOCK, 1);
	MEMCPY(tmp, block->prev, struct BLOCK, 1);
	scope_dup(tmp->scope);
	frame_dup(&tmp->frame);

	for (vars = tmp->dyna_vars; vars; vars = vars->next) {
	    if (FL_TEST(vars, DVAR_DONT_RECYCLE)) break;
	    FL_SET(vars, DVAR_DONT_RECYCLE);
	}

	block->prev = tmp;
	block = tmp;
    }
}


static void
blk_dup(dup, orig)
    struct BLOCK *dup, *orig;
{
    MEMCPY(dup, orig, struct BLOCK, 1);
    frame_dup(&dup->frame);

    if (dup->iter) {
	blk_copy_prev(dup);
    }
    else {
	dup->prev = 0;
    }
}

/*
 * MISSING: documentation
 */

static VALUE
proc_clone(self)
    VALUE self;
{
    struct BLOCK *orig, *data;
    VALUE bind;

    Data_Get_Struct(self, struct BLOCK, orig);
    bind = Data_Make_Struct(rb_obj_class(self),struct BLOCK,blk_mark,blk_free,data);
    CLONESETUP(bind, self);
    blk_dup(data, orig);

    return bind;
}

/*
 * MISSING: documentation
 */

#define PROC_TSHIFT (FL_USHIFT+1)
#define PROC_TMASK  (FL_USER1|FL_USER2|FL_USER3)
#define PROC_TMAX   (PROC_TMASK >> PROC_TSHIFT)

static int proc_get_safe_level(VALUE);


static VALUE
proc_dup(self)
    VALUE self;
{
    struct BLOCK *orig, *data;
    VALUE bind;
    int safe = proc_get_safe_level(self);

    Data_Get_Struct(self, struct BLOCK, orig);
    bind = Data_Make_Struct(rb_obj_class(self),struct BLOCK,blk_mark,blk_free,data);
    blk_dup(data, orig);
    if (safe > PROC_TMAX) safe = PROC_TMAX;
    FL_SET(bind, (safe << PROC_TSHIFT) & PROC_TMASK);

    return bind;
}

VALUE
rb_block_dup(self, klass, cref)
    VALUE self, klass, cref;
{
    struct BLOCK *block;
    VALUE obj = proc_dup(self);
    Data_Get_Struct(obj, struct BLOCK, block);
    block->klass = klass;
    block->cref = NEW_NODE(nd_type(block->cref), cref, block->cref->u2.node,
			   block->cref->u3.node);
    return obj;
}

static VALUE
rb_f_binding(VALUE self)
{
    struct BLOCK *data, *p;
    struct RVarmap *vars;
    VALUE bind;

    PUSH_BLOCK(0,0);
    bind = Data_Make_Struct(rb_cBinding,struct BLOCK,blk_mark,blk_free,data);
    *data = *ruby_block;

    data->orig_thread = rb_thread_current();
    data->wrapper = ruby_wrapper;
    data->iter = rb_f_block_given_p();
    frame_dup(&data->frame);
    if (ruby_frame->prev) {
	data->frame.last_func = ruby_frame->prev->last_func;
	data->frame.last_class = ruby_frame->prev->last_class;
	data->frame.orig_func = ruby_frame->prev->orig_func;
    }

    if (data->iter) {
	blk_copy_prev(data);
    }
    else {
	data->prev = 0;
    }

    for (p = data; p; p = p->prev) {
	for (vars = p->dyna_vars; vars; vars = vars->next) {
	    if (FL_TEST(vars, DVAR_DONT_RECYCLE)) break;
	    FL_SET(vars, DVAR_DONT_RECYCLE);
	}
    }
    scope_dup(data->scope);
    POP_BLOCK();

    return bind;
}

void
Init_binding_of_caller()
{
  VALUE mBindingOfCaller = rb_define_module("BindingOfCaller");

  rb_define_method(mBindingOfCaller, "of_caller", rb_f_binding, 1);
  rb_include_module(rb_cBinding, mBindingOfCaller);
}


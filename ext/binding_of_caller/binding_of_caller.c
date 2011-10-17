/* (c) 2011 John Mair (banisterfiend), MIT license */

#include <ruby.h>
//#include "compat.h"

//#ifdef RUBY_19
# include <ruby/io.h>
# include <ruby/re.h>
# include "vm_core.h"
# include "gc.h"
/* #else */
/* # include "re.h" */
/* # include "env.h" */
/* # include "node.h" */
/* # include "rubysig.h" */
/* # include "rubyio.h" */
/* #endif */

static size_t
binding_memsize(const void *ptr)
{
  return ptr ? sizeof(rb_binding_t) : 0;
}

static void
binding_free(void *ptr)
{
  rb_binding_t *bind;
  RUBY_FREE_ENTER("binding");
  if (ptr) {
    bind = ptr;
    ruby_xfree(ptr);
  }
  RUBY_FREE_LEAVE("binding");
}

static void
binding_mark(void *ptr)
{
  rb_binding_t *bind;
  RUBY_MARK_ENTER("binding");
  if (ptr) {
    bind = ptr;
    RUBY_MARK_UNLESS_NULL(bind->env);
    RUBY_MARK_UNLESS_NULL(bind->filename);
  }
  RUBY_MARK_LEAVE("binding");
}

static const rb_data_type_t binding_data_type = {
  "binding",
  binding_mark,
  binding_free,
  binding_memsize,
};

static VALUE
binding_alloc(VALUE klass)
{
  VALUE obj;
  rb_binding_t *bind;
  obj = TypedData_Make_Struct(klass, rb_binding_t, &binding_data_type, bind);
  return obj;
}

typedef enum { false, true } bool;

static bool valid_frame_p(rb_control_frame_t * cfp) {
  return cfp->iseq && !NIL_P(cfp->self);
}

static rb_control_frame_t * find_valid_frame(rb_control_frame_t * cfp) {
  int error_count = 0;

  while (error_count <= 4) {
    cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(cfp);

    if (valid_frame_p(cfp))
      return cfp;
    else
      error_count += 1;
  }

  rb_raise(rb_eRuntimeError, "No valid stack frame found.");

  // never reached
  return 0;
}

static VALUE binding_of_caller(VALUE self, VALUE rb_level)
{
  rb_thread_t *th = GET_THREAD();
  rb_control_frame_t *cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(th->cfp);
  int level = FIX2INT(rb_level);

  for (int i = 0; i < level; i++)
    cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(cfp);

  if (!valid_frame_p(cfp))
    cfp = find_valid_frame(cfp);

  VALUE bindval = binding_alloc(rb_cBinding);
  rb_binding_t *bind;

  if (cfp == 0) {
    rb_raise(rb_eRuntimeError, "Can't create Binding Object on top of Fiber.");
  }

  GetBindingPtr(bindval, bind);
  bind->env = rb_vm_make_env_object(th, cfp);
  bind->filename = cfp->iseq->filename;
  bind->line_no = rb_vm_get_sourceline(cfp);
  return bindval;
}

void
Init_binding_of_caller()
{
  rb_define_method(rb_cObject, "binding_of_caller", binding_of_caller, 1);
}


/* (c) 2010 John Mair (banisterfiend), MIT license */

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

static rb_control_frame_t *
vm_get_ruby_level_caller_cfp(rb_thread_t *th, rb_control_frame_t *cfp)
{
    if (RUBY_VM_NORMAL_ISEQ_P(cfp->iseq)) {
	return cfp;
    }

    cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(cfp);

    while (!RUBY_VM_CONTROL_FRAME_STACK_OVERFLOW_P(th, cfp)) {
	if (RUBY_VM_NORMAL_ISEQ_P(cfp->iseq)) {
	    return cfp;
	}

	if ((cfp->flag & VM_FRAME_FLAG_PASSED) == 0) {
	    break;
	}
	cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(cfp);
    }
    return 0;
}


static VALUE hello(VALUE self)
{
  rb_thread_t *th = GET_THREAD();
  rb_control_frame_t *cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(RUBY_VM_PREVIOUS_CONTROL_FRAME(th->cfp));
  //vm_get_ruby_level_caller_cfp(th,  RUBY_VM_PREVIOUS_CONTROL_FRAME(RUBY_VM_PREVIOUS_CONTROL_FRAME(RUBY_VM_PREVIOUS_CONTROL_FRAME(th->cfp))));
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
      //  VALUE cBindingOfCaller = rb_define_module("BindingOfCaller");

  rb_define_method(rb_cObject, "binding_of_caller", hello, 0);

}


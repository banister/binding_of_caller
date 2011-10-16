/* contains basic macros to facilitate ruby 1.8 and ruby 1.9 compatibility */

#ifndef GUARD_COMPAT_H
#define GUARD_COMPAT_H

#include <ruby.h>

/* test for 1.9 */
#if !defined(RUBY_19) && defined(ROBJECT_EMBED_LEN_MAX)
# define RUBY_19
#endif

/* macros for backwards compatibility with 1.8 */
#ifndef RUBY_19
# define RCLASS_M_TBL(c) (RCLASS(c)->m_tbl)
# define RCLASS_SUPER(c) (RCLASS(c)->super)
# define RCLASS_IV_TBL(c) (RCLASS(c)->iv_tbl)
# define OBJ_UNTRUSTED OBJ_TAINTED
# include "st.h"
#endif

#ifdef RUBY_19
inline static VALUE
class_alloc(VALUE flags, VALUE klass)
{
  rb_classext_t *ext = ALLOC(rb_classext_t);
  NEWOBJ(obj, struct RClass);
  OBJSETUP(obj, klass, flags);
  obj->ptr = ext;
  RCLASS_IV_TBL(obj) = 0;
  RCLASS_M_TBL(obj) = 0;
  RCLASS_SUPER(obj) = 0;
  RCLASS_IV_INDEX_TBL(obj) = 0;
  return (VALUE)obj;
}
#endif

inline static VALUE
create_class(VALUE flags, VALUE klass)
{
#ifdef RUBY_19
  VALUE new_klass = class_alloc(flags, klass);
#else
  NEWOBJ(new_klass, struct RClass);
  OBJSETUP(new_klass, klass, flags);
#endif

  return (VALUE)new_klass;
}
  
# define FALSE 0
# define TRUE 1

/* a useful macro. cannot use ordinary CLASS_OF as it does not return an lvalue */
#define KLASS_OF(c) (RBASIC(c)->klass)

#endif

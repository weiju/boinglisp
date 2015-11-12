#ifndef __BL_RUNTIME_H__
#define __BL_RUNTIME_H__

typedef int BLWORD;

#define BL_IS_FIXNUM(v) ((v & 1) == 1)
#define BL_FIXNUM2INT(v) (v >> 1)
#define BL_INT2FIXNUM(v) ((v << 1) | 1)

/* Special values */
#define BL_UNDEFINED  (0x1e)
#define BL_EOF        (0x3e)
#define BL_EMPTY_LIST (0x0e)

typedef struct _Continuation {
    struct _Continuation *prev;
    BLWORD value;
    BLWORD env;
    BLWORD label;
    BLWORD tmpl;
    BLWORD stack_ptr;
} Continuation;

struct _Environment {
    struct _Environment *prev;
    /* TODO: bindings */
};

struct _Template {

};

#endif /* __BL_RUNTIME_H__ */

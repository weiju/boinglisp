#ifndef __BL_TYPES_H__
#define __BL_TYPES_H__
#pragma once

/*
 * The internal data representation is inspired by Chicken Scheme.
 * BLWORD is a machine word (architecture dependent, 32 or 64 Bit)
 * representing a Lisp value, the low order nibble (4 bits) specify
 * the type
 */
#ifdef __VBCC__
typedef unsigned int BLWORD;
#else
#ifdef __LP64__
typedef __uint64_t BLWORD;
#else
typedef __uint32_t BLWORD;
#endif
#endif

/* Fix nums are (machine word width - 1) sized integers with the
   LSB set to 1
 */
#define BL_IS_FIXNUM(v) ((v & 1) == 1)
#define BL_FIXNUM2INT(v) (v >> 1)
#define BL_INT2FIXNUM(v) ((v << 1) | 1)

/* Booleans */
#define BL_BOOL_BITS    (0x06)
#define BL_TRUE         (0x16)
#define BL_FALSE        (0x06)

/* Characters (unicode code point is in the upper 24 Bits)  */
#define BL_CHAR_BITS    (0x0a)

/* Special values */
#define BL_SPECIAL_BITS (0x0e)
#define BL_UNDEFINED    (0x1e)
#define BL_EOF          (0x3e)
#define BL_EMPTY_LIST   (0x0e)


/* struct HeapObject {}; */

struct _Continuation {
    struct _Continuation *prev;
    BLWORD value;
    BLWORD env;
    BLWORD label;
    BLWORD tmpl;
    BLWORD stack_ptr;
};

struct _Environment {
    struct _Environment *prev;
    /* bindings follow here */
};

struct _Template {
    BLWORD code;
};

#endif /* __BL_TYPES_H__ */

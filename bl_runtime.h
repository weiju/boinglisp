#ifndef __BL_RUNTIME_H__
#define __BL_RUNTIME_H__

typedef int BLWORD;

#define BL_IS_FIXNUM(v) ((v & 1) == 1)
#define BL_TO_FIXNUM(v) (v >> 1)

/* Special values */
#define BL_UNDEFINED  (0x1e)
#define BL_EOF        (0x3e)
#define BL_EMPTY_LIST (0x0e)

#endif /* __BL_RUNTIME_H__ */

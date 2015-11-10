#ifndef __BL_RUNTIME_H__
#define __BL_RUNTIME_H__

typedef int BLWORD;

#define BL_IS_FIXNUM(v) ((v & 1) == 1)
#define BL_TO_FIXNUM(v) (v >> 1)

#endif /* __BL_RUNTIME_H__ */

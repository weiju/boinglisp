#pragma once
#ifndef __BL_RUNTIME_H__
#define __BL_RUNTIME_H__

#include "bl_types.h"

extern int bl_init();
extern void bl_cleanup();

extern BLWORD bl_print(int numargs, ...);
extern BLWORD bl_println(int numargs, ...);

extern BLWORD bl_add(int numargs, ...);
extern BLWORD bl_sub(int numargs, ...);
extern BLWORD bl_mul(int numargs, ...);
extern BLWORD bl_div(int numargs, ...);

extern BLWORD bl_num_eq(int numargs, ...);
extern BLWORD bl_not(int numargs, ...);
extern BLWORD bl_quote(int numargs, ...);
extern BLWORD bl_tlenv_bind(const char *key, BLWORD value);
extern BLWORD bl_tlenv_lookup(const char *key);
extern void bl_new_local_env(int slots);
extern void bl_pop_local_env();
extern void bl_local_env_bind(int slot, BLWORD value);
extern BLWORD bl_local_env_lookup(int level, int slot);

#endif /* __BL_RUNTIME_H__ */

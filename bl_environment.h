#pragma once
#ifndef __BL_ENVIRONMENT_H__
#define __BL_ENVIRONMENT_H__

#include "bl_types.h"

/*
A binding entry, it is assumed that strings will be part
of the compiled binary and so we store only the reference
to the key
*/
struct _bl_binding {
    const char *key;
    BLWORD value;
    struct _bl_binding *next; /* next binding entry */
};

struct _bl_toplevel_env {
    int num_entries;
    int size;
    struct _bl_binding **entries;
};

/*
 * Local binding environments that implement scopes.
 * The bindings within an environment are represented by
 * a single linked list.
 */
struct _bl_local_env {
    struct _bl_local_env *parent;
};

/* Top level environment management */
extern struct _bl_toplevel_env *bl_new_tl_env();
extern void bl_free_tl_env(struct _bl_toplevel_env *);
extern const char *bl_tl_env_put(struct _bl_toplevel_env *env, const char *key, BLWORD value);
extern BLWORD bl_tl_env_get(struct _bl_toplevel_env *env, const char *key);

#endif /* __BL_ENVIRONMENT_H__ */

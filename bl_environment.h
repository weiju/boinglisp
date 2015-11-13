#pragma once
#ifndef __BL_ENVIRONMENT_H__
#define __BL_ENVIRONMENT_H__

#include "bl_types.h"

/*
 * A simple hash based string template library. Templates look a little
 * like jinja, with mustaches, and {{key}} occurrences are replaced with value.
 */
#define STEMP_MAX_KEY_LENGTH 31

struct _bl_binding {
    char key[STEMP_MAX_KEY_LENGTH + 1];
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
    struct _bl_binding *head;
};

/* Top level environment management */
extern struct _bl_toplevel_env *bl_new_tl_env();
extern void bl_free_tl_env(struct _bl_toplevel_env *);
extern const char *bl_tl_env_put(struct _bl_toplevel_env *env, const char *key, BLWORD value);
extern BLWORD bl_tl_env_get(struct _bl_toplevel_env *env, const char *key);

/* local and module environment management */
extern struct _bl_local_env *bl_new_local_env(struct _bl_local_env *parent);
extern void bl_free_local_env(struct _bl_local_env *);
extern void bl_local_env_put(struct _bl_local_env *env, const char *key, BLWORD value);
extern BLWORD bl_local_env_get(struct _bl_local_env *env, const char *key);

#endif /* __BL_ENVIRONMENT_H__ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bl_environment.h"


/***************************************************************************
 * Supporting hash table implementation
 * We actually only need get and put (with replace)
 ***************************************************************************/

#define INITIAL_NUM_HASH_ENTRIES 100

static unsigned long djb2_hash(const unsigned char *str)
{
    unsigned long hash = 5381;
    int c;

    while ((c = *str++)) hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    return hash;
}

struct _bl_toplevel_env *bl_new_tl_env()
{
    struct _bl_toplevel_env *result = calloc(1, sizeof(struct _bl_toplevel_env));
    if (!result) return NULL;
    result->size = INITIAL_NUM_HASH_ENTRIES;
    result->num_entries = 0;
    result->entries = calloc(INITIAL_NUM_HASH_ENTRIES, sizeof(struct _bl_binding *));

    if (!result->entries) {
        free(result);
        return NULL;
    }
    return result;
}

void bl_free_tl_env(struct _bl_toplevel_env *env)
{
    if (!env) return;
    if (env->entries) {
        struct _bl_binding *slot, *cur, *next;
        int i;
        /* free each entry by freeing the values of each bucket first */
        for (i = 0; i < env->size; i++) {
            slot = env->entries[i];
            if (slot) {
                cur = slot;
                while (cur) {
                    next = cur->next;
                    free(cur);
                    cur = next;
                }
            }
        }
        free(env->entries);
        env->entries = NULL;
        env->num_entries = 0;
        env->size = 0;
    }
    free(env);
}

const char *bl_tl_env_put(struct _bl_toplevel_env *env, const char *key, BLWORD value)
{
    int slot;
    struct _bl_binding *new_entry;

    /* NULL or long keys not allowed */
    if (!key || strlen(key) > STEMP_MAX_KEY_LENGTH) return NULL;

    /* no dictionary or table size 0, TODO should resize table */
    if (!env || env->size == 0) return NULL;
    slot = djb2_hash((const unsigned char *) key) % env->size;

    new_entry = calloc(1, sizeof(struct _bl_binding));
    if (!new_entry) return NULL;

    strncpy(new_entry->key, key, STEMP_MAX_KEY_LENGTH);

    new_entry->value = value;
    if (!env->entries[slot]) env->entries[slot] = new_entry;
    else {
        /* Append */
        int replaced = 0;
        struct _bl_binding *cur = env->entries[slot], *prev = NULL;
        while (cur) {
            if (!strcmp(cur->key, key)) {
                if (!prev) env->entries[slot] = new_entry;
                else prev->next = new_entry;
                new_entry->next = cur->next;

                /* free the old entry's memory  */
                free(cur);
                replaced = 1;
                break;
            }
            prev = cur;
            cur = cur->next;
        }
        if (!replaced) prev->next = new_entry;
    }
    env->num_entries++;
    return key;
}

BLWORD bl_tl_env_get(struct _bl_toplevel_env *env, const char *key)
{
    int slot;
    struct _bl_binding *cur;
    if (!key || !env) return BL_UNDEFINED;

    slot = djb2_hash((const unsigned char *) key) % env->size;
    cur = env->entries[slot];
    if (!cur) return BL_UNDEFINED; /* no such entry */
    if (!strncmp(cur->key, key, STEMP_MAX_KEY_LENGTH)) return cur->value;
    while (cur->next) {
        cur = cur->next;
        if (!strncmp(cur->key, key, STEMP_MAX_KEY_LENGTH)) return cur->value;
    }
    return BL_UNDEFINED;
}

struct _bl_local_env *bl_new_local_env(struct _bl_local_env *parent)
{
    struct _bl_local_env *result = calloc(1, sizeof(struct _bl_local_env));
    result->parent = parent;
    return result;
}

void bl_free_local_env(struct _bl_local_env *env)
{
    if (env) free(env);
}

void bl_local_env_put(struct _bl_local_env *env, const char *key, BLWORD value)
{
}

BLWORD bl_local_env_get(struct _bl_local_env *env, const char *key)
{
    return 0;
}

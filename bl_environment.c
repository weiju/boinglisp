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

struct stemp_dict *stemp_new_dict()
{
    struct stemp_dict *result = calloc(1, sizeof(struct stemp_dict));
    if (!result) return NULL;
    result->size = INITIAL_NUM_HASH_ENTRIES;
    result->num_entries = 0;
    result->entries = calloc(INITIAL_NUM_HASH_ENTRIES, sizeof(struct stemp_htable_entry *));

    if (!result->entries) {
        free(result);
        return NULL;
    }
    return result;
}

void stemp_free_dict(struct stemp_dict *dict)
{
    if (!dict) return;
    if (dict->entries) {
        struct stemp_htable_entry *slot, *cur, *next;
        int i;
        /* free each entry by freeing the values of each bucket first */
        for (i = 0; i < dict->size; i++) {
            slot = dict->entries[i];
            if (slot) {
                cur = slot;
                while (cur) {
                    if (slot->value.value_type == STHT_CSTR && slot->value.cstr_value) {
                        free(slot->value.cstr_value);
                    }
                    if (slot->value.value_type == STHT_PTR && slot->value.ptr_value) {
                        free(slot->value.ptr_value);
                    }
                    next = cur->next;
                    free(cur);
                    cur = next;
                }
            }
        }
        free(dict->entries);
        dict->entries = NULL;
        dict->num_entries = 0;
        dict->size = 0;
    }
    free(dict);
}

const char *stemp_dict_put(struct stemp_dict *dict, const char *key, const char *value)
{
    int slot;
    struct stemp_htable_entry *new_entry;

    /* NULL or long keys not allowed */
    if (!key || strlen(key) > STEMP_MAX_KEY_LENGTH) return NULL;

    /* no dictionary or table size 0, TODO should resize table */
    if (!dict || dict->size == 0) return NULL;
    slot = djb2_hash((const unsigned char *) key) % dict->size;

    new_entry = calloc(1, sizeof(struct stemp_htable_entry));
    if (!new_entry) return NULL;

    strncpy(new_entry->key, key, STEMP_MAX_KEY_LENGTH);

    /* reserve space for value and copy */
    new_entry->value.value_type = STHT_CSTR;
    if (value) {
        new_entry->value.cstr_value = calloc(strlen(value) + 1, sizeof(char));
        if (!new_entry->value.cstr_value) {
            free(new_entry);
            return NULL;
        }
        strcpy(new_entry->value.cstr_value, value);
    }

    if (!dict->entries[slot]) dict->entries[slot] = new_entry;
    else {
        /* Append */
        int replaced = 0;
        struct stemp_htable_entry *cur = dict->entries[slot], *prev = NULL;
        while (cur) {
            if (!strcmp(cur->key, key)) {
                if (!prev) dict->entries[slot] = new_entry;
                else prev->next = new_entry;
                new_entry->next = cur->next;

                /* free the old entry's memory  */
                if (cur->value.value_type == STHT_CSTR) free(cur->value.cstr_value);
                else if (cur->value.value_type == STHT_PTR) free(cur->value.ptr_value);
                free(cur);
                replaced = 1;
                break;
            }
            prev = cur;
            cur = cur->next;
        }
        if (!replaced) prev->next = new_entry;
    }
    dict->num_entries++;
    return key;
}

const stemp_htable_value *stemp_dict_get(struct stemp_dict *dict, const char *key)
{
    int slot;
    struct stemp_htable_entry *cur;
    if (!key || !dict) return NULL;

    slot = djb2_hash((const unsigned char *) key) % dict->size;
    cur = dict->entries[slot];
    if (!cur) return NULL; /* no such entry */
    if (!strncmp(cur->key, key, STEMP_MAX_KEY_LENGTH)) return &(cur->value);
    while (cur->next) {
        cur = cur->next;
        if (!strncmp(cur->key, key, STEMP_MAX_KEY_LENGTH)) return &(cur->value);
    }
    return NULL;
}

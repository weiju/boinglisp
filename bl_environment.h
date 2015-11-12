#pragma once
#ifndef __BL_ENVIRONMENT_H__
#define __BL_ENVIRONMENT_H__


/*
 * A simple hash based string template library. Templates look a little
 * like jinja, with mustaches, and {{key}} occurrences are replaced with value.
 */
#define STEMP_MAX_KEY_LENGTH 31

typedef enum {STHT_INT, STHT_CSTR, STHT_PTR} stemp_ht_value_type;

typedef struct _stemp_htable_value {
  stemp_ht_value_type value_type;
  union {
    int int_value;
    char *cstr_value;
    void *ptr_value;
  };
} stemp_htable_value;

struct stemp_htable_entry {
  char key[STEMP_MAX_KEY_LENGTH + 1];
  stemp_htable_value value;
  struct stemp_htable_entry *next; /* to resolve hash collisions */
};

struct stemp_dict {
  int num_entries;
  int size;
  struct stemp_htable_entry **entries;
};

extern struct stemp_dict *stemp_new_dict();
extern void stemp_free_dict(struct stemp_dict *);
extern const char *stemp_dict_put(struct stemp_dict *dict, const char *key, const char *value);
extern const stemp_htable_value *stemp_dict_get(struct stemp_dict *dict, const char *key);

#endif /* __SIMPLE_TEMPLATES_H__ */

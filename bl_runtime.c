#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "bl_types.h"
#include "bl_environment.h"

/*
 * The kernel of the BoingLisp system.
 * This module contains the essential functionality that is
 * necessary for every BoingLisp program
 */

static char *APP_NAME = "Boing Lisp version 0.002 (c) 2015\n";
static struct _bl_toplevel_env *toplevel_env;
static struct _bl_local_env *local_envs = NULL;

int bl_init()
{
    /* TODO:
       1. Initialize top-level environment and return a pointer to
       that environment
       2. Allocate an initial page to hold some heap objects
     */
    toplevel_env = bl_new_tl_env();
    local_envs = NULL;
    return 1;
}

void bl_cleanup()
{
    /* TODO: free all resources that were allocated during
       the execution
     */
    if (toplevel_env) bl_free_tl_env(toplevel_env);
    if (local_envs) free(local_envs);
}

/*
 * I/O
 */
static int print_bl_value(BLWORD value)
{
    if (value == BL_UNDEFINED) return 0;
    if (value == BL_EMPTY_LIST) {
        fprintf(stdout, "'()");
    } else if (value == BL_TRUE) {
        fputs("#t", stdout);
    } else if (value == BL_FALSE) {
        fputs("#f", stdout);
    } else if (BL_IS_FIXNUM(value)) {
        int n = BL_FIXNUM2INT(value);
        fprintf(stdout, "%d", n);
    } else {
        const char *s = (const char *) value;
        fprintf(stdout, "\"%s\"", s);
    }
    return 1;
}

static void println_bl_value(BLWORD value)
{
    if (print_bl_value(value)) fputs("\n", stdout);
}

BLWORD bl_print(int numargs, ...)
{
    va_list args;
    BLWORD current;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        print_bl_value(va_arg(args, BLWORD));
    }
    va_end(args);
    return BL_UNDEFINED;
}

BLWORD bl_println(int numargs, ...)
{
    va_list args;
    BLWORD current;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        println_bl_value(va_arg(args, BLWORD));
    }
    va_end(args);
    return BL_UNDEFINED;
}

/*
 * Integer operations
 */
BLWORD bl_add(int numargs, ...)
{
    va_list args;
    BLWORD current, result = 0;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            result += BL_FIXNUM2INT(current);
        } else {
            fprintf(stdout, "ERROR ! wrong type\n");
        }
    }
    va_end(args);
    return BL_INT2FIXNUM(result);
}

BLWORD bl_sub(int numargs, ...)
{
    va_list args;
    BLWORD current, result = 0;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            if (i == 0) result = BL_FIXNUM2INT(current);
            else result -= BL_FIXNUM2INT(current);
        } else {
            fprintf(stdout, "ERROR ! wrong type\n");
        }
    }
    va_end(args);
    return BL_INT2FIXNUM(result);
}

BLWORD bl_mul(int numargs, ...)
{
    va_list args;
    BLWORD current, result = 1;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            result *= BL_FIXNUM2INT(current);
        } else {
            fprintf(stdout, "ERROR ! wrong type\n");
        }
    }
    va_end(args);
    return BL_INT2FIXNUM(result);
}

BLWORD bl_div(int numargs, ...)
{
    va_list args;
    BLWORD current, result = 0;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            if (i == 0) result = BL_FIXNUM2INT(current);
            else result /= BL_FIXNUM2INT(current);
        } else {
            fprintf(stdout, "ERROR ! wrong type\n");
        }
    }
    va_end(args);
    return BL_INT2FIXNUM(result);
}

/*
 * Comparisons
 */
BLWORD bl_num_eq(int numargs, ...)
{
    va_list args;
    BLWORD current, result = BL_TRUE;
    int i, curr_num, tmp;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            tmp = BL_FIXNUM2INT(current);
            if (i > 0 && curr_num != tmp) {
                result = BL_FALSE;
                break;
            }
            curr_num = tmp;
        } else {
            fprintf(stdout, "ERROR ! wrong type\n");
        }
    }
    va_end(args);
    return result;
}

/* Boolean operations */
BLWORD bl_not(int numargs, ...)
{
    va_list args;
    BLWORD result = BL_FALSE;
    va_start(args, numargs);
    result = va_arg(args, BLWORD);
    va_end(args);
    if (result == BL_TRUE) result = BL_FALSE;
    else if (result == BL_FALSE) result = BL_TRUE;
    else ; /* TODO: type error */
    return result;
}

/*
 * Elementary Lisp operations
 */
BLWORD bl_quote(int numargs, ...)
{
    va_list args;
    BLWORD current;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        break;
    }
    va_end(args);
    return current;
}

/*
 * Environment interface
 */
BLWORD bl_tlenv_bind(const char *key, BLWORD value)
{
    bl_tl_env_put(toplevel_env, key, value);
    return BL_UNDEFINED;
}

BLWORD bl_tlenv_lookup(const char *key)
{
    return bl_tl_env_get(toplevel_env, key);
}

void bl_new_local_env(int slots)
{
    struct _bl_local_env *result = (struct _bl_local_env *)
        calloc(1, sizeof(struct _bl_local_env *) + sizeof(BLWORD) * slots);
    result->parent = local_envs;
    local_envs = result;
}

void bl_pop_local_env()
{
    /* note that we do not free the space occupied by the environment because
       we did not figure out garbage collection and closures yet !!!
       Thus, the environments will currently the main cause of memory leaks
       in the system.
    */
    local_envs = local_envs->parent;
}

void bl_local_env_bind(int slot, BLWORD value)
{
    local_envs->entries[slot] = value;
}

BLWORD bl_local_env_lookup(int level, int slot)
{
    int count = 0;
    struct _bl_local_env *env = local_envs;
    while (count < level) {
        env = env->parent;
        count++;
    }
    return env->entries[slot];
}

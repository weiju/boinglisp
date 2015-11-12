#include <stdio.h>
#include <stdarg.h>
#include "bl_types.h"
#include "bl_environment.h"

/*
 * The kernel and main entry point of the BoingLisp system.
 * This module contains the essential functionality that is
 * necessary for every BoingLisp program
 */

static char *APP_NAME = "Boing Lisp version 0.002 (c) 2015\n";
static struct _bl_toplevel_env *toplevel_env;

int bl_init()
{
    /* TODO:
       1. Initialize top-level environment and return a pointer to
       that environment
       2. Allocate an initial page to hold some heap objects
     */
    toplevel_env = bl_new_tl_env();
    return 1;
}

void bl_cleanup()
{
    /* TODO: free all resources that were allocated during
       the execution
     */
    if (toplevel_env) bl_free_tl_env(toplevel_env);
}

static void print_bl_value(BLWORD value)
{
    if (value == BL_UNDEFINED) return;
    if (value == BL_EMPTY_LIST) {
        fprintf(stdout, "'()");
    } else if (BL_IS_FIXNUM(value)) {
        int n = BL_FIXNUM2INT(value);
        fprintf(stdout, "%d", n);
    } else {
        const char *s = (const char *) value;
        fprintf(stdout, "\"%s\"", s);
    }
}

static void println_bl_value(BLWORD value)
{
    print_bl_value(value);
    fputs("\n", stdout);
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
  This is the real start of the program, it calls bl_main(), defined by the
  compiler output.
*/
int main(int argc, char **argv)
{
    bl_init();
    bl_main();
    bl_cleanup();
    return 1;
}

#include <stdio.h>
#include <stdarg.h>
#include "bl_runtime.h"

int bl_init()
{
    printf("Boing Lisp version 0.002 (c) 2015\n");
    return 1;
}

void bl_cleanup()
{
}

/*
 * Variable argument function.
 */
void bl_println(int numargs, ...)
{
    va_list args;
    BLWORD current;
    int i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, BLWORD);
        if (BL_IS_FIXNUM(current)) {
            int n = BL_TO_FIXNUM(current);
            printf("%d\n", n);
        }
    }
    va_end(args);
}

/* */
int main(int argc, char **argv)
{
    bl_init();
    bl_main();
    bl_cleanup();
    return 1;
}

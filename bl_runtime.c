#include <stdio.h>
#include <stdarg.h>

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
    int current, i;
    va_start(args, numargs);
    for (i = 0; i < numargs; i++) {
        current = va_arg(args, int);
        printf("%d\n", current);
    }
    va_end(args);
}

int main(int argc, char **argv)
{
    bl_println(3, 1, 2, 3);
    return 1;
}

ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/amigadev/NDK_3.9/Include/include_i

ASM = vasmm68k_mot
CC = vc +kick13 -c99
GCC_FLAGS = -std=c99 -pedantic

.PHONY : clean check
.SUFFIXES : .o .asm

all: test

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	rm -f main test bl_environment_test bl_runtime_test *.o *~

test: test.o bl_start.o bl_runtime.o bl_environment.o
	$(CC) -o $@ -s $^

check: bl_environment_test bl_runtime_test
	./bl_environment_test && ./bl_runtime_test

bl_environment_test: bl_environment_test.c chibi_test/chibi.c bl_environment.c
	gcc $(GCC_FLAGS) -o $@ $^

bl_runtime_test: bl_runtime_test.c chibi_test/chibi.c bl_runtime.c bl_environment.c
	gcc $(GCC_FLAGS) -o $@ $^

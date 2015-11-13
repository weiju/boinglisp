ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/amigadev/NDK_3.9/Include/include_i

ASM = vasmm68k_mot
CC = vc +kick13

.PHONY : clean check
.SUFFIXES : .o .asm

all: main test

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	rm -f main test bl_environment_test *.o *~

main: main.o bl_runtime.o bl_environment.o
	$(CC) -o $@ -s $^

test: test.o bl_runtime.o bl_environment.o
	$(CC) -o $@ -s $^

check: bl_environment_test.c chibi.c bl_environment.c
	gcc -o bl_environment_test $^ && ./bl_environment_test

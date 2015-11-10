ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/amigadev/NDK_3.9/Include/include_i

ASM = vasmm68k_mot
CC = vc +kick13

.SUFFIXES : .o .asm

all: main test

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	rm -f main test *.o

main: main.o bl_runtime.o
	$(CC) -o $@ -s $^

test: test.o bl_runtime.o
	$(CC) -o $@ -s $^

ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/amigadev/NDK_3.9/Include/include_i # -L runtime.list
VLINK_FLAGS = -L/home/weiju/local/vbcc/targets/m68k-amigaos/lib -bamigahunk -lamiga
ASM = vasmm68k_mot
CC=vc +kick13

.SUFFIXES : .o .asm .c

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<

.c.o:
	$(CC) -c -o $@ $<

all: ffi1

clean:
	rm -f *.o ffi1

ffi1: main.o ffi1.o myobject.o
	$(CC) -o $@ $^

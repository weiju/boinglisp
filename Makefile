ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/amigadev/NDK_3.9/Include/include_i # -L runtime.list
VLINK_FLAGS = -L/home/weiju/local/vbcc/targets/m68k-amigaos/lib -bamigahunk -lamiga
ASM = vasmm68k_mot
.SUFFIXES : .o .asm

all: main

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	rm -f main *.o

main: main.o runtime.o
	vlink $(VLINK_FLAGS) -o $@ -s $^

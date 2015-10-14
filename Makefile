ASM_FLAGS = -Fhunk -devpac -I/home/weiju/Development/NDK_3.9/Include/include_i
ASM = vasmm68k_mot
.SUFFIXES : .o .asm

all: runtime

.asm.o:
	$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	rm -f runtime *.o


runtime: runtime.o
	vlink -bamigahunk -o $@ -s $<

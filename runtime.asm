        ;; This is the BoingLisp runtime module
        ;; Every compiled Lisp program uses functions out of this
        ;; module
        xdef    init_runtime,cleanup_runtime,nil_str,quote,print_str,println

ABSEXECBASE		EQU	4

        INCLUDE 'exec/exec.i'
        INCLUDE 'runtime_macros.i'

        ;; Initialize the Lisp runtime system
init_runtime:
        move.l	ABSEXECBASE.w,a6
	    lea	    dosname,a1
	    moveq	#0,d0
        JSRLIB  OpenLibrary
	    tst.l	d0
	    beq.s	nodos
        move.l  d0,dosbase
        bsr     print_greeting
nodos:
        rts

        ;; Clean up the runtime system
cleanup_runtime:
	    move.l	dosbase,a1
	    move.l	ABSEXECBASE.w,a6
        JSRLIB  CloseLibrary
        rts

print_greeting:
        PRINT_ADDR   greeting
        rts

        ;; A simple output function that expects the address of the string
        ;; to print as the first argument (on top of the stack)
print_str:
        ;; Parameter is 4 bytes after return address
        move.l  4(a7),a0
        PRINT_A0
        rts

println:
        move.l  4(a7),a0
        PRINT_A0
        lea     line_feed,a0
        PRINT_A0
        rts

quote:
        ;; TODO: quote calls should be optimized by the compiler
        ;; to nothing, it's actually a no-op
        move.l  4(a7),a0
        rts

        ;; ----------------------------------------------------------------
        ;; BSS Section (placed in Fast RAM)
        ;; All explicitly referred data must be aligned to a 32-bit boundary
        ;; so they can at the same time tagged with type information and
        ;; fit into a machine word, on Motorola 68k this is always 32 bit
        ;; ----------------------------------------------------------------
        bss_f
	    align	2
dosbase:
        dc.l    0

        ;; ----------------------------------------------------------------
        ;; Data Section (placed in Fast RAM)
        ;; All explicitly referred data must be aligned to a 32-bit boundary
        ;; so they can at the same time tagged with type information and
        ;; fit into a machine word, on Motorola 68k this is always 32 bit
        ;; Predefined values of length multiples of 4
        ;; ----------------------------------------------------------------
        data_f
        ;; representation of the NIL value
	    align	2
lisp_nil:
        dc.w    0

        ;; Predefined byte strings
	    align	2
dosname:
	    dc.b	'dos.library',0
	    align	2
greeting:
	    dc.b	'Boing Lisp Version 0.001 (c) 2015',10,0
        ;; Note: this is a trick, line_feed is at a 4 byte-boundary
        ;; because nil_str has length 3
	    align	2
nil_str:
        dc.b    "'()"
line_feed:
        dc.b    10,0

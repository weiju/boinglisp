        xdef    print_greeting
        xdef    print_nil
        xdef    init_runtime
        xdef    cleanup_runtime

ABSEXECBASE		EQU	4

        INCLUDE 'exec/exec.i'
        INCLUDE 'runtime_macros.i'

init_runtime:
        move.l	ABSEXECBASE.w,a6
	    lea	    dosname(pc),a1
	    moveq	#0,d0
        JSRLIB  OpenLibrary
	    tst.l	d0
	    beq.s	nodos
        move.l  d0,dosbase
nodos:
        rts

cleanup_runtime:
	    move.l	dosbase,a1
	    move.l	ABSEXECBASE.w,a6
        JSRLIB  CloseLibrary
        rts

print_greeting:
        PRINT_ADDR   greeting
        rts

print_nil:
        PRINT_ADDR  nil_str
        rts

dosbase:
        dc.l    0

dosname:
	    dc.b	'dos.library',0
greeting:
	    dc.b	'Boing Lisp Version 0.001 (c) 2015',10,0
nil_str:
        dc.b    "'()",10,0

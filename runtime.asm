        ;; This is the BoingLisp runtime module
        ;; Every compiled Lisp program uses functions out of this
        ;; module
        xdef    init_runtime,cleanup_runtime,print_nil,nil_str,quote,print_str

ABSEXECBASE		EQU	4

        INCLUDE 'exec/exec.i'
        INCLUDE 'runtime_macros.i'

        ;; Initialize the Lisp runtime system
init_runtime:
        move.l	ABSEXECBASE.w,a6
	    lea	    dosname(pc),a1
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

print_str:
        ;; dummy: get param from stack:
        move.l  (a7)+,a0
        PRINT_ADDR  nil_str
        rts

print_nil:
        PRINT_ADDR  nil_str
        rts

quote:
        rts

        ;; Predefined values of length multiples of 4
dosbase:
        dc.l    0

        ;; Predefined values of length multiples of 2
        ;; representation of the NIL value
lisp_nil:
        dc.w    0

        ;; Predefined byte strings
dosname:
	    dc.b	'dos.library',0
greeting:
	    dc.b	'Boing Lisp Version 0.001 (c) 2015',10,0
nil_str:
        dc.b    "'()",10,0

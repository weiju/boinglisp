;; Exec
ABSEXECBASE		EQU	4

        INCLUDE "exec/exec.i"
        INCLUDE "runtime_macros.i"

        ;; PROGRAM STARTS HERE
start:
        bsr.s   init
        bsr.s   print_greeting
        bra.s   cleanup

init:
        move.l	ABSEXECBASE.w,a6
	    lea	    dosname(pc),a1
	    moveq	#0,d0
        JSRLIB  OpenLibrary
	    tst.l	d0
	    beq.s	nodos
        move.l  d0,dosbase
        rts

print_greeting:
        lea     int_greeting,a0
        PRINT_STR
        lea     ext_greeting,a0
        PRINT_STR
        rts

cleanup:
	    move.l	dosbase,a1
	    move.l	ABSEXECBASE.w,a6
        JSRLIB  CloseLibrary
nodos:
	    moveq	#0,d0
	    rts

dosbase:
        dc.l    0
dosname:
	    dc.b	'dos.library',0

int_greeting:
	    dc.b	'Hello, Lisp (internal) !',10,0

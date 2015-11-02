;; Exec
ABSEXECBASE		EQU	4

        INCLUDE "exec/exec.i"

start:
        bsr.s   init
        bsr.s   print_greeting
        bra.s   cleanup

init:
	    move.l	4.w,a6
	    lea	    dosname(pc),a1
	    moveq	#0,d0
	    JSRLIB  OpenLibrary
	    tst.l	d0
	    beq.s	nodos
	    move.l	d0,dosbase
        rts

print_greeting:
	    lea	msg(pc),a0
	    moveq	#-1,d3
	    move.l	a0,d2
strlen:
	    addq.l	#1,d3
	    tst.b	(a0)+
	    bne.s	strlen
        move.l  dosbase,a6
	    JSRLIB  Output
	    move.l	d0,d1
	    JSRLIB  Write
        rts

cleanup:
	    move.l	dosbase,a1
	    move.l	ABSEXECBASE,a6
	    JSRLIB  CloseLibrary
nodos:
	    moveq	#0,d0
  	    rts

dosbase:
        dc.l    0
dosname:
	    dc.b	'dos.library',0
msg:
	    dc.b	'Hello, world 2 !',10,0

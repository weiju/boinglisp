;; Exec
ABSEXECBASE		EQU	4

        INCLUDE "exec/exec.i"

start:
        move.l	ABSEXECBASE.w,a6
	    lea	dosname(pc),a1
	    moveq	#0,d0
        JSRLIB  OpenLibrary
	    tst.l	d0
	    beq.s	nodos
	    move.l	d0,a6
        xref    GREETING
        lea     GREETING(pc),a0
	    moveq	#-1,d3
	    move.l	a0,d2
strlen:
	    addq.l	#1,d3
	    tst.b	(a0)+
	    bne.s	strlen
        JSRLIB  Output
	    move.l	d0,d1
        JSRLIB  Write
	    move.l	a6,a1
	    move.l	ABSEXECBASE.w,a6
        JSRLIB  CloseLibrary
nodos:
	    moveq	#0,d0
  	    jsr	dummy
	    rts

dummy:	rts

dosname:
	    dc.b	'dos.library',0

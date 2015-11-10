	idnt	"main.c"
	opt	0
	opt	NQLPSMRBT
	section	"CODE",code
	public	_main
	cnop	0,4
_main
	movem.l	l2,-(a7)
	jsr	_bl_main
	moveq	#1,d0
l1
l2	reg
l4	equ	0
	rts
	public	_bl_main

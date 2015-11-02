        IFND RUNTIME_MACROS_I
RUNTIME_MACROS_I    SET     1

        ;; MACROS
        ;; strlen()
        ;; a0: pointer to the string (0-terminated)
        ;; return value: length of string in d0
        ;; uses registers a0,a1,d0,d1,d2,d3
STRLEN_A0   MACRO
	    moveq	#-1,d0
strlen_loop\@:
	    addq.l	#1,d0
	    tst.b	(a0)+
	    bne.s	strlen_loop\@
        ENDM

        ;; prints the specified address
        ;; prints 0-terminated string
        ;; param 1: label to the string
PRINT_ADDR   MACRO
        lea     \1,a0
        move.l  a0,a1           ; save string pointer
        STRLEN_A0
        move.l  d0,d3
        ;; note that a0 has been incremented by STRLEN
        ;; restore the string address
        move.l  a1,d2

        move.l  dosbase,a6
        JSRLIB  Output
	    move.l	d0,d1
        JSRLIB  Write
        ENDM

        ENDC                    ; RUNTIME_MACROS_I

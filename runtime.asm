        ;; This is the BoingLisp runtime module
        ;; Every compiled Lisp program uses functions out of this
        ;; module
        xdef    init_runtime,cleanup_runtime,nil_str,quote,print_str,println
        xdef    add_int

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

add_int:
        ;; Currently, this only adds 2 values, TODO: add arbitrary number
        ;; Parameter is 4 bytes after return address
        ;; a0 :=  sum(parameters)
        move.l  4(a7),d0
        move.l  8(a7),d0
        move.l  12(a7),d1
        asr.l   #1,d0
        asr.l   #1,d1
        add.l   d0,d1
        asl.l   #1,d1
        ori.l   #1,d1
        move.l  d1,a0
        rts

        ;; A simple output function that expects the address of the string
        ;; to print as the first argument (on top of the stack)
print_str:
        ;; Parameter is 4 bytes after return address
        move.l  4(a7),a0        ; # args
        move.l  8(a7),a0        ; first arg
        PRINT_A0
        rts

println:
        move.l  4(a7),a0        ; # args
        move.l  8(a7),a0        ; first arg
        move.l  a0,d0
        btst    #0,d0
        beq     println_do_str
        ;; number conversion
        bsr     itoa
        lea     itoa_buf,a0
println_do_str:
        PRINT_A0
        lea     line_feed,a0
        PRINT_A0
        rts

        ;; the number to convert is in d0
        ;; the output will be in itoa_buf
        ;; the idea is to build the string from the smallest digit to the
        ;; largest and then reverse the string
        ;; one of the problems is that the div instruction will
        ;; overflow on large numbers.
        ;; For now, we will only ensure working on numbers
        ;; which divided by 10 fit in the 16bit range
        ;; TODO: 31 bit numbers, negative numbers
itoa:   lea     itoa_buf,a0
        asr.l   #1,d0           ; get rid of the LSB (marking fixnum)

itoa_loop:
        divu    #10,d0          ; quotient in lo16, remainder in hi16
        move.l  d0,d1
        swap    d1              ; 16-bit remainder (a single digit)
        move.b  #'0',d2
        add.b   d1,d2           ; d2 := d1 + d2
        move.b  d2,(a0)+
        cmp.w   #0,d0           ; are we finished ?
        beq     itoa_end        ; yes
        andi.l  #$ffff,d0       ; get rid of the remainder
        bra     itoa_loop
itoa_end:
        ;; TODO: reverse the string
        move.b  #0,(a0)
        rts


;; itoa:   lea itoa_buf,a0
;;         move.l  #10,d0
;;         move.l  #40,d1
;;         ;; note: the quotient has to fit in a 16-bit word on MC68000!!!
;;         divu    d0,d1           ; d1 := d1 / d0
;;         move.b  #'0',d2
;;         add.b   d1,d2           ; d2 := d1 + d2
;;         move.b  d2,(a0)+
;;         move.b  #0,(a0)
;;         rts

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
        ;; This is the buffer to use for int -> string conversion
        ;; since the maximum length including the optional sign is 11,
        ;; 12 bytes is large enough to hold the 0 byte as well
itoa_buf:
        ds.b    12

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

	    align	2
is_int_msg:
	    dc.b	'result is integer',10,0
        ;; Note: this is a trick, line_feed is at a 4 byte-boundary
        ;; because nil_str has length 3
	    align	2
nil_str:
        dc.b    "'()"
line_feed:
        dc.b    10,0

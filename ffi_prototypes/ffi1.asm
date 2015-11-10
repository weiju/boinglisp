        code
        xdef    _bl_main
        cnop    0,4
_bl_main:
        move.l  #41,-(a7)
        move.l  #2,-(a7)
        jsr     _myfun
        add.l   #8,a7
        ;; move.l  d0,-(a7)
        ;; jsr     _mycall
        rts

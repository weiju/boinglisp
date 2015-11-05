
        INCLUDE "exec/exec.i"
        INCLUDE "runtime_macros.i"

        ;; PROGRAM STARTS HERE
start:
        bsr     init_runtime
	    tst.l	d0
        beq.s   error
        bsr     print_nil
        bsr     cleanup_runtime

error:
	    moveq	#0,d0
	    rts


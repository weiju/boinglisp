#lang racket
;; This is a small compiler written in Racket that compiles
;; S-Expressions into 3-address code.
;;
;; Implementation will be in 3 steps:
;; 1. run in Racket
;; 2. run on the Lisp interpreter
;; 3. compile in compiler

;; --------------------------
;; TODO:
;; -----
;; 1. integrate literal registration
;; database with unique labels for literals
;; literals are printed in a separate section
;; e.g.
;; (string-literal sl-0 "string 1")
;; (int-literal il-0 123)
;; ...
;; ---------------------------


;; currently the only public procedure is
;; compile-file
(provide compile-file)

;; state of a template
;; slots the literal slots
;; code the code of the template
;; slits string literals
;; ilits int literals
(struct tmpstate (slots code slits ilits) #:mutable #:transparent)

;; manage the compile state in this object
;; lcount is the current label counter
;; tcount is the current template slot counter
(struct cstate (lcount curr-templ) #:mutable #:transparent)

(define (atom? x) (not (or (pair? x) (null? x))))

;; ensure we emit the literals with the correct
;; representation in intermediate code
(define (as-literal value)
  (cond [(string? value) (string-append "\"" value "\"")]
        [else value]))

;; emit intermediate code
;; we can either emit S-Expressions or a plain format which is easier
;; to process by non-lisp languages
(define (emit-push-param) (printf "  (push)~n"))
(define (emit-fetch-literal rval) (printf "  (fetch-literal ~a)~n" (as-literal rval)))
(define (emit-fetch-nil) (printf "  (fetch-nil)~n"))
(define (emit-call fun) (printf "  (lookup-variable ~a)~n  (apply)~n" fun))
(define (emit-lookup-variable varname) (printf "  (lookup-variable ~a)~n" varname))
(define (emit-println) (printf "  (push)~n  (lookup-variable println)~n  (apply)~n"))

;; process function arguments right-to-left
(define (process-args args state)
  (cond [(not (empty? args))
         (let ([arg (last args)])
           (compile-exp arg state)
           (emit-push-param))
         (process-args (drop-right args 1) state)]))

;; management procedure for literal and template slot space
;; TODO: very obviously, this is not exactly what we need, instead,
;; we need to emit code to do this in the emitted current frame
(define (register-literal state literal)
  (let* ([tstate (cstate-curr-templ state)]
         [curr-slot (length (tmpstate-slots tstate))])
    ;; TODO: allocate a reference and put the reference to the literal
    ;; into the slots list
    (printf ";; literal: '~a'~n" literal)
    (cond [(string? literal)
           (set-tmpstate-slots! tstate (cons (string-append "s-"
                                                           (~a (length (tmpstate-slits tstate))))
                                             (tmpstate-slots tstate)))
           (set-tmpstate-slits! tstate (cons literal (tmpstate-slits tstate)))
           (printf "  (register-string-literal '~a')~n" literal)]
          [else
           (set-tmpstate-slots! tstate (cons (string-append "i-"
                                                            (~a (length (tmpstate-ilits tstate)))) 
                                             (tmpstate-slots tstate)))
           (set-tmpstate-ilits! tstate (cons literal (tmpstate-ilits tstate)))])
    (printf ";; ~a~n" state)
    curr-slot))

;; compile expression (recursive)
;; cont-count is the counter for continuation labels
(define (compile-exp sexp state)
  (cond
    [(atom? sexp)
     (cond [(symbol? sexp)
            (emit-lookup-variable sexp)]
           [else
            ;; TODO: register literal for current function's template frame
            ;; and emit the offset
            (emit-fetch-literal (register-literal state sexp))])]
    [(null? sexp) (emit-fetch-nil)]
    [else (let ([fun (car sexp)])
            (process-args (cdr sexp) state)
            (emit-call fun))]))

;; compile an s-expression (top-level)
(define (compile-stream sexp-num compiler-state in)
  (let ([sexp (read in)])
    (cond [(eof-object? sexp) #t]
          [else
           (printf ";; sexp ~a~n" sexp-num)
           (compile-exp sexp compiler-state)
           (emit-println)
           (compile-stream (+ sexp-num 1) compiler-state in)])))

;; compiling a file
(define (compile-file filename)
  (printf ";; compiling file: \"~a\"~n" filename)
  (let ([in (open-input-file filename)]
        [compiler-state (cstate 0 (tmpstate '() '() '() '()))])
    (compile-stream 1 compiler-state in)
    (close-input-port in)))

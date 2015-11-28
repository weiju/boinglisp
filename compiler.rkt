#lang racket
;; This is a small compiler written in Racket that compiles
;; S-Expressions into 3-address code.
;;
;; Implementation will be in 3 steps:
;; 1. run in Racket
;; 2. run on the Lisp interpreter
;; 3. compile in compiler

;; currently the only public procedure is
;; compile-file
(provide compile-file)

;; manage the compile state in this object
;; lcount is the current label counter
;; slitvals is a hash table (label -> literal)
;; curr-templ current template data item
(struct cstate (lcount slitvals symbols) #:mutable #:transparent)

(define (atom? x) (not (or (pair? x) (null? x))))

;; ensure we emit the literals with the correct
;; representation in intermediate code
(define (as-literal value)
  (cond [(string? value) (string-append "\"" value "\"")]
        [else value]))

;; emit intermediate code
;; we can either emit S-Expressions or a plain format which is easier
;; to process by non-lisp languages
(define (emit-push-param) (printf "(push)~n"))
;; integer literals are treated specially: for most part we assume that
;; they fit into a Lisp value (e.g. into a car or cdr of a cons cell)
;; so we don't store them in the static data section for now
(define (emit-fetch-literal spec)
  (cond [(eq? 'string-literal (car spec))
         (printf "(fetch-str-literal ~a)~n" (as-literal (cadr spec)))]
        [else (printf "(fetch-int-literal ~a)~n" (cadr spec))]))
(define (emit-fetch-symbol symbol)
  (printf "(fetch-symbol \"~a\")~n" symbol))
(define (emit-fetch-nil) (printf "(fetch-nil)~n"))
(define (emit-call fun) (printf "(lookup-variable ~a)~n(apply)~n" fun))
(define (emit-lookup-variable varname) (printf "(lookup-variable ~a)~n" varname))
(define (emit-println) (printf "(push)~n(lookup-variable println)~n(apply)~n"))
(define (emit-continuation state)
  (let ([label (string-append "resume" (~a (cstate-lcount state)))])
    (printf "(push-continuation \"~a\")~n" label)
    (set-cstate-lcount! state (+ (cstate-lcount state) 1))
    label))
(define (emit-label label) (printf "(label \"~a\")~n" label))

(define (emit-literals compiler-state)
  (let [(sliterals (cstate-slitvals compiler-state))]
    (printf ";; literals follow here~n")
    (hash-for-each sliterals (lambda (key value)
                               (printf "(string-literal ~a \"~a\")~n" key value)))))

(define (emit-symbols compiler-state)
  (let [(symbols (cstate-symbols compiler-state))]
    (printf ";; symbols follow here~n")
    (hash-for-each symbols (lambda (key value)
                             (printf "(symbol ~a \"~a\")~n" key value)))))

(define (emit-define define-args compiler-state)
  (let ([bind-target (car define-args)])
    ;; need to check:
    ;; 1. only 2 arguments
    ;; 2. first argument can only be
    ;;   a. identifier (simple binding)
    ;;   b. list with at least one identifier (named function)
    (cond [(symbol? bind-target)
           ;; generate space for symbol
           (emit-fetch-symbol (register-symbol compiler-state bind-target))
           (emit-push-param)
           (compile-exp (cadr define-args) compiler-state)
           (emit-push-param)
           (printf "(tl-env-bind)~n")]
          [(printf ";; (TODO: handle lambda) bind-target: ~a~n" bind-target)])
    ))

;; process function arguments right-to-left
(define (process-args args state)
  (cond [(not (empty? args))
         (let ([arg (last args)])
           (compile-exp arg state)
           (emit-push-param))
         (process-args (drop-right args 1) state)]))

;; management procedure for literals
(define (register-literal state literal)
  ;; allocate a reference and put the reference to the literal
  ;; into the slots list
  (cond [(string? literal)
         (let ([litlabel (string-append "s" (~a (hash-count (cstate-slitvals state))))])
           (hash-set! (cstate-slitvals state) litlabel literal)
           (printf ";; ~a~n" state)
           (list 'string-literal litlabel))]
        [else (list 'int-literal literal)]))

;; management procedure for symbols
(define (register-symbol state symbol)
  (let ([symlabel (string-append "sym" (~a (hash-count (cstate-symbols state))))])
           (hash-set! (cstate-symbols state) symlabel symbol)
           (printf ";; ~a~n" state)
           symlabel))

;; compile expression (recursive)
;; cont-count is the counter for continuation labels
(define (compile-exp sexp state)
  (cond
    [(atom? sexp)
     (cond [(symbol? sexp)
            (emit-lookup-variable sexp)]
           [else
            (emit-fetch-literal (register-literal state sexp))])]
    [(null? sexp) (emit-fetch-nil)]
    [else (let ([fun (car sexp)])
            (cond
              ;; special forms evaluate their argument differently
              ;; we do not generate any continuations for them for now
              [(eq? 'define fun) (emit-define (cdr sexp) state)]
              [(let ([label (emit-continuation state)])
                (process-args (cdr sexp) state)
                (emit-call fun)
                (emit-label label))]))
]))

;; ----------------------------------------------------
;; Top-level calls
;;
;; These are the starting points, the top-level input
;; goes in here as well as the initialized compiler state
;; ----------------------------------------------------
;; compile an s-expression (top-level)
(define (compile-stream sexp-num compiler-state in)
  (let ([sexp (read in)])
    (cond [(eof-object? sexp)
           (printf "(end-program)~n")
           (emit-literals compiler-state)
           (emit-symbols compiler-state)]
          [else
           (printf ";; sexp ~a~n" sexp-num)
           (compile-exp sexp compiler-state)
           (emit-println)
           (compile-stream (+ sexp-num 1) compiler-state in)])))

;; compiling a file
(define (compile-file filename)
  (printf ";; compiling file: \"~a\"~n" filename)
  (let ([in (open-input-file filename)]
        [compiler-state (cstate 0 (make-hash) (make-hash))])
    (compile-stream 1 compiler-state in)
    (close-input-port in)))

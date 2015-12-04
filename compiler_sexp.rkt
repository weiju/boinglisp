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
(provide compile-file compile-exp cstate cstate-string-literal-for
         cstate-symbol-for)

;; ************************************************************************
;; **** COMPILER STATE
;; *************************************
;; manage the compile state in this object
;; lcount is the current label counter
;; slitvals is a hash table (label -> literal)
;; curr-templ current template data item
(struct cstate (lcount slitvals symbols) #:mutable #:transparent)

(define (cstate-string-literal-for state key)
  (hash-ref (cstate-slitvals state) key))
(define (cstate-symbol-for state key)
  (hash-ref (cstate-symbols state) key))

;; generates a new label and updates the label counter
(define (next-label state prefix)
  (let ([result (string-append prefix (~a (cstate-lcount state)))])
    (set-cstate-lcount! state (+ (cstate-lcount state) 1))
    result))

;; tries to retrieve a symbol from compiler state, if it exists,
;; returns the key, otherwise the empty list
(define (find-symbol state sym)
  (let [(match (filter (lambda (pair) (eq? (cdr pair) sym))
                       (hash->list (cstate-symbols state))))]
    (cond [(empty? match) '()]
          [(caar match)])))

;; ***********************************************************************
;; ***** General Helpers
;; *********************************
(define (atom? x) (not (or (pair? x) (null? x))))

;; ensure we emit the literals with the correct
;; representation in intermediate code
(define (as-literal value)
  (cond [(string? value) (~a value)]
        [else value]))

;; ***********************************************************************
;; ***** Code Generation
;; ***** All emitters should returns lists of s-expressions so we
;; ***** can uniformly use append
;; *********************************
;; emit intermediate code
;; we can either emit S-Expressions or a plain format which is easier
;; to process by non-lisp languages
(define (emit-push-param) '((push)))
;; integer literals are treated specially: for most part we assume that
;; they fit into a Lisp value (e.g. into a car or cdr of a cons cell)
;; so we don't store them in the static data section for now
(define (emit-fetch-literal spec)
  (cond [(eq? 'string-literal (car spec))
         (list (list 'fetch-str-literal (as-literal (cadr spec))))]
        [else (list (list 'fetch-int-literal (cadr spec)))]))
(define (emit-fetch-symbol symbol) (list (list 'fetch-symbol symbol)))
(define (emit-fetch-nil) '((fetch-nil)))
(define (emit-call fun) (list (list 'lookup-variable fun) '(apply)))
(define (emit-lookup-variable varname state)
  (let [(sym (find-symbol state varname))]
    (cond [(not (null? sym)) (list (list 'lookup-env sym))]
          [(list (list 'lookup-variable varname))])))

(define (emit-println) (list '(push) '(lookup-variable println) '(apply)))
(define (emit-continuation state label) (list (list 'push-continuation label)))
(define (emit-label label) (list (list 'label label)))
(define (emit-tlenv-bind) '((tl-env-bind)))

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


;; ***********************************************************************
;; ***** Compiler logic
;; *********************************

(define (compile-define define-args compiler-state)
  (let ([bind-target (car define-args)])
    ;; need to check:
    ;; 1. only 2 arguments
    ;; 2. first argument can only be
    ;;   a. identifier (simple binding)
    ;;   b. list with at least one identifier (named function)
    (cond [(symbol? bind-target)
           ;; generate space for symbol
           (append
            (compile-exp (cadr define-args) compiler-state)
            (emit-push-param)
            (emit-fetch-symbol (register-symbol compiler-state bind-target))
            (emit-push-param)
            (emit-tlenv-bind))]
          [(printf ";; (TODO: handle lambda) bind-target: ~a~n" bind-target)])
    ))

;; process function arguments right-to-left
(define (process-args args state current-out)
  (cond [(not (empty? args))
         (let ([arg (last args)])
           (process-args (drop-right args 1) state
                         (append (compile-exp arg state)
                                 (emit-push-param)
                                 current-out)))]
        [else current-out]))

;; management procedure for literals
(define (register-literal state literal)
  ;; allocate a reference and put the reference to the literal
  ;; into the slots list
  (cond [(string? literal)
         (let ([litlabel (string-append "s" (~a (hash-count (cstate-slitvals state))))])
           (hash-set! (cstate-slitvals state) litlabel literal)
           (list 'string-literal litlabel))]
        [else (list 'int-literal literal)]))

;; management procedure for symbols
(define (register-symbol state symbol)
  (let ([symlabel (string-append "sym" (~a (hash-count (cstate-symbols state))))])
           (hash-set! (cstate-symbols state) symlabel symbol)
           symlabel))

;; TODO: optimization: after a branch whose condition is always true
;; (either else or #t), just stop compiling the rest of the branches
;; test each condition one after another.
;; If condition is true:
;;   1. execute body
;;   2. goto exit-label
;; else skip to next condition label
(define (compile-cond branches branch-label exit-label state)
  (cond [(not (empty? branches))
         (emit-label branch-label)
         (let* ([branch (car branches)]
                [next-branch-label (next-label state "cond")]
                [condition (car branch)])
           ;; note that we currently require the else keyword
           (cond [(not (equal? condition 'else))
                  (printf ";; branch condition: ~a~n" condition)
                  (compile-exp condition state)
                  (printf "(branch-false ~a)~n" next-branch-label)])
           (compile-exp-list (cdr branch) state)
           (printf "(branch ~a)~n" exit-label)
           (compile-cond (cdr branches) next-branch-label exit-label state))]
        [else (emit-label exit-label)]))

;; compile a list of expressions
(define (compile-exp-list sexp-list state)
  (cond [(not (empty? sexp-list))
         (compile-exp (car sexp-list) state)
         (compile-exp-list (cdr sexp-list) state)]))

;; compile expression (recursive)
;; cont-count is the counter for continuation labels
(define (compile-exp sexp state)
  (cond
    [(atom? sexp)
     (cond [(symbol? sexp)
            ;; TODO: if the variable is in the registered symbols
            ;; replace with a lookup using the symbol reference
            (emit-lookup-variable sexp state)]
           [else
            (emit-fetch-literal (register-literal state sexp))])]
    [(null? sexp) (emit-fetch-nil)]
    [else (let ([fun (car sexp)])
            (cond
              ;; Special forms (syntactic forms):
              ;; different order of processing arguments
              ;; and no generation of continuations
              [(eq? 'define fun) (compile-define (cdr sexp) state)]
              [(eq? 'cond fun) (compile-cond (cdr sexp)
                                             (next-label state "cond")
                                             (next-label state "condexit")
                                             state)]
              ;; Functions
              [else
               (let ([label (next-label state "resume")])
                 (append (append (emit-continuation state label)
                                 (process-args (cdr sexp) state '())
                                 (emit-call fun) (emit-label label))))]))]))

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

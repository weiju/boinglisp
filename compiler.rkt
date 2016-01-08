#lang racket
;; This is a small compiler written in Racket that compiles
;; S-Expressions into intermediate code represented.
;;
;; Implementation will be in 3 steps:
;; 1. run in Racket
;; 2. run on the Lisp interpreter
;; 3. compile in compiler

;; currently the only public procedure is
;; compile-file
(provide compile-file compile-exp
         new-compiler-state
         cstate-string-literal-for
         cstate-symbol-for
         size-local-env-stack)

;; ************************************************************************
;; **** COMPILER STATE
;; *************************************

;; a lambda object within the compiler is held in its original form
;; so the code can be generated at the if it is referenced at all
(struct lambda-object (params body))

;; manage the compile state in this object
;; lcount is the current label counter
;;   there is only one label counter
;; slitvals is a hash table (label -> literal)
;; symbols is a hash table (label -> symbol)
;; lambdas is a hash table (label -> lambda)
;; local-envs is a list that represents a stack of local environments/scopes
;;   scope objects help to generate environment offsets in the output
(struct cstate (lcount
                slitvals
                symbols
                lambdas
                local-envs)
  #:mutable #:transparent)

(define (new-compiler-state) (cstate 0 (make-hash) (make-hash) (make-hash) '()))

;; returns a pair of (environment, slot) indexes for a given
;; symbol or '()
(define (find-in-env env symbol index)
  (cond [(empty? env) -1]
        [(eq? (car env) symbol) index]
        [else (find-in-env (cdr env) symbol (+ index 1))]))
(define (locals-pos-priv env-stack symbol pos)
  (cond [(empty? env-stack) '()]
        [else
         (let ([slot (find-in-env (car env-stack) symbol 0)])
           (cond [(= slot -1) (locals-pos-priv (cdr env-stack) symbol (+ pos 1))]
                 [else (list pos slot)]))]))
(define (locals-pos state symbol)
  (locals-pos-priv (cstate-local-envs state) symbol 0))
(define (size-local-env-stack state) (length (cstate-local-envs state)))

(define (cstate-string-literal-for state key)
  (hash-ref (cstate-slitvals state) key))
(define (cstate-symbol-for state key)
  (hash-ref (cstate-symbols state) key))
(define (push-local-env state names)
  (set-cstate-local-envs! state (cons names (cstate-local-envs state))))
(define (pop-local-env state) (set-cstate-local-envs! state (cdr (cstate-local-envs state))))

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

;; management procedure for lambdas
;; TODO: create a closure if we are created within a local scope
(define (add-lambda state params body)
  (let ([lambda-label (string-append "lambda" (~a (hash-count (cstate-lambdas state))))])
    (hash-set! (cstate-lambdas state) lambda-label
               (lambda-object params (compile-exp-list body state)))
    (printf ";; STATE: ~a~n" state)
    lambda-label))

;; ***********************************************************************
;; ***** General Helpers
;; *********************************
(define (atom? x) (not (or (pair? x) (null? x))))

;; ensure we emit the literals with the correct
;; representation in intermediate code
(define (as-literal value)
  (cond [(string? value) (~a value)]
        [else value]))

(define (flatmap f lst) (apply append (map f lst)))
(define (flatmap-index f lst) (apply append (map-index f lst 0)))

;; like map, but expects f to be a function (int, *) -> *
(define (map-index f lst i)
  (cond [(empty? lst) lst]
        [else (cons (f i (car lst)) (map-index f (cdr lst) (+ i 1)))]))
  

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
    (hash-map sliterals (lambda (key value)
                          (list 'string-literal key value)))))

(define (emit-symbols compiler-state)
  (let [(symbols (cstate-symbols compiler-state))]
    (hash-map symbols (lambda (key value)
                        (list 'symbol key value)))))

(define (emit-lambdas compiler-state)
  (let [(lambdas (cstate-lambdas compiler-state))]
    (apply append (hash-map lambdas (lambda (label lobj)
                                      (append
                                       (emit-label label)
                                       (lambda-object-body lobj)))))))

(define (emit-branch-false label) (list (list 'branch-false label)))
(define (emit-branch label) (list (list 'branch label)))
(define (emit-new-local-env num-slots) (list (list 'new-local-env num-slots)))
(define (emit-local-lookup env-pos) (list (list 'local-lookup (car env-pos) (cadr env-pos))))
(define (emit-pop-local-env) '((pop-local-env)))

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
;; TODO: can we simplify by using map ??
(define (process-args args state current-out)
  (cond [(empty? args) current-out]
        [else
         (let ([new-out (append current-out
                                (compile-exp (last args) state)
                                (emit-push-param))])
           (process-args (drop-right args 1) state new-out))]))


;; TODO: optimization: after a branch whose condition is always true
;; (either else or #t), just stop compiling the rest of the branches
;; test each condition one after another.
;; If condition is true:
;;   1. execute body
;;   2. goto exit-label
;; else skip to next condition label
(define (compile-cond branches branch-label exit-label state)
  (cond [(not (empty? branches))
         (append
          (emit-label branch-label)
          (let* ([branch (car branches)]
                 [next-branch-label (next-label state "cond")]
                 [condition (car branch)])
            ;; note that we currently require the else keyword
            (append
             (cond [(not (equal? condition 'else))
                    (append (compile-exp condition state) (emit-branch-false next-branch-label))]
                   [else '()])
             (compile-exp-list (cdr branch) state)
             (emit-branch exit-label)
             (compile-cond (cdr branches) next-branch-label exit-label state))))]
        [else (emit-label exit-label)]))

;; binds the given expression to the local env slot i
(define (compile-binding i sexp state)
  (append (compile-exp sexp state)
          (emit-push-param)
          (list (list 'local-env-bind i))))

;; compile a let special form
(define (compile-let rest state)
  (let ([bindings (car rest)]
        [body (cdr rest)])
    (push-local-env state (map car bindings))
    ;;(printf ";; bindings: ~a~n" bindings)
    (let ([result (append (emit-new-local-env (length bindings))
            (flatmap-index (lambda (i binding) (compile-binding i (cadr binding) state)) bindings)
            (compile-exp-list body state)
            (emit-pop-local-env))])
      (pop-local-env state)
      result)))

(define (compile-lambda params body state)
  (let ([lambda-label (add-lambda state params body)])
    (printf ";; LAMBDA params: ~a body: ~a STATE: [~a]~n" params body state) '()
    ;; assuming the backend knows what to do
    (list (list 'make-closure lambda-label))
    ))

(define (compile-exp-list sexps state)
  (flatmap (lambda (sexp) (compile-exp sexp state)) sexps))

;; compile expression (recursive)
;; cont-count is the counter for continuation labels
(define (compile-exp sexp state)
  (cond
    [(atom? sexp)
     (cond [(symbol? sexp)
            ;; local or global lookup ?
            ;; TODO: if lambda, we have to check the parameters as well
            (let ([env-pos (locals-pos state sexp)])
              (cond [(empty? env-pos) (emit-lookup-variable sexp state)]
                    [else (emit-local-lookup env-pos)]))]
           [else
            (emit-fetch-literal (register-literal state sexp))])]
    [(null? sexp) (emit-fetch-nil)]
    [else (let ([form (car sexp)])
            (cond
              ;; Special forms (syntactic forms):
              ;; different order of processing arguments
              ;; and no generation of continuations
              [(eq? 'define form) (compile-define (cdr sexp) state)]
              [(eq? 'cond form) (compile-cond (cdr sexp)
                                             (next-label state "cond")
                                             (next-label state "condexit")
                                             state)]
              [(eq? 'let form) (compile-let (cdr sexp) state)]
              [(eq? 'lambda form) (compile-lambda (cadr sexp) (cddr sexp) state)]

              ;; Functions
              [else
               (let ([label (next-label state "resume")])
                 (append (append (emit-continuation state label)
                                 (process-args (cdr sexp) state '())
                                 (cond [(atom? form) (emit-call form)]
                                       ;; function is a lambda expression, which needs to be
                                       ;; compiled into a template and closure
                                       [else (append (compile-exp form state) '((push) (apply)))])
                                 (emit-label label))))]))]))

;; ----------------------------------------------------
;; Top-level calls
;;
;; These are the starting points, the top-level input
;; goes in here as well as the initialized compiler state
;; ----------------------------------------------------
;; compile an s-expression (top-level)
(define (compile-stream sexp-num compiler-state in output-list)
  (let ([sexp (read in)])
    (cond [(eof-object? sexp)
           (append output-list
                   '((end-program))
                   (emit-literals compiler-state)
                   (emit-symbols compiler-state)
                   (emit-lambdas compiler-state))]
          [else
           (let ([new-output-list (append output-list
                                          (compile-exp sexp compiler-state)
                                          (emit-println))])
             (compile-stream (+ sexp-num 1) compiler-state in new-output-list))])))

;; compiling a file
(define (print-il program)
  (cond [(not (empty? program))
         (write (car program))
         (newline)
         (print-il (cdr program))]))

(define (compile-file filename)
  (printf ";; compiling file: \"~a\"...~n" filename)
  (let* ([in (open-input-file filename)]
         [il-program (compile-stream 1 (new-compiler-state) in '())])
    (close-input-port in)
    (print-il il-program)))

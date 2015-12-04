#lang racket
(require rackunit "compiler_sexp.rkt")

;; Unit tests to test the compiler stage
;; helper function to make an initial compiler state
(define (new-compiler-state) (cstate 0 (make-hash) (make-hash)))

;; tests for self-evaluating
(check-equal? (compile-exp '() (new-compiler-state)) '((fetch-nil)) "compile empty list")
(check-equal? (compile-exp 1 (new-compiler-state)) '((fetch-int-literal 1)) "compile int")
(let* ([mycstate (new-compiler-state)]
        [output (compile-exp "hello" mycstate)])
  (check-equal? output '((fetch-str-literal "s0")) "compile string")
  (check-equal? (cstate-string-literal-for mycstate "s0") "hello" "state contains hello"))

;; tests for procedure-calls
(let* ([mycstate (new-compiler-state)]
        [output (compile-exp '(print "hello") mycstate)])
  (check-equal? output '((push-continuation "resume0")
                         (fetch-str-literal "s0")
                         (push)
                         (lookup-variable print)
                         (apply)
                         (label "resume0")) "check print")
  (check-equal? (cstate-string-literal-for mycstate "s0") "hello" "state contains hello"))

;; test for define with a simple value
(let* ([mycstate (new-compiler-state)]
       [output (compile-exp '(define a 10) mycstate)])
  (check-equal? output '((fetch-int-literal 10)
                         (push)
                         (fetch-symbol "sym0")
                         (push)
                         (tl-env-bind)))
  (check-equal? (cstate-symbol-for mycstate "sym0") 'a "state contains a"))

;; lookup without an existing top-level binding
(let* ([mycstate (new-compiler-state)]
       [output (compile-exp 'a mycstate)])
  (check-equal? output '((lookup-variable a))))
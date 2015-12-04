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


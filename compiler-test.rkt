#lang racket
(require rackunit "compiler_sexp.rkt")

;; Unit tests to test the compiler stage
;; helper function to make an initial compiler state
(define (new-compiler-state) (cstate 0 (make-hash) (make-hash)))

(check-equal? (compile-exp '() (new-compiler-state)) '(fetch-nil) "compile empty list")
(check-equal? (compile-exp 1 (new-compiler-state)) '(fetch-int-literal 1) "compile int")
(let* ([mycstate (new-compiler-state)]
        [output (compile-exp "hello" mycstate)])
  (check-equal? output '(fetch-str-literal "s0") "compile string")
  (check-equal? (cstate-string-literal-for mycstate "s0") "hello") "state contains hello")

(compile-exp '(print "hello") (new-compiler-state))
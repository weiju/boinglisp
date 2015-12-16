#lang racket
(require rackunit "compiler.rkt")

;; Unit tests to test the compiler stage

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

;; cond-form
(let* ([mycstate (new-compiler-state)]
       [output (compile-exp '(cond  ((= 1 2) 1) (else 2)) mycstate)])
  (check-equal? output '((label "cond0")
                         (push-continuation "resume3")
                         (fetch-int-literal 2)
                         (push)
                         (fetch-int-literal 1)
                         (push)
                         (lookup-variable =)
                         (apply)
                         (label "resume3")
                         (branch-false "cond2")
                         (fetch-int-literal 1)
                         (branch "condexit1")
                         (label "cond2")
                         (fetch-int-literal 2)
                         (branch "condexit1")
                         (label "condexit1"))))

;; simple let-form
(let* ([mycstate (new-compiler-state)]
       [output (compile-exp '(let  ([a 1]) a) mycstate)])
  (check-equal? output '((new-local-env 1)
                         (fetch-int-literal 1)
                         (push)
                         (local-env-bind 0)
                         (local-lookup 0 0)
                         (pop-local-env)))
  (check-equal? (size-local-env-stack mycstate) 0 "environment should have been popped off"))
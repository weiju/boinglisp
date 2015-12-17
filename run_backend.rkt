#lang racket
(require "backend.rkt")

(define (il-to-asm filename)
  (let ([in (open-input-file filename)])
    (translate-stream in)))

(print-prologue)
(translate-stream '(0) (current-input-port))
(print-epilogue)

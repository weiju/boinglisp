#lang racket
(require racket/cmdline)
(require "compiler.rkt")

(define file-to-compile
  (command-line
   #:program "compiler"
   #:args (filename)
   (compile-file filename)))

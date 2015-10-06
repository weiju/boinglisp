#lang racket
(require racket/cmdline)
(require "compiler.rkt")

(define file-to-compile
  (command-line
   #:program "compiler"
   #:once-any
   ["--plain" "output in plain format" (output-format "plain")]
   #:args (filename)
   (compile-file filename)))

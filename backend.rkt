#lang racket

(define (translate-instr instr)
  (let ([code (car instr)])
    (printf "~a~n" code)))

(define (translate-stream in)
  (let ([instr (read in)])
    (cond [(eof-object? instr) #t]
          [else 
           (translate-instr instr)
           (translate-stream in)])))

(define (il-to-asm filename)
  (let ([in (open-input-file filename)])
    (translate-stream in)))

(translate-stream (current-input-port))

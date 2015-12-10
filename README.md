# Boing Lisp

## Introduction

Boing Lisp is a small Lisp compiler system written in Racket. The current version
generates Motorola 68k assembly code to be compiled in a VBCC/VASM environment
for AmigaOS.

This project is for me to study practical programming language concepts targetting
the clean, simple and fun Amiga platform.

The intention is to create a language that is inspired by Racket, attempting to
keep it small yet useful enough to write applications.

## System requirements

    * PLT Racket >= 6.x
    * VBCC
    * VASM
    * GNU Make

For running test suite for backend:

    * gcc

## Run compilation

Currently, this project assumes a single source file that will
be compiled into a file named `test.asm`:

```
racket run_compiler.rkt <source-file> | racket backend.rkt > test.asm
make
```

## Run test suite

For the compiler:

```
racket compiler-test.rkt
```

For the backend:

```
make check
```

## Status

The compiler's functionality is currently very limited, but it is capable of
producing working 68k AmigaOS command line applications.

Current features:

    * compiles a single lisp source file to a single 68k assembly file
    * unit test suite for compiler
    * simple integer math
    * output to console
    * supported types: int, bool, string
    * store and retrieve variables (define)
    * conditionals (cond-form)
    * local bindings (let-form)

## Roadmap, TODOs

### Language features

    * lambdas
    * heap-allocation of cons cells
    * garbage collection
    * list functions
    * loop form

### OS support

    * UI integration
    * graphics
    * IO

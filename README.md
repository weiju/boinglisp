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

For running test suite:

    * gcc

## Run compilation

```
racket run_compiler.rkt <source-file> | racket backend.rkt > test.asm
make
```

## Status

The compiler's functionality is currently very limited, but it is capable of
producing working 68k AmigaOS command line applications.

Current features:

    * simple integer math
    * output to console
    * supported types: int, bool, string
    * store and retrieve variables

## Roadmap, TODOs

### Language features

    * conditionals
    * local bindings
    * lambdas
    * list functions
    * loop constructs ?

### OS support

    * UI integration
    * graphics
    * IO

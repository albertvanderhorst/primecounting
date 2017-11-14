\ $Id: eratosthenes.frt,v 1.3 2015/01/31 18:45:53 albert Exp $
\ Copyright (2008): Albert van der Horst {by GNU Public License

\ projecteuler.net Problem 196 30 May 2008

NAMESPACE eratosthenes

WANT ALIAS REALLOC INLINING

eratosthenes DEFINITIONS

\ -------------------------------------------------------------
DATA primes     \ to be realloced.
0 CONSTANT psize

\ for INDEX return 1 if prime else 0.
:I prime?    primes + C@ ;

\ Eliminate all multiples of P from the sieve starting at START
\ over LENGTH
:I eliminate
    >R
    BEGIN DUP R@ < WHILE
          0 OVER primes +  C!
          OVER +
    REPEAT
    2DROP RDROP ;

: era
     primes psize 1 FILL
     0 primes C!         \ 0 is not a prime.
     0 primes 1+ C!      \ 1 is not a prime.
     psize 2 DO
         I I * psize > IF LEAVE THEN
         primes I + C@ IF
           I   I 2 *   psize   eliminate
        THEN
     LOOP ;

\ Initialise this module with a SIZE, for how many primes.
\ The 1+ is such that SIZE itself can be used with prime?
: init-era    1+ 'psize >DFA !   'primes psize REALLOC
   era ;


'prime?
  'init-era
    PREVIOUS DEFINITIONS
  ALIAS init-era
ALIAS prime?

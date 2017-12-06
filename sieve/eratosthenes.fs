\ eratosthenes.fs
\ Copyright (2017): Albert van der Horst (by GNU Public License)

\ Non standard words wanted:
WANT ALIAS

' VALUE ALIAS DATA      \ Whenever it is a pointer into the dictionary

\ -------------------------------------------------------------
0 DATA primes     \ to be realloced.
0 VALUE psize     \ to be specified.

\ for INDEX return 1 if prime else 0.
: prime?    primes + C@ ;

\ Eliminate all multiples of P from the sieve starting at START
\ over LENGTH
: eliminate
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
: init-era    1+ TO psize       HERE TO primes   psize ALLOT
   era ;

\ Count the primes up to SIZE, return the COUNT.
: pi   0 SWAP 1+ 1 DO I prime? + LOOP ;

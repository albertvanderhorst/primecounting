#!./lina8G -s
\ $Id: r10.frt,v 1.10 2017/10/30 19:13:12 albert Exp albert $
\ Copyright (2012): Albert van der Horst {by GNU Public License}

\ A prime counting program using Lucy Hedgehog's technique of
\ tables for primes under n/i

WANT SQRT :I NOT -scripting- .FORMAT
: \D POSTPONE \ ; IMMEDIATE
\ : \D ; IMMEDIATE
:I CELL  0 CELL+ ;
:I <=  > NOT ;
:I >=  < NOT ;
:I DSSWAP ROT ROT ;

\ For  x  return its cube  root  .
: CUBRT  DUP >R
      DUP BEGIN 2/ 2/ 2/ DUP WHILE SWAP 2/ 2/  SWAP REPEAT DROP
      BEGIN R@ OVER / OVER / OVER + OVER +   3 /  2DUP > WHILE
       NIP REPEAT   R> 2DROP ;

\ 100 CONSTANT n
\ 1000 CONSTANT n
\ 10000 CONSTANT n
1 ARG[] EVALUATE CONSTANT n
n SQRT CONSTANT r    \ Must be exactly floor(sqrt(n))
r SQRT CONSTANT r4   \ Must be exactly floor(fourth root(n))
n CUBRT CONSTANT r3

DATA S/I
_ ,     \ dummy entry to get a one-based array.
r 1+ 1 DO n I / 1- ( don't count 1 ) , LOOP
    HERE S/I - CELL / CONSTANT #S/I
\ For  i  return the  count   for would be primes under n/i.
:I S/I[]  CELLS S/I + ;

\ If n is a perfect square index r will be present in both tables.
\ This is needed because otherwise "r prime?" would access an
\ invalid entry.
DATA S   _ ,  r 1+ 1 DO I 1- , LOOP
    HERE S - CELL / CONSTANT #S

\ For  i  return the   count   for would be primes under i.
:I S[]  CELLS S + ;

:I prime?  DUP S[] @ SWAP 1- S[] @ <> ;
VARIABLE #p    \ Number of primes already treated.

\ For  p  collect its dismissals into the N/1 entry.
:I collect
\D      DUP >R
       S/I[] @ #p @ - NEGATE \ &* EMIT SPACE DUP . OVER . ^M EMIT
\D     DUP R> "At final(1) in the S/I array(h) for prime %d  correct by %d %n" .FORMAT
       1 S/I[] +! ;
\ Remove multiples of  p  from `S/I not needing S.
\ Leave  position  where to continue.
: sieveh
       DUP collect
       DUP BEGIN                                \ p i
       2DUP *                                  \ p i  i.p
\        .S
       DUP #S/I < WHILE                        \ p i  i.p
       S/I[] @ #p @ - NEGATE                   \ p i cor
\D      DUP >R
        OVER S/I[] +!       \ p i
\D     2DUP R> DSSWAP "At index %d  in the S/I array(h) for prime %d  correct by %d %n" .FORMAT
       1+                                      \ p i+1
       REPEAT
       DROP NIP ;

\ Starting at  pos  in S/I  remove multiples of  p  from `S/I
\ where the subtraction comes from `S.
\ The loop must stop at N/I < P^2 or I > N/P^2
     VARIABLE temp
:I (sievehl)
    ?DO                \ p  ( I is an index in `S/I )
        n I / OVER /               \ p  i'  (index in `S)
        S[] @ #p @ - NEGATE
\D      DUP temp !
        I S/I[] +!  \ p
\D      temp @ OVER I " At index %d  in the S/I array for prime %d  correct by %d %n" .FORMAT
     LOOP ;

: sievehl   \ &+ EMIT ^M EMIT
    SWAP #S/I SWAP ( Upper,lower limit ) (sievehl) DROP ;

: sievehl-large  OVER >R  \ &+ EMIT ^M EMIT
    n OVER / OVER / 1+ R> ( Upper,lower limit ) (sievehl) DROP ;

\ Remove multiples of  p  from `S .
: sievel  >R  \ &. EMIT ^M EMIT
       #S BEGIN 1-                              \ R:p i
           DUP R@ /                             \ R:p i  i/p
       DUP R@ >= WHILE                          \ R:p i  i/p
           S[] @ #p @ - NEGATE OVER S[] +!      \ R:p i
       REPEAT                               \ R:p i-1
       2DROP RDROP ;

0 #p !
\ Do the whole sieve for  p  increment @p
: sieve-p-small   >R  R@ sieveh   R@ sievehl  R> sievel  1 #p +! ;

: sieve-p-large   DUP collect DUP sievehl-large  1 #p +! ;

: show
    #p @ "Correction: %d %n" .FORMAT
    #S 1 DO I DUP S[] @ SWAP "under %d  : %d  primes%n" .FORMAT  LOOP
    #S/I 1 DO n I / I S/I[] @ SWAP "under %d  : %d  primes%n" .FORMAT LOOP
;

: doit 0 #p !
   r4 1+ 2 ?DO !CSP  I prime? IF I sieve-p-small THEN !CSP LOOP
\D   r r3 r4 "%d  %d  %d  sqrts%n" .FORMAT
   r3 1+ r4 1+ ?DO !CSP  I prime? IF I sieve-p-large THEN !CSP LOOP
   r 1+ r3 1+ ?DO !CSP  I prime? IF I collect 1 #p +! THEN !CSP LOOP
   1 S/I[] @ n "Under %d : %d  primes%n" .FORMAT ;
doit
\D show

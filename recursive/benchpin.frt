\ FILE:      benchpin.frt
\ LANGUAGE : ISO Forth
\ TITLE : The corrected PI(N) recursion benchmark.

\ COPYRIGHT :  Albert van der Horst FIG Chapter Holland
\ This program and modified versions thereof may be distributed
\ and used freely provided:
\  1. this copyright and a www reference to the original is kept
\  2. the following line states correctly either original or modified.
\ This version is : original.
\ The original version is available at
\ http://home.hccnet.nl/a.w.m.van.der.horst/benchpin.frt


\ DESCRIPTION:
\  This (highly recursive) function calculates PI(n), i.e.
\  the number of primes less or equal to n.
\  It doesn't use a sieve, nor does it inspect numbers larger
\  than the square root of n for primeness.
\  It may be used for benchmarking, because it takes
\  considerable time for large numbers.
\  It is one of the few highly recursive algorithms that
\  actually calculate something sensible.

    -1 CONSTANT TRUE                 \ Comment out if present
    0  CONSTANT FALSE                \ Comment out if present

: \D
     POSTPONE \                       \ Comment out if debugging
; IMMEDIATE

\ ?PRIME tests whether the single precision number p is prime
\ Cases 0 1 are in fact illegal but return TRUE
: ?PRIME        ( p -- flag )
  >R
  R@ 4 U< IF R> DROP TRUE EXIT THEN       \ Prevent silly infinite loop
  R@ 1 AND 0= IF R> DROP FALSE EXIT THEN  \ Handle even numbers other than 2

  3 BEGIN
    R@ OVER /MOD SWAP
    0= IF R> DROP 2DROP FALSE EXIT THEN
    OVER < IF R> DROP DROP TRUE EXIT THEN
    2 +
    AGAIN
;

CREATE TABLE 60000 ALLOT
REQUIRE NEW-IF
60000 0 DO I ?PRIME TABLE I + C! LOOP

: ?PRIME  TABLE + C@ ;

\ N2 are the amount of numbers <= N1 that are dismissed by the prime P,
\ i.e. it is divisible by P but not by a smaller prime.
\ Requires P<=N1
: DISMISS       ( N1 P -- N2 )
\D 2DUP CR ." Dismissing " . .
   >R      R@ /
   DUP R@ < IF DROP R> DROP 1 EXIT THEN       \ Only P itself
   DUP
   R> 2 ?DO
      I ?PRIME IF
         OVER I RECURSE -
      THEN
   LOOP
   SWAP DROP
;

\ Return PI(N2) i.e. the number of primes <= N1
: PI            ( N1 -- N2 )
   DUP >R
   1 -        \ Exclude 1
   R@ 2 / 1-   \ Multiples of 2 except 2 itself
   -           \ Exclude them
   3 BEGIN
   DUP DUP * R@ > 0= WHILE
      DUP ?PRIME IF
\D       CR DUP . ." IS PRIME"
         R@ OVER DISMISS 1-   \ Dismissals, except the prime itself.
         SWAP >R    -    R>   \ Exclude them
      THEN
   2 + REPEAT DROP
   R> DROP
;

\ ---  TEST: doesn't belong to benchmark proper ---

VARIABLE OLD
\ Find any errors in PI for arguments < N .
: FINDPROBLEMS        ( N -- )
   1 OLD !
   3 DO
      I PI DUP OLD @ - 0= 0=
      I ?PRIME 0= 0= <> IF
         DROP ." Wrong : " I . LEAVE
\D    ELSE
\D       ." Okay  : " I .        \ Comment out as desired.
      THEN
      OLD !
\D    .S
   LOOP
;

: MAIN 1 ARG[] EVALUATE PI . CR ;

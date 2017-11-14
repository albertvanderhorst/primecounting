( Copyright{2005}: Albert van der Horst, HCC FIG Holland by GNU Public License)
( $Id: yapcp.frt,v 1.16 2005/04/03 13:17:07 albert Exp albert $ )

\ This program is an improved version of my prime counting benchmark,
\ using techniques from the world record holding program for counting
\ primes by Deleglise e.a., but it is O(N) not O(N^2/3).
\ See also :
\ http://home.hccnet.nl/a.w.m.van.der.horst/benchpin.frt
\ http://home.hccnet.nl/a.w.m.van.der.horst/pipi.pas   (More explanation).
\ The number of primes less or equal than n is a function denoted
\ by the greek letter pi, hence the names.

: \D
      POSTPONE \                       \ Comment out if debugging
; IMMEDIATE

WANT DEFER
WANT RDROP
WANT NIP
WANT NEW-IF
WANT BIN-SEARCH
WANT ALIASED
WANT SQRT

: ALIASED 3 CELLS MOVE ;
\D WANT DO-DEBUG

\ ---------------------------------------------------
1 8 CELLS 1- LSHIFT 1- CONSTANT MAX-INT

\ For N: "it IS prime".
\ Cases 0 1 are in fact illegal but return true.
: ?PRIME    DUP 2 DO
                DUP I /MOD
                I <  IF 2DROP -1 LEAVE THEN
                0= IF DROP  0 LEAVE THEN
            LOOP ;

\ With this sqrt(MAX-INT) we can handle all positive numbers.
MAX-INT SQRT 1+ CONSTANT MAX-TABLE
10,000,000 CONSTANT MAX-TABLE
"MAX-TABLE is:" TYPE MAX-TABLE . CR

\ You may tweek MAX-TABLE by hand, no harm done.
\D 1000 CONSTANT MAX-TABLE       \ Trim table during testing, or for 64 bit systems.

\ Makes 2 the first prime, and 1 the zero-th ...
\ For 32 bit Forth's we need (7/5)*0x8000/15.5*.7=4K400 cells (or 16 bit words).
\ For 64 bits we need (7/5)*0x8000,0000/31.5*.7 140M cells (or 32 bit words).
CREATE PRIMES 1 BEGIN DUP ?PRIME IF DUP , THEN 1+ DUP MAX-TABLE = UNTIL DROP

HERE PRIMES - 0 CELL+ / CONSTANT PIhalf   \ Number of primes in table.

\ For I return the ith prime NUMBER.
: PRIME[]   CELLS PRIMES + @ ;

\ For N return the NUMBER of primes less than or equal to it.
\ Use this only for small numbers < ``MAX-TABLE''
    VARIABLE LIMIT              \ Auxiliary for BIN-SEARCH
    : p< PRIME[] LIMIT @ > 0= ;    \ Auxiliary for BIN-SEARCH
: PI(small)   LIMIT !   0 PIhalf 'p< BIN-SEARCH 1- ;

\ For N return the NUMBER of primes less than or equal to its square root.
    VARIABLE LIMIT              \ Auxiliary for BIN-SEARCH
    : p< PRIME[] DUP * LIMIT @ > 0= ;    \ Auxiliary for BIN-SEARCH
: PI(sqrt)   LIMIT !   0 PIhalf 'p< BIN-SEARCH 1- ;

\ For M and N return their GREATEST COMMON DIVIDER
: GCD   BEGIN 2DUP MOD DUP WHILE ROT DROP REPEAT DROP NIP ;

\ Tabulate the result of sieving the first 6 primes
2 3 * 5 * 7 * 11 * 13 * CONSTANT P6
CREATE TABLE6   0 ,   0 P6 1 DO P6 I GCD 1 = IF 1+ THEN DUP , LOOP
CONSTANT MULT6

\ For N return the NUMBER of 6-primes less or equal.
\ A 6-prime is not divisible by any of the first 6 primes:
\  so 1 is counted as a 6-prime.
\  and the 6 primes themselves are not counted.
\ This results in a correction of 5 + for use as a prime counter.
: phi(.,6)  P6 /MOD   MULT6 *   SWAP   CELLS TABLE6 + @   + ;

CREATE PI%              \ Forward declaration
CREATE DISMISS%

\ (N1 P -- N2 )
\ N2 are the amount of numbers <= N1 that are dismissed by the prime P,
\ i.e. it is divisible by P but not by a smaller prime.
\ Compared to Deleglise : DISMISS(N,P)= phi(N,Psubn) - phi(N,Psubn-1)
\ Requires P<=N1
: DISMISS   >R          \ Use R@ as a local, representing P.
   R@ PRIME[] /
   DUP R@ PRIME[] DUP * < IF
        PI%    R@ PRIME[] PI% -  2 +   \ 2 represents P and P^2
   ELSE
        \ Initialise loop over primes, but cut short the smallest 6.
        \ Remember: highest index will be `'R@ 1-''
        R@ 7 < IF
            DUP   R@   1
        ELSE
           DUP phi(.,6) R@   7
        THEN ?DO
             OVER I DISMISS% -
       LOOP NIP
   THEN
RDROP ;

\ For N return the NUMBER of primes less or equal.
\ Make sure phi(.,6) is not called out of range.
13 DUP * MAX-TABLE 1- > 13 AND THROW  \ Last 13 as in "bad luck".
: PI
    DUP MAX-TABLE < IF
        PI(small)
    ELSE
        DUP phi(.,6) 5 +
        OVER PI(sqrt) 1+   7   DO
            OVER I DISMISS -   1+    \ Dismiss multiples, add 1 for prime itself.
        LOOP NIP
    THEN
;

'PI 'PI% ALIASED
'DISMISS 'DISMISS% ALIASED

\ Redefine with error detection (outside of recursion).
\ Only needed if you trimmed max-table!
\ : PI   DUP MAX-TABLE DUP * > IF ." Too large!  " 13 ERROR THEN   PI ;

\ ---  TEST ---


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

: MAIN   POSTPONE ONLY    1 ARG[] EVALUATE   PI . CR ;

\ $Id: pinew.frt,v 1.6 2017/11/14 00:33:37 albert Exp albert $
\ Copyright (2012): Albert van der Horst {by GNU Public License}
\ Please observe the conventions of projecteuler.net for distributing solutions of problems

\ This program is a new prime counting benchmark,
\ in the family started with yapcp .
\ For 64 bit systems, the tabulation refinement made by Anton Ertl
\ resulting in sbpcp and sbpcpd is less essential, and this simpler
\ program is not much slower.

\ See also :
\ http://home.hccnet.nl/a.w.m.van.der.horst/benchpin.frt
\ http://home.hccnet.nl/a.w.m.van.der.horst/pipi.pas   (More explanation).
\ The number of primes less or equal than n is a function denoted
\ by the greek letter pi, hence the names.
\ test case : 10**11 4118054813   ca 5 seconds

: \D
       POSTPONE \                       \ Comment out if debugging
; IMMEDIATE

WANT <=
WANT GCD
WANT TRI
WANT SQRT
WANT :F
WANT RDROP
WANT -scripting-
WANT ARG[]
WANT .FORMAT
WANT REALLOT

\ ---------------------- auxiliary -------------------------------
:I R+=  R> + >R ;
:I R-=  NEGATE R+= ;
:I D- DNEGATE D+ ;
:I DSSWAP ROT ROT ;
:I SDSWAP ROT ;


\D WANT DO-DEBUG
: REALLOT ALIGN REALLOT ;

INCLUDE eratosthenes.frt

\ For P return the previous prime or 0.
\ Requires tweak in prime table!
:I prev  BEGIN 1- DUP prime? UNTIL ;

\ ------------- paritally sieved count ------------

100 CONSTANT SIZE
100 CONSTANT SSIZE
\ You may incorporate less or more primes, and it stay working.
2 3 * 5 * 7 * 11 * 13 * CONSTANT #tab6

DATA tab-pi6       \ number of 6-primes.
VARIABLE cnt-S    \ What we get at the end.
:I s-pi6[] CELLS tab-pi6 + @ ;

: init-pi6
  'tab-pi6 0 REALLOT
  0 DUP , #tab6 1 DO I #tab6 GCD 1 = IF 1 + THEN DUP , LOOP  cnt-S !
;

\ ------------- count of primes part ----------------

VARIABLE cnt-S    \ What we get at the end.


\ Initialise `` cnt-S'' for `` #tab6 '' etries.
: init-6 0 #tab6 1 DO I #tab6 GCD 1 = IF 1+ THEN LOOP   cnt-S ! ;

\ For NMOD return cnt of the 6-primes between  [M,N) where M is a
\ multiple of #tab6.
:I tail s-pi6[] ;

\ For NSLASH  return cnt of 6-primes over [0,M) where M is a
\ multiple of #tab6.
:I bulk cnt-S @ * ;

\ cnt, except for multiples of 1..13. under N
: smf6()
  #tab6 /MOD          ( S:remainder-in-period, #periods )
  bulk SWAP tail + ;

DATA primes-count
:I smf[] CELLS primes-count + @ ;

: init-primes-count
    'primes-count 0 REALLOT
    0 , 0 , 0 SSIZE 1+ 2 DO I prime? IF 1 + THEN DUP , LOOP
    "Last count of primes " TYPE . CR ;

:F dismiss ;
:F pi() ;

\ N2 is the count of numbers <= N1 that are dismissed by P
\ i.e. divisible by P but not by a smaller prime.
\ P itself must not be dismissed.
\ They are one correction to smf(N1).
:R dismiss       ( N1 P -- N2 )
\D 2DUP CR ." Dismissing " . .
   SWAP OVER /
   2DUP > IF DROP ELSE
   OVER SQ OVER > IF OVER >R pi() R> 1- pi() - ELSE
        OVER 13 > IF
           DUP smf6() 1- >R   \ 1- : Not the prime itself
           \ For LIMIT and N correct the item on the return stack for all p<N
           OVER BEGIN prev DUP 13 > WHILE 2DUP dismiss 1+ R-= REPEAT 2DROP
           R>
       ELSE
           DUP 1- >R       \ 1- : Not the prime itself
           \ For LIMIT and N correct the item on the return stack for all p<N
           OVER BEGIN prev DUP WHILE 2DUP dismiss 1+ R-= REPEAT 2DROP
           R>
      THEN
   THEN THEN
   NIP ;

\ For N1 return pi(N1)=cnt(p<=N1:mf(p))
\ E.g the count of all primes <= N1
:R pi()  ( N1 -- N2 )
\D DUP CR ." Pi for " .
   DUP SSIZE < IF smf[] ELSE
       DUP 1- >R DUP SQRT 1+
        \ For LIMIT and N correct the item on the stack for all p<N
        BEGIN prev DUP WHILE 2DUP dismiss R-= REPEAT 2DROP
       R>
   THEN
;

\ --------------------------------------------------
\ This results in 5/8 instead of 2/3   .625 instead of .66
\ I'm sure gawd fill forgive us.
: init-size    'SIZE >DFA !  SIZE SQRT DUP SQRT SQRT * 'SSIZE  >DFA ! ;


: init
    init-pi6
    SSIZE init-era  [ eratosthenes ] -1 primes C! ." era ready " [ PREVIOUS ]
    init-6 ." other sixes"
    init-primes-count
;

: doit 1 ARG[] EVALUATE init-size init
    ." under SIZE: " SIZE . ." with SSIZE: " SSIZE .
    SIZE DUP pi()
    "%n %n There are %d  primes under %d %n" .FORMAT
    ( show-accumulator ) ;

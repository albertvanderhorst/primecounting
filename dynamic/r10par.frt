#!./lina8G -s
\ $Id: r10par.frt,v 1.4 2017/10/31 00:08:04 albert Exp albert $
\ Copyright (2012): Albert van der Horst {by GNU Public License}

\ A prime counting program using Lucy Hedgehog's technique of
\ tables for primes under n/i

WANT SQRT :I NOT -scripting- .FORMAT THREAD-PET TRUE
DECIMAL
:I CELL  0 CELL+ ;
:I <=  > NOT ;
:I >=  < NOT ;

: \D POSTPONE \ ;  IMMEDIATE
\ : \D ;
4096 THREAD-PET auxcpu

\ 100 CONSTANT n
\ 1000 CONSTANT n
\ 10000 CONSTANT n
1 ARG[] EVALUATE CONSTANT n
n SQRT CONSTANT r    \ Must be exactly floor(sqrt(n))

DATA S/I
_ ,     \ dummy entry to get a one-based array.
r 1+ 1 DO n I / 1- ( don't count 1 ) , LOOP
    HERE S/I - CELL / CONSTANT #S/I
\ For  i  return the  count   for would be primes under n/i.
:I S/I[]  CELLS S/I + ;

DATA S   _ ,  r 1+ 1 DO I 1- , LOOP
    HERE S - CELL / CONSTANT #S

\ For  i  return the   count   for would be primes under i.
:I S[]  CELLS S + ;

:I prime?  DUP S[] @ SWAP 1- S[] @ <> ;
VARIABLE #p    \ Number of primes already treated.

\ Remove multiples of  p  from `S/I not needing S.
\ Leave  position  where to continue.
: sieveh
       1 BEGIN                                \ p i
       2DUP *                                  \ p i  i.p
\        .S
       DUP #S/I < WHILE                        \ p i  i.p
       S/I[] @ #p @ - NEGATE OVER S/I[] +!       \ p i
       1+                                      \ p i+1
       REPEAT
       DROP NIP ;
: sieveh
       DUP S/I[] @ #p @ - NEGATE \ &* EMIT SPACE DUP . OVER . ^M EMIT
       1 S/I[] +!
       DUP BEGIN                                \ p i
       2DUP *                                  \ p i  i.p
\        .S
       DUP #S/I < WHILE                        \ p i  i.p
       S/I[] @ #p @ - NEGATE OVER S/I[] +!       \ p i
       1+                                      \ p i+1
       REPEAT
       DROP NIP ;

\ Starting at  pos  in S/I  remove multiples of  p  from `S/I
\ where the subtraction comes from `S.
\ The loop must stop at N/I < P^2 or I > N/P^2
     VARIABLE temp
: sievehl   OVER >R  \ &+ EMIT ^M EMIT
    n OVER / OVER / 1+ #S/I MIN  R> \ Upper limit, lower limit
    ?DO                \ p  ( I is an index in `S/I )
        n I / OVER /               \ p  i'  (index in `S)
        S[] @ #p @ - NEGATE I S/I[] +!  \ p
     LOOP DROP ;

    VARIABLE high
    VARIABLE middle
    VARIABLE low
    VARIABLE n/p
    VARIABLE run    FALSE run !

: sievehl-I
   BEGIN !CSP
      BEGIN run @ UNTIL
\      high @ low @
\    middle @ low @ "%d  %d %n" FORMAT ETYPE
\D    &L EMIT SPACE low ? middle ? CR
    middle @ low @
    ?DO                \ ( I is an index in `S/I )
        n/p @ I /      \ i'  (index in `S)
        S[] @ #p @ - NEGATE I S/I[] +!  \
     LOOP
     FALSE run !
   ?CSP AGAIN
;

    'sievehl-I auxcpu   \ Have it runpermanently

: sievehl-II
\D    &H EMIT SPACE middle ? high ? CR
    high @ middle @
    ?DO                \ ( I is an index in `S/I )
        n/p @ I /      \ i'  (index in `S)
        S[] @ #p @ - NEGATE I S/I[] +!  \
     LOOP ;
: sievehl   OVER low ! \ &+ EMIT ^M EMIT
    n OVER / OVER / 1+ #S/I MIN  high ! \ Upper limit, lower limit
    low @ high @ + 2/ middle !
\D     low ? middle ?    high ? CR
    n SWAP / n/p !
    TRUE  run  !   \ Start sievehl-I
    sievehl-II
    BEGIN run @ WHILE REPEAT
   DROP ;

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
: sieve-p   >R  R@ sieveh   R@ sievehl  R> sievel  1 #p +! ;

: show
    #p @ "Correction: %d %n" .FORMAT
    #S 1 DO I DUP S[] @ SWAP "under %d  : %d  primes%n" .FORMAT  LOOP
    #S/I 1 DO n I / I S/I[] @ SWAP "under %d  : %d  primes%n" .FORMAT LOOP
;

: doit 0 #p !
   r 1+ 2 DO !CSP I prime? IF I sieve-p THEN ?CSP LOOP
   1 S/I[] @ n "Under %d : %d  primes%n" .FORMAT ;

doit
'auxcpu KILL-PET

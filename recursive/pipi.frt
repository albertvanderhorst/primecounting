\ FILE:      pipi.frt
\ LANGUAGE : ANSI Forth
\ COPYRIGHT :  Albert van der Horst FIG Chapter Holland
\ This program may be copied and distributed freely as is.
\ Expressly forbidden is
\ 1. gratitious de-ansification, like use of non-standard comment symbols
\ 2. lower casing
\ 3. comment stripping
\ 4. addition of system-specific words like source control tools such as
\     MARKER look-alikes

\ ?Prime tests whether the single precision number p is prime
\ Cases 0 1 are in fact illegal but return TRUE
: ?Prime        ( p -- flag )
  LOCAL P
  P 4 U< IF TRUE EXIT THEN       \ Prevent silly infinite loop
  P 1 AND 0= IF FALSE EXIT THEN  \ Handle even numbers ither than 2

  P 3 DO
    P I /MOD
    I < IF DROP TRUE LEAVE THEN
    0= IF FALSE LEAVE THEN
    2 +LOOP
;

\ N3 are the amount of numbers <= N1 that are dismissed by the prime N2,
\ i.e. it is divisible by N2 but by not smaller prime.
\ Requires N2<=N1
: DISMISS       ( N1 N2 -- N3 )
\     2DUP CR ." Dismissing " . .
    LOCAL P    LOCAL N
    N P /      LOCAL N'
    N' P < IF 1 EXIT THEN       \ Only P itself
    N'
    P 2 ?DO
       I ?Prime IF
          N' I RECURSE -
       THEN
    LOOP
;

\ Return PI(N2) i.e. the number of primes <= N2
: PI            ( N1 -- N2 )
   LOCAL N
   N 1 -        \ Exclude 1
   N 2 / -      \ Exclude multiples of 2
   1 +          \ Except 2 itself
   N 3 DO       \ Upper limit never reached
      I I * N > IF LEAVE THEN
      I ?Prime IF
         N I DISMISS - 1 +
      THEN
   2 +LOOP
;

: findproblems
  1 LOCAL OLD
  0 3 DO                \ In fact "infinite" loop
     I PI DUP OLD - 0= 0=
     I ?Prime 0= 0= <> IF DROP ." Wrong : " I . LEAVE THEN
     TO OLD
\      .S
  LOOP
;

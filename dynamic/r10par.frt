#!./lina8G -s
\ $Id: r10par.frt,v 1.14 2017/11/22 01:13:46 albert Exp $
\ Copyright (2012): Albert van der Horst {by GNU Public License}

\ A prime counting program using Lucy Hedgehog's technique of
\ tables for primes under n/i
\ So it calculates pi(n) for the variable `n .

ARGC 1 = IF
"Usage : r10par.frt [-p #proc] N
   Prints test output and then pi(N): the number of primes up till N.
Require lina8G in the current directory. You may need to do
    lina64 -g 8000 lina8G
with lina64 in the path
" TYPE BYE THEN

WANT SQRT :I NOT -scripting- .FORMAT THREAD-PET TRUE $=
DECIMAL
:I CELL  0 CELL+ ;

: \D
\          POSTPONE \      \ Comment out for debug
;  IMMEDIATE
   'R# ALIAS ME         \ Identifies the proces currently running.
2  1 ARG[] "-p" $= IF SHIFT-ARGS 1 ARG[] EVALUATE NIP SHIFT-ARGS THEN
  CONSTANT #PROC

\ We can't comma the latest definitions, because THREADS as well as the
\ generation of definitions move HERE.
#PROC 1+ 2 ?DO   I ME !   I "4096 THREAD-PET auxcpu%d" FORMAT&EVAL   LOOP
\ main is already running. No need for an extra thread
1 ME !

\ Now we can comma them into an area.
DATA pids   #PROC 1+ 2 ?DO I " 'auxcpu%d " FORMAT&EVAL ,   LOOP

: pid[] 2 - CELLS pids + ;

\ Killing aux processes, only needed in an emergency.
: kill-all   #PROC 1+ 2 ?DO I pid[] @ KILL-PET  LOOP ;

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

\ Collect the result for  p  of n/p into n/1.
\ Once p is above the cube root, this remains the only correction to be
\ made.
:I collect-one
       S/I[] @ #p @ - NEGATE \ &* EMIT SPACE DUP . OVER . ^M EMIT
       1 S/I[] +!
;
\ Remove multiples of  p  from `S/I not needing `S.
\ Leave  position  where to continue.
: sieveh
       DUP collect-one
       \ If we'd start at one the above could be left out
       \ but we would calculate pi(n/2) pi(n/3) etc unneeded.
       DUP BEGIN                                \ p i
       2DUP *                                  \ p i  i.p
\        .S
       DUP #S/I < WHILE                        \ p i  i.p
       S/I[] @ #p @ - NEGATE OVER S/I[] +!       \ p i
       1+                                      \ p i+1
       REPEAT
       DROP NIP ;

   VARIABLE high
   VARIABLE low
   \ No need to pass the prime, n/p is sufficient.
   VARIABLE n/p
   VARIABLE turn    0 turn !

\ From a range in `high `low  select the range   high  low  to be run by me.
: me-select
     high @ ME @         2DUP 1- * >R * R>      \ high weighted by ME
     low  @ #PROC ME @ - 2DUP 1+ * >R * R>      \ low weighted by #PROC - ME
     ROT + #PROC /       >R + #PROC / R> ;

VARIABLE ready  \ If set processes are to stop.
\ Wait until I must run again
:I wait  BEGIN turn @ ME @ = UNTIL ;
\ Signal next higher process to run
:I signalup  1 turn +! ;
\ Signal next lower process to run
:I signaldown  -1 turn +! ;

\ See `sievehl
:I (sievehl)
    me-select
    ?DO                \ ( I is an index in `S/I )
        n/p @ I /      \ i'  (index in `S)
        S[] @ #p @ - NEGATE I S/I[] +!  \
     LOOP ;

\ See `sievehl
\ Restart of the loop is controlled by the main process.
: sievehl-I
   BEGIN
    wait   ME @ #PROC <> IF signalup THEN
    ready @ IF EXIT THEN
    (sievehl)
    wait signaldown
   AGAIN
;

\ All those processes run and eat cycles until killed or ready.
: start-all   #PROC 1+ 2 ?DO 'sievehl-I I pid[] @ EXECUTE  LOOP ;

\ This one run by the main process. No exit here.
: sievehl-II
    wait   ME @ #PROC <> IF signalup THEN
    (sievehl)
    wait signaldown
;

\ Starting at  pos  in `S/I remove multiples of  p  from `S/I
\ where the subtraction comes from `S.
\ The loop must stop at N/I < P^2 or I > N/P^2
: sievehl
    \ Upper limit, lower limit n/p in variables in behalf of other processes
    SWAP low ! \ &+ EMIT ^M EMIT
    n OVER / OVER / 1+ #S/I MIN  high !
\D DUP . &: EMIT SPACE    low ? high ? ^M EMIT
    n SWAP / n/p !
    signalup
    \ `turn is one, I'm up
    sievehl-II
    \ I'm finished, `turn is zero again.
;

\ Remove multiples of  p  from `S .
: sievel  >R  \ &. EMIT ^M EMIT
       #S BEGIN 1-                              \ R:p i
           DUP R@ /                             \ R:p i  i/p
       DUP R@ >= WHILE                          \ R:p i  i/p
           S[] @ #p @ - NEGATE OVER S[] +!      \ R:p i
       REPEAT                               \ R:p i-1
       2DROP RDROP ;

\ Do the whole sieve for  p  increment #p
: sieve-p   >R  R@ sieveh   R@ sievehl  R> sievel  1 #p +! ;

\ Only update element 1 of `S/I for  p  .
: sieve-nomore-p   collect-one   1 #p +! ;

\ Do updates to the database for all primes.
: all-primes
   FALSE ready !   0 turn !  start-all
   0 #p !   2
   BEGIN DUP prime? IF DUP sieve-p THEN 1+   high @ low @ < UNTIL
   TRUE ready ! signalup signalup   \ This kills all processes by suicide.
   r 1+ SWAP DO I prime? IF I sieve-nomore-p THEN LOOP
;

: show
    #p @ "Correction: %d %n" .FORMAT
    #S 1 DO I DUP S[] @ SWAP "under %d  : %d  primes%n" .FORMAT  LOOP
    #S/I 1 DO n I / I S/I[] @ SWAP "under %d  : %d  primes%n" .FORMAT LOOP
;

: doit
   all-primes
\   show
   1 S/I[] @ n "Under %d : %d  primes%n" .FORMAT
   ;

doit

#!./lina8G -s
\ $Id: q10.frt,v 1.3 2017/10/17 18:49:40 albert Exp albert $
\ Copyright (2012): Albert van der Horst {by GNU Public License}
\ Usage q10.frt <N>
\ print the prime numbers under N.

\ # Lucy hedgehog's trick.
\ # S(n) is the sum of primes
\ # S(n) is a property
WANT SQRT :I SQ FORMAT

1 ARG[] EVALUATE CONSTANT n
n SQRT CONSTANT r


DATA V   r 1+ 1 DO n I / , LOOP
         n r / BEGIN 1- DUP WHILE DUP , REPEAT DROP
HERE V - 0 CELL+ / CONSTANT #SV

:I INDEX   DUP r < IF #SV SWAP - ELSE n SWAP / 1- THEN ;
:I V[]  CELLS V + ;
DATA S   #SV 0 DO I V[] @ 1- , LOOP
:I S[]  INDEX CELLS S + ;

\ From all counts remove multiples of  p .
:I v I V[] @ ;
     VARIABLE cor
: remove-p  DUP . ^M EMIT
        #SV 0 DO
           v OVER SQ < IF LEAVE THEN
           v OVER / S[] @   cor @ - NEGATE    v S[] +!
        LOOP
        DROP 1 cor +! ;

: fill-V
    0 cor !
    r 1+ 2 DO
       I S[] @   I 1- S[] @ > IF I remove-p THEN
    LOOP ;

\  THEN
\ "----------------- V -----------------" TYPE CR
\ #SV 0 DO I . I V[] ? .S LOOP
\ "----------------- S -----------------" TYPE CR
\ r 1 DO I . I S[] ? .S LOOP
\ r 1+ 1 DO n I .S / DUP . S[] ? LOOP
fill-V
\ "----------------- S -----------------" TYPE CR
\ r 1 DO I . I S[] ? .S LOOP
\ r 1+ 1 DO n I .S / DUP . S[] ? LOOP

n    DUP S[] @
"And we have %d  primes uptil %d %n " .FORMAT
BYE

# Lucy hedgehog's trick.
# S(n) is the sum of primes
# S(n) is a property
def P10(n):
    r = int(n**0.5)
    assert r*r <= n and (r+1)**2 > n
    V = [n//i for i in range(1,r+1)]
    V += list(range(V[-1]-1,0,-1))
    S = {i:i-1 for i in V}
    for p in range(2,r+1):
        if S[p] > S[p-1]:  # p is prime
            sp = S[p-1]  # sum of primes smaller than p
            for v in V:
                if v < p*p: break
                S[v] -= (S[v//p] - sp)

    return S[n]

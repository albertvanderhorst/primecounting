\ Counting primes by sieving.
\ Compile by:
\   [ciforth] -c pi.frt
\ Usage:
\    pi 10,000
\    pi '10 4 **'

"eratosthenes.frt" INCLUDED

: doit
   1 ARG[] EVALUATE
   DUP init-era
   DUP pi . CR ;

\ Improved Slightly Better Prime Counting Program.  It is derived from YAPCP
\ posted by Albert van der Horst <albert@spenarnc.xs4all.nl>
\ Improvements by Albert van der Horst and Anton Ertl

\ Usage (after loading):
\ 100000 pi . \ counts and prints the number of primes <=100000.

\ Improvements:

\ - Compiles on Gforth (but some Gforthisms were introduced)
\   If you don't like the Gforthisms, try
\     http://www.complang.tuwien.ac.at/forth/programs/sbpcp-1.0.fs
\     (slower, but as non-standard as yapcp)
\ - Is usable on 64-bit systems
\ - It is faster, because it uses direct lookup tables instead of
\   binary search. Speedup factor 2.5-3 for the ranges I tested.
\ - added stack effect comments and other code cleanup.
\ - TABLE6 to short cut the dismissal of primes <=13 (speedup factor 5)
\ - table size for high speed up to TABLE-LIMIT (for limiting RAM consumption)
\ - table compression (for factor 4-5 bigger tables with the same RAM)

\ This program uses techniques from the world record holding program
\ for counting primes by Deleglise e.a., but it is O(N) not O(N^2/3).
\ See also :
\ http://home.hccnet.nl/a.w.m.van.der.horst/benchpin.frt
\ http://home.hccnet.nl/a.w.m.van.der.horst/pipi.pas   (More explanation).

\  For checking correctness: http://primes.utm.edu/howmany.html

\  The program uses the following words
\  from CORE :
\  environment? drop : ; 2/ cells fill i + c@ IF 2* dup BEGIN < WHILE
\  swap c! over REPEAT 2drop THEN LOOP , and 0= rshift ! - here 2dup
\  cell+ / 1+ @ mod rot * Constant DO = Create execute /mod >r r@ ELSE
\  ' min max > 1- allot cr  <# # #> hold
\  from CORE-EXT :
\  Value ?DO nip :noname .r
\  from BLOCK-EXT :
\  \
\  from EXCEPTION :
\  throw
\  from FILE :
\  S" (
\  from LOCAL :
\  from MEMORY :
\  allocate free
\  from non-ANS :
\  { W: -- } Defer rdrop IS

s" X:deferred" environment? drop \ ask for deferred words

\ the table size will not grow beyond the following limit unless necessary
\ set it as required for your RAM size
100000000 value table-limit \ about 93MB with 64-bit cells
                            \ table-limit 2/ -> pi-lo-table, + some for primes

\ For N return FLOOR of the square root of n.
VARIABLE seed   1 seed !
\ While calculating decreasing roots, the seed can be kept.
\ It is favourable if the roots are near each other.

: SQRT  DUP IF
   >R seed @
   R@ OVER / + 2/
   BEGIN R@ OVER / 2DUP > WHILE + 2/ REPEAT   seed ! RDROP
THEN ;

\ this is adapted from the Byte Sieve

: sieve { u -- addr }
    \ compute the primes up to U, in the form of an array of U/2 cells
    \ at ADDR, each containing -1 if the number is prime and 0 if it is not
    u 2/ allocate throw { flags }
    flags u 2/ 1 fill
    u sqrt 2/ 0 ?do
        flags i + c@ if
            i 2* 3 + dup i + begin ( prime index )
                dup u 2/ < while
                    dup flags + 0 swap c! over +
            repeat
            2drop
        then
    loop
    flags ;

-1 value max-table  \ limit for table lookup
0 value primes      \ lookup table
0 value pi-lo-table \ table for small pi lookups, offset since last hi entry
0 value pi-hi-table \ table for small pi lookups, entries for 1024|(N-3)
-1 value PIhalf     \ number of primes in lookup table

: sieve-to-primes { addr u -- }
    \ take a sieve at addr with u elements, and generate a primes
    \ table HERE from it
    1 , 2 ,
    u 0 ?do
        addr i + c@ if
            i 2* 3 + ,
        then
    loop ;

\ our pi-table has a funny format (for more compact storage):
\ for every odd number N there's a byte, containing pi(N)-pi((N-3)&~$3ff)
\ for every N (where N mod 1024 = 3), theres a cell containing pi(N)
\ so you get pi(N)=pi_hi((N-3)&~$3ff)+pi_lo(N) (see pi(small)).

: sieve-to-pi { addr u -- }
    \ take a sieve with u elements and convert it to a pi-table
    1 { lastbase } 1 u 0 ?do
        i addr + c@ +
        i $1ff and 0= if \ i is already divided by 2
            dup to lastbase
            dup i 9 rshift cells pi-hi-table + !
        then
        dup lastbase - i addr + c!
    loop
    drop ;

: make-tables ( n -- )
    \ set up primes, pi-table etc.
    to max-table
    here to primes
    max-table sieve to pi-lo-table
    pi-lo-table max-table 2/ 2dup sieve-to-primes \ a little too big
    here primes - 0 cell+ / to PIhalf
    max-table 10 rshift 1+ cells allocate throw to pi-hi-table
    sieve-to-pi ;

\ For I return the ith prime NUMBER.
: PRIME[] ( n -- nth-prime )
    CELLS PRIMES + @ ;

: pi(small) ( n -- primes )
    \ PRIMES is the number of primes <= n; works for 2<n<=max-table
    3 - dup 10 rshift cells pi-hi-table + @
    swap 2/ pi-lo-table + c@ + ;

: pi(sqrt) ( n -- primes )
    \ PRIMES is the number of primes <= sqrt(n); works for 3<=sqrt(n)<=max-table
    sqrt pi(small) ;


: GCD ( m n -- gcd )
    \ For M and N return their GREATEST COMMON DIVIDER
    BEGIN 2DUP MOD DUP WHILE ROT DROP REPEAT DROP NIP ;

\ Tabulate the result of sieving the first 6 primes
2 3 * 5 * 7 * 11 * 13 * CONSTANT P6
:NONAME ( -- n )
    0 P6 1 DO P6 I GCD 1 = IF 1+ THEN DUP , LOOP ;
CREATE TABLE6   0 ,   EXECUTE
CONSTANT MULT6

\ A 6-prime is not divisible by any of the first 6 primes:
\  so 1 is counted as a 6-prime.
\  and the 6 primes themselves are not counted.
\ This results in a correction of 5 + for use as a prime counter.
: phi(.,6) ( n -- number )
    \ For N return the NUMBER of 6-primes less or equal.
    P6 /MOD   MULT6 *   SWAP   CELLS TABLE6 + @   + ;

\ Forward declarations
DEFER PI%      ( n -- primes )
DEFER DISMISS% ( N1 IP -- N2 )

: DISMISS ( N1 IP -- N2 )
    \ N2 are the amount of numbers <= N1 that are dismissed by the prime IP,
    \ i.e. it is divisible by PRIMES[IP] but not by a smaller prime.
    \ Compared to Deleglise : DISMISS(N,Psubn)= phi(N,Psubn) - phi(N,Psubn-1)
    \ Requires P<=N1
    >R          \ Use R@ as a local, representing IP.
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

: PI ( n -- primes )
    \ PRIMES is the number of primes <= n;
    DUP MAX-TABLE < IF
        PI(small)
    ELSE
        DUP phi(.,6) 5 +   \ N PItobe
        OVER PI(sqrt) 1+   7   DO
            OVER I DISMISS -   1+    \ Dismiss multiples, add 1 for prime itself.
        LOOP NIP
    THEN
;

' PI IS PI%
' DISMISS IS DISMISS%

: PI ( n -- primes )
    dup sqrt over 0 d>f 0.6e f** f>d drop ( min-elems opt-elems )
    table-limit min max 12000 max make-tables
    dup 2 > if
        PI
    else
        1- \ give same result as yapcp.fs for pi(0..2)
    then
    primes here - allot
    pi-lo-table free throw
    pi-hi-table free throw ;

: test
    100000 1 do i pi i 7 .r 7 .r cr loop ;

( n -- )
    char , constant &,
: .PI PI S>D <#
    begin 999. 2over d< while # # # &, hold repeat #s
    #>
  type ;

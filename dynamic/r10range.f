\ $Id: r10range.f,v 1.2 2018/07/31 20:09:15 albert Exp albert $
\ Copyright (2012): Albert van der Horst {by GNU Public License}

\ A prime counting program inspired by Lucy Hedgehog's technique of
\ summing primes under n/i

\ Analysis: This is based on dividing [1,N] in ranges
\      (R, N/R]           (R-1,R]
\      (N/(R), N/(R-1)]    (R-2,R-1]
\      (N/(R-1), N/(R-2)]  (R-3,R-2]
\
\      (N/3, N/2]          (1,2]
\      (N/2, N/1]          (0,1]
\ Initially a range contains the count of all numbers in it.
\ Then primes are removed one by one, and counts are adjusted
\ and ranges are collapsed.
\ Note that the first entry may contain two ranges that end
\ at the same number if N/R is equal to R.
\ Then its left count is zero, which renders this harmless.
\ After eliminating some primes we get
\      (R_0, N/R_0]        (R_1,R_0]
\      (N/(R_0), N/(R_1)]  (R_2,R_1]
\      (N/(R_1), N/(R_2)]  (R_3,R_2]

\                           (Q_1,Q_2]
\      (N/Q_2, N/Q_1]       (1,Q_1]
\      (N/_1, N/1]          (0,1]
\ Note that all right ranges contain always one number, so there
\ is no need to keep a count there.
\ Ranges are collapsed until one range remains, with only primes.

\ P is elminated from  (A,B] by subtracting the count of all
\ ranges (L,H] Where A/P<H<=B/P . This must proceed from high
\ to low. Note that eliminating P from (P-1,P] results in a zero count
\ by virtue of the range (0,1] that is never changed, because it
\ contains no multiple of a prime.
\ After eliminating P the boundary N/(P*A) is no longer needed,
\ and its adjacent ranges a can be collapsed. At the right side
\ there is (P*A-1,P*A] which also has gotten a zero count.
\ This results in a quick reduction of the table size during
\ the elimination of the smallest primes.

\ After all small primes (<N^.25) are removed, only the
\ outside ranges are collapsed, and all R's and Q' will
\ be primes. Q_1 (initially 2) will always be prime.

[DEFINED] WANT [IF]
WANT :I  <=
WANT REGRESS ALIAS
\ : .S ; IMMEDIATE
[ELSE]
: REGRESS POSTPONE \ ;
: WANT POSTPONE \ ;
: :I : ;   \ To indicate this could be inlined.
0 CONSTANT _
: "--" S" --" ;
13 CONSTANT ^M
: HUH 1 ABORT" NOT IMPLEMENTED" ;
: ARG[] HUH ;
[THEN]

\ Works for 32 and 16 bit.
3 1 CELLS 4 = + CONSTANT #SHIFT
:I CELL/  #SHIFT RSHIFT ;
:I 2CELL/  #SHIFT 1+ RSHIFT ;

100 VARIABLE (N)     10 VARIABLE r
1 VARIABLE (p) \ Current prime
_ VARIABLE (tbl)     _ VARIABLE (tblnew)
_ VARIABLE (tbl-end)     _ VARIABLE (tblnew-end)
:I p (p) @ ;             :I N (N) @ ;
:I tbl (tbl) @ ;         :I tbl-end (tbl-end) @ ;
:I tblnew (tblnew) @ ;   :I tblnew-end (tblnew-end) @ ;

:I tbl[]  1- 2* CELLS tbl + ;
\ Store  range  index  at proper  position .
:I tbl!   tbl[] 2! ;
\ From  position  : range  index .
:I tbl@   tbl[] 2@ ;
\ :I * M* ABORT" OVERFLOW" ;   comment in for protection
\ Increment pointer into old or new.
:I ++ 2 CELLS + ;
:I -- 2 CELLS - ;
:I ++! 2 CELLS SWAP +! ;
:I --! -2 CELLS SWAP +! ;

\ Fields
:I CNT CELL+ @ ;         :I IX @ ;
:I CNT'  3 CELLS + @ ;   :I IX' 2 CELLS + @ ;
:I CNT+! CELL+ +! ;

VARIABLE cul    \ Cursor left, for CNT
VARIABLE cur    \ Cursor left, for IX
VARIABLE cuc    \ Cursor right, for correction, removing prime
VARIABLE cun    \ Destination cursor into `tblnew (small) or `tbl (large)

:I init-range   (N) !
     HERE (tbl) !
     0 BEGIN 1+ N OVER / 2DUP <= WHILE OVER , , REPEAT  DROP 1- r !
     HERE (tbl-end) !
     tbl
     BEGIN DUP tbl-end -- < WHILE  DUP CNT' NEGATE OVER CNT+! ++ REPEAT
     DROP
     \ Subtle: the range n/r may get a zero count!
     r @ NEGATE tbl-end -- CNT+!
    HERE (tblnew) !   r @ 1+ 2* CELLS ALLOT HERE (tblnew-end) !
;
REGRESS 100 init-range N r @  S: 100 10
REGRESS 1 tbl@ S: N 2/ 1

:I SWAP-OLD-NEW   tbl tblnew (tbl) ! (tblnew) !
    tbl-end tblnew-end (tbl-end) !  (tblnew-end) ! ;

: show  "--" TYPE CR
    tbl BEGIN DUP tbl-end < WHILE DUP IX . DUP CNT . CR ++ REPEAT DROP ;
REGRESS show S:

\ Later: value could be cached here.
VARIABLE to-be-removed  \ Multiple of p we can do without in following rounds.
:I next-cuc  cuc @ IX p * to-be-removed ! cuc ++! ;
:I init-cuc  tbl cuc ! next-cuc ;
REGRESS 2 (p) !   init-cuc  next-cuc to-be-removed @ S: 4

\ :I new-entry? CR ." BINGO " DUP . p MOD to-be-removed ? ;
:I new-entry? to-be-removed @ <> ;
:I next-cun cul ++! cul @ 2@ DUP new-entry? IF cun ++! cun @ 2!
    ELSE next-cuc DROP cun @ CNT+! THEN ;
\   If  entry1  is not where to subtract  entry2  leave  nextentry1  entry2 .
\ Otherwise do nothing.
:I ?INC?  cul @ IX' p * cur @ IX <= IF next-cun THEN  ;
REGRESS 2 (p) !   1 tbl[] cul ! 2 tbl[] cur ! cul @ ?INC? S: 1 tbl[]
\ REGRESS cul @ cun ! 4 tbl[] cur ! ?INC? cun @ S: 1 tbl[]
\ REGRESS cul @ cun ! 5 tbl[] cur ! ?INC? cun @ S: 2 tbl[]

\ From on use all left ranges downwards to remove `P
\ from left   ix  and up.
\ Leave last index to be corrected.
:I remove-p-using-left  init-cuc tbl cul !    tblnew cun !   tbl ++ cur !
    cul @ 2@ cun @ 2!
    BEGIN cur @ tbl-end < WHILE   ?INC?
        cur @  CNT NEGATE cun @ CNT+!  cur ++! REPEAT
;
REGRESS 2 (p) ! remove-p-using-left  cul @ show S: 5 tbl[]

\ We are left with the following situation:
\ All primes on the right combined with p result in a
\ hit somewhere on the left. It is a multiple of p
\ that makes no difference. It stops if the left range is
\ exhausted. This always happens because of the 1 in the
\ right range.

\ Maintain cursors for the left and right entries
\     left start at where we left
\     ight start at the end
\     repeat until left range exhausted
\         if the product of the current prime and the right prime falls in the left range
\            increment right cursor   decrement left count
\         else
\            increment left cursor
\
\ Left N/IX  right IX2 , p*IX2 must be between N/IX N/(IX+1)
\ P*IX2 must be greater than N/IX'  P*IX*IX' must be greater than N.
\ From  index  on use all right ranges to remove `P  from preceeding ranges
    VARIABLE target
:I handle-one-left   BEGIN DUP cur @ IX * target @ > WHILE
    -1 cun @ CNT+!  cur --!  REPEAT DROP ;
REGRESS 100 init-range tbl-end -- cur ! 2 (p) ! 5 tbl[] cun ! S:
\ REGRESS cul @ IX' handle-one-left 5 tbl[] CNT S: 2

\ Go on eliminating p from `cun
:I remove-p-using-right  tbl-end -- cur !   N p / target !
    BEGIN cul @ DUP tbl-end -- < WHILE
        IX'  handle-one-left next-cun REPEAT DROP
    BEGIN cur @ IX p * r @  >  WHILE -1 cun @ CNT+!  cur --!  REPEAT
    cun @ ++ (tblnew-end) !
;
REGRESS 100 init-range 5 tbl[] DUP cul ! cun ! S:
REGRESS remove-p-using-right show S:

: eliminate-p   (p) !   remove-p-using-left remove-p-using-right
    SWAP-OLD-NEW  ;
REGRESS 100 init-range 2 eliminate-p show S:

\ Go on eliminating p from `cul with `cun walking through `tbl not `tblnew.
:I remove-p-using-right2 tbl-end -- cur !   N p / target !
    tbl cun !
    BEGIN cun @ DUP tbl-end -- < WHILE
       IX'  handle-one-left cun ++! REPEAT DROP
    cur @ tbl - 2CELL/ NEGATE   cun @ CNT+! ;

VARIABLE sum
: calculate-sum tbl ++ cul !
    0 BEGIN cul @ DUP tbl-end < WHILE CNT + cul ++! REPEAT DROP ;

:I size  tbl-end tbl - 2CELL/ ;
:I p-    tbl IX' ;
:I p+    tbl-end -- IX ;
REGRESS 100 init-range p- p+ size S: 2 10 10

:I collapse-first   size 1- 2 tbl[] CNT +  NEGATE sum +!
    tbl 2@    (tbl) ++!   SWAP tbl CNT + SWAP  tbl 2! ;
:I collapse-last  (tbl-end) --!   tbl-end CNT tbl-end -- CNT+! ;
REGRESS 100 init-range collapse-first collapse-last show S:

: eliminate-large-small   (p) !
    sum @ NEGATE tbl CNT+!
    remove-p-using-right2
    collapse-first ;


\ Eliminate the largest prime if all ranges except (0,1] are applicable.
:I eliminate-p+   tbl-end -- CNT  size 1-  +   NEGATE  tbl CNT+!
   collapse-last ;

\ Choose you run time display.
\ :I ... ; IMMEDIATE
\ :I ... DUP . CR show ;
\ :I ... DUP .  ^M EMIT ;
:I ... p- . p+ . ^M EMIT ;
\ Eliminate large primes whose single ranges are no longer needed.
\ If N approaches the limit of single precision the unsigned
\ comparison is absolutely needed.
: eliminate-large-large   N p- DUP * /
    BEGIN p+ OVER > WHILE eliminate-p+ REPEAT DROP ;

\ : TT CR TICKS D. CR ;
: TT ; IMMEDIATE
: PI  TT
    init-range 0  \ Initial prime count.
    TT
    BEGIN 1+ p- ... size >R eliminate-p R> size 1+ = UNTIL
    TT
     size + 1-  \ All IX except "1" are eliminated primes
     calculate-sum sum !
     BEGIN eliminate-large-large ... tbl ++ tbl-end < WHILE
        p- eliminate-large-small REPEAT
    tbl CNT +   \ Add bulk count to eliminated primes.
    TT ;


: doit 1 ARG[] EVALUATE PI CR CR . CR ;

2000000000 PI .  BYE

eratosthenes has the following usage:

 ##### init-era   \ Make a table of primes up til ####
 ##### prime? .   \ prints 1 if ### is a prime, otherwise zero
 ##### pi .       \ prints the number of primes under #####

We're into counting primes.
The above can be combined into pi.frt , then compiled
(ciforth only).
The usage then becomes, to be typed from within a shell 2]
(bash, powershell) :

 pi #####

which will print the number of primes up till ####
or crash if #### is too large.

For your convenience PI.EXE PI64.EXE(NOT YET) pi pi64 are precompiled.
See the wiki compilation (NO YET) how to build those programs
yourself if you think that more secure.

--------------------------------------------------

The program eratosthenes.fs should run on most Forth's
after adding WANT by including a file.
It runs i.a. on gforth.
See the wiki gforth for how to get it. (NOT YET)

Within 1] gforth type

S" want.fs" INCLUDED
S" eratosthenes.fs" INCLUDED

--------------------------------------------------

The program eratosthenes.frt is ciforth specific.
It only runs on versions of ciforth which you can get
from
http://github.com/albertvanderhorst/ciforth

See the wiki ciforth for how to get it. (NOT YET)
Within lina/lina64/wina/wina64 type

"eratosthenes.frt" INCLUDED

------------------------------------------------

1] See the FAQ how to get into a Forth. (NOT YET)
2] See the FAQ how to run a command in a shell. (NOT YET)

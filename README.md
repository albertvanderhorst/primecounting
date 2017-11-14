# primecounting
This is a collection of programs to count how many prime numbers there are under a given number.

Sometimes a property is mentionned. They are explained in the wiki, not this
overview.
All techniques have their own subdirectories

There are several techniques:

- naive : just check each number for primeness. Keep the count

- sieve : keep an array of flags. Toggle flags for non-primes.
          then count.

- recursive : Use the legendre property to recursively split a range.

- meissel : A combination of recursion and sieving. Named after Meissel
  the first to explore these tecniques.

- dynamic : Use the legendre property to reuse sieving results without
  actually sieving. This is a form of dynamic programming.

Languages
Programs are written in i.a. Python , C , Forth , Pascal , FORTRAN.
Not all programs have already been uploaded.
For some programs there is a binary available, with a note for
what Operating System.
You may not want to run a program from an unknown source.
There are instructions how to compile.
You may not trust a compiler from an unknown source.
For some compilers the source is given such that you can inspect it
and build the compiler yourself.

Build and run.
Use the usual compilers with the usual extension.
Many files are in Forth. The extension fs (Forth stream)
runs on gforth and probably most ISO standard Forth compilers.
The extension .frt means ciforth https://github.com/albertvanderhorst/ciforth

Files beginning with `` #! '' are linux style scripts.
Without extensions are executable for 64 bit linux. You can compile
those yourself.

WARNING: Those programs use a lot of memory. You may instruct your compiler
to use more memory.

Copyright
Copyright GPL2 is an indication. If a file contains a copyright
notice it is overruling.



-

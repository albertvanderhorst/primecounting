The programs in this directory are so fast that they need
a Forth with a huge memory space, or larger.

See the general remarks about extensions in the main directory.

Inorder to run
   r10par.frt
place it together with lina8G and forth.lab in a working directory
such as /tmp .
Now do
    chmod +x lina8G r10par.frt
    r10par.frt -p 4 1,000,000
This should give the result
    Under 1000000: 78498 primes

It doesn't make much sense to run them on a 32 bit system with a
skimpy number range. The following is for 32 bits but probably runs
on 64 bit.

r10.f  : calculate for 2,000,000,000 : 98222287

r10lico.py : contains the most concise formulation of the
  algorithm, provided you understand list comprehension

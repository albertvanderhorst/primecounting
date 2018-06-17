The programs in this directory are so fast that they need
a Forth with a huge memory space, or larger.

Inorder to run
   r10par.frt
place it together with lina8G and forth.lab in a working directory
such as /tmp .
Now do
    chmod +x lina8G r10par.frt
    r10par.frt -p 4 1,000,000
This should give the result
    Under 1000000: 78498 primes


It doesn't make sense to run them on a 32 bit system with a
skimpy memory space.

r10lico.py : contains the most concise formulation of the
  algorithm, provided you understand list comprehension

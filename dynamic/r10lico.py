# Lucy hedgehog's trick.
def P10(n):
    # S[i] contains the remaining numbers after sieving through p
    S,p = {n/i:n/i-1 for i in xrange(1,n)},1
    # print S, p
    while (p+1)**2 <=n:
        p += 1
        if S[p] > S[p-1]:  # p is prime
            S = { i: S[i]-(0 if i<p*p else S[i//p]-S[p-1]) for i in S.keys() }
            # print S, p
    return S[n]

print P10(1000000)

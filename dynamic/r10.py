# Lucy hedgehog's trick.
# S(n) is the sum of primes
# S(n) is a property
def P10(n):
    S = {n/i:n/i-1 for i in xrange(1,n)}
    for p in range(2,n):
        if p*p > n: break
        if S[p] > S[p-1]:  # p is prime
            S2 = {}
            print S, p
            for i in S.keys():
                if i < p*p :
                    S2[i] = S[i]
                else:
                    S2[i] = S[i] - (S[i//p] - S[p-1])
            S=S2
    print S
    return S

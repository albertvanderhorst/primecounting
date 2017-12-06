# Lucy hedgehog's trick.
# S(n) is the number of primes

def index(n,v,r):
    if v<=r:
       return -v
    else:
       return n//v - 1

def P10(n):
    r = int(n**0.5)
    assert r*r <= n and (r+1)**2 > n
    V = [n//i for i in range(1,r+1)]
    V += list(range(V[-1]-1,0,-1))
    #print V
    #S = {i:i-1 for i in V}
    S2 = [i-1 for i in V]
    #for i in range(1,r+1):
    #   print i, S[i],S2[index(n,i,r)]
    #for i in range(1,r+1):
    #   print i, S[n//i],S2[index(n,n//i,r)]
    #print S2,S
    for p in range(2,r+1):
        #if S[p] > S[p-1]:  # p is prime
        if S2[index(n,p,r)] > S2[index(n,p-1,r)]:  # p is prime
            print p
            #print S[p], S2[index(n,p,r)]
            #sp = S2[index(n,p-1,r)]  # number of primes smaller than p
            sp2 = S2[index(n,p-1,r)]
            p2 = p*p
            #S2[index(n,n,r)] -= (S2[index(n,n//p,r)] - sp2)
            #for v in V[p-1:]:
            for v in V:
                if v < p2: break
                #S[v] -= (S[v//p] - sp)
                S2[index(n,v,r)] -= (S2[index(n,v//p,r)] - sp2)

    #return S[n],S2[index(n,n,r)],len(S)
    return S2[index(n,n,r)],len(S2)

print P10(10000)

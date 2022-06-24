# Notes for X25519 RVV implementation

## Vectorizations for variable-base scalar multiplication on Curve25519

- $(1 \times 4 \times 1)$-way based on `vwmulu` and `vwmaccu`, i.e. `32-bit * 4-lane`
- $(1 \times 2 \times 1)$-way based on `vmul` and `vmulhu`, i.e. `64-bit * 2-lane`

Note: $(1 \times 4 \times 1)$-way can be used for `zve64*` but $(1 \times 2 \times 1)$-way is impossible

---

## $(1 \times 4 \times 1)$-way implementation 

### Seletecd raidx 
- radix-$2^{25.5}$ 
- supports inteleaved multiplication/squaring and reduction

### $(4 \times 1)$-way field arithmetic implementation 
- [x] field multiplication
  - formula
  
  $$\begin{align*}
  r_0 &=& a_0b_0 &+& 38a_1b_9 &+& 19a_2b_8 &+& 38a_3b_7 &+& 19a_4b_6 &+& 38a_5b_5 &+& 19a_6b_4 &+& 38a_7b_3 &+& 19a_8b_2 &+& 38a_9b_1 \\
  r_1 &=& a_0b_1 &+&   a_1b_0 &+& 19a_2b_9 &+& 19a_3b_8 &+& 19a_4b_7 &+& 19a_5b_6 &+& 19a_6b_5 &+& 19a_7b_4 &+& 19a_8b_3 &+& 19a_9b_2 \\
  r_2 &=& a_0b_2 &+&  2a_1b_1 &+&   a_2b_0 &+& 38a_3b_9 &+& 19a_4b_8 &+& 38a_5b_7 &+& 19a_6b_6 &+& 38a_7b_5 &+& 19a_8b_4 &+& 38a_9b_3 \\
  r_3 &=& a_0b_3 &+&   a_1b_2 &+&   a_2b_1 &+&   a_3b_0 &+& 19a_4b_9 &+& 19a_5b_8 &+& 19a_6b_7 &+& 19a_7b_6 &+& 19a_8b_5 &+& 19a_9b_4 \\
  r_4 &=& a_0b_4 &+&  2a_1b_3 &+&   a_2b_2 &+&  2a_3b_1 &+&   a_4b_0 &+& 38a_5b_9 &+& 19a_6b_8 &+& 38a_7b_7 &+& 19a_8b_6 &+& 38a_9b_5 \\
  r_5 &=& a_0b_5 &+&   a_1b_4 &+&   a_2b_3 &+&   a_3b_2 &+&   a_4b_1 &+&   a_5b_0 &+& 19a_6b_9 &+& 19a_7b_8 &+& 19a_8b_7 &+& 19a_9b_6 \\
  r_6 &=& a_0b_6 &+&  2a_1b_5 &+&   a_2b_4 &+&  2a_3b_3 &+&   a_4b_2 &+&  2a_5b_1 &+&   a_6b_0 &+& 38a_7b_9 &+& 19a_8b_8 &+& 38a_9b_7 \\
  r_7 &=& a_0b_7 &+&   a_1b_6 &+&   a_2b_5 &+&   a_3b_4 &+&   a_4b_3 &+&   a_5b_2 &+&   a_6b_1 &+&   a_7b_0 &+& 19a_8b_9 &+& 19a_9b_8 \\
  r_8 &=& a_0b_8 &+&  2a_1b_7 &+&   a_2b_6 &+&  2a_3b_5 &+&   a_4b_4 &+&  2a_5b_3 &+&   a_6b_2 &+&  2a_7b_1 &+&   a_8b_0 &+& 38a_9b_9 \\
  r_9 &=& a_0b_9 &+&   a_1b_8 &+&   a_2b_7 &+&   a_3b_6 &+&   a_4b_5 &+&   a_5b_4 &+&   a_6b_3 &+&   a_7b_2 &+&   a_8b_1 &+&   a_9b_0 \\
  \end{align*}$$
  
  - ranges 
    - inputs:
      - $a_0, a_2, a_4, a_6, a_8$: 28 bits 
      - $a_3, a_5, a_7, a_9$: 27 bits 
      - $a_1$: 28 bits
    - intermediates: 
      - taking a term $38a_1b_9$ as an example: it's impossible to compute first $38 \cdot a_1$ then $38a_1 \cdot b_9$, because $38 \cdot a_1$ causes **overflow**; one must compute $2 \cdot a_1$ and $19 \cdot b_9$ separately, and then $2a_1 \cdot 19b_9 = 38a_1b_9$.
  - implementation 
    - see details in [1] and codes in [2].
- [x] field squaring 
  - formula
   
  $$
  \begin{align*}
  r_0 &=&   a_0a_0 &+& 76a_1a_9 &+& 38a_2a_8 &+& 76a_3a_7 &+& 38a_4a_6 &+& 38a_5a_5                                                   \\
  r_1 &=&  2a_0a_1 & &          &+& 38a_2a_9 &+& 38a_3a_8 &+& 38a_4a_7 &+& 38a_5a_6                                                   \\
  r_2 &=&  2a_0a_2 &+&  2a_1a_1 & &          &+& 76a_3a_9 &+& 38a_4a_8 &+& 76a_5a_7 &+& 19a_6a_6                                      \\
  r_3 &=&  2a_0a_3 &+&  2a_1a_2 & &          & &          &+& 38a_4a_9 &+& 38a_5a_8 &+& 38a_6a_7                                      \\
  r_4 &=&  2a_0a_4 &+&  4a_1a_3 &+&   a_2a_2 & &          & &          &+& 76a_5a_9 &+& 38a_6a_8 &+& 38a_7a_7                         \\
  r_5 &=&  2a_0a_5 &+&  2a_1a_4 &+&  2a_2a_3 & &          & &          & &          &+& 38a_6a_9 &+& 38a_7a_8                         \\
  r_6 &=&  2a_0a_6 &+&  4a_1a_5 &+&  2a_2a_4 &+&  2a_3a_3 & &          & &          & &          &+& 76a_7a_9 &+& 19a_8a_8            \\
  r_7 &=&  2a_0a_7 &+&  2a_1a_6 &+&  2a_2a_5 &+&  2a_3a_4 & &          & &          & &          & &          &+& 38a_8a_9            \\
  r_8 &=&  2a_0a_8 &+&  4a_1a_7 &+&  2a_2a_6 &+&  4a_3a_5 &+&  a_4a_4  & &          & &          & &          & &         &+& 38a_9a_9\\
  r_9 &=&  2a_0a_9 &+&  2a_1a_8 &+&  2a_2a_7 &+&  2a_3a_6 &+& 2a_4a_5                                                                 \\
  \end{align*}
  $$
  
  - implementation
    - developed from scratch (maybe somebody has already used the same formula, but anyways)
    - faster than the method in [1]

### $(1 \times 4)$-way field arithmetic implementation 
- [x] field multiplicative inversion
  - formula 
    - Euler's theorem  
  - implementation 
    - [x] $(1 \times 4)$-way field multiplication 
    - [ ] $(1 \times 4)$-way field squaring (currently no good idea)

### Montgomery curve arithmetic
- [x] $(1 \times 4 \times 1)$-way Montgomery ladder 
  - implementation 
    - based on the method in [3]

---

## $(1 \times 2 \times 1)$-way implementation 

### Seletecd raidx 
- radix-$2^{51}$ 
- supports inteleaved multiplication/squaring and reduction

### $(2 \times 1)$-way field arithmetic implementation 
- [x] field multiplication
  - formula
  
  $$
  \begin{align*}
  r_0 &=& a_0b_0 &+& 19a_1b_4 &+& 19a_2b_3 &+& 19a_3b_2 &+& 19a_4b_1  \\
  r_1 &=& a_0b_1 &+&   a_1b_0 &+& 19a_2b_4 &+& 19a_3b_3 &+& 19a_4b_2  \\
  r_2 &=& a_0b_2 &+&   a_1b_1 &+&   a_2b_0 &+& 19a_3b_4 &+& 19a_4b_3  \\
  r_3 &=& a_0b_3 &+&   a_1b_2 &+&   a_2b_1 &+&   a_3b_0 &+& 19a_4b_4  \\
  r_4 &=& a_0b_4 &+&   a_1b_3 &+&   a_2b_2 &+&   a_3b_1 &+&   a_4b_0  
  \end{align*}
  $$
  
  - ranges 
    - inputs:
      - $a_0, a_1, a_2, a_3, a_4$: 53 bits 
  - implementation 
    - conventional operand-scanning
- [x] field squaring 
  - formula
   
  $$
  \begin{align*}
  r_0 &=&  a_0a_0 &+& 38a_1a_4 &+& 38a_2a_3 & &          & &           \\
  r_1 &=& 2a_0a_1 & &          &+& 38a_2a_4 &+& 19a_3a_3 & &           \\
  r_2 &=& 2a_0a_2 &+&   a_1a_1 & &          &+& 38a_3a_4 & &           \\
  r_3 &=& 2a_0a_3 &+&  2a_1a_2 & &          & &          &+& 19a_4a_4  \\
  r_4 &=& 2a_0a_4 &+&  2a_1a_3 &+&   a_2a_2 & &          & &    
  \end{align*}
  $$

### $(1 \times 2)$-way field arithmetic implementation 
- [x] field multiplicative inversion
  - formula 
    - Euler's theorem  
  - implementation 
    - [x] $(1 \times 2)$-way field multiplication 
    - [ ] $(1 \times 2)$-way field squaring 

## Montgomery curve arithmetic 

- [x] $(1 \times 2 \times 1)$-way Montgomery ladder 
  - implementation 
    - based on Algorithm 1 in [7]
  
---

## Field multiplicative inversion 

- I guess in terms of field inversion $1$-way $>$ $(1 \times 2)$-way $>$ $(1 \times 4)$-way, which means using hybrid vectorized-with-scalar implementation is the most efficient option. 

---

## Something interesting

- Based on the observation in inversion, I'm also wondering whether the hybrid implementation (batch multiplication/squaring + serial addition/subtraction) of Montgomery ladder is more efficient? Because there are two ALUs, i.e., scalar ALU and vector ALU, and all the data are stored in RAM (unless we choose to store all the data in vector scratchpad), the hybrid way seems to be the most efficient option? 

---

## References 

[1] A. Faz-Hernández, J. López, and R. Dahab. *High-performance Implementation of Elliptic Curve Cryptography Using Vector Instructions*, in ACM Transactions on Mathematical Software (TOMS) 2019.

[2] https://github.com/armfazh/fld-ecc-vec/blob/master/src/eltfp25519_4w_redradix.c

[3] H. Hisil, B. Egrice, and M. Yassi. *Fast 4 way vectorized ladder for the complete set of Montgomery curves*, in ePrint 2020/388.

[4] H. Hisil, K. Wong, G. Carter, and E. Dawson. *Twisted Edwards Curves Revisited*, in ASIACRYPT 2008.

[5] https://www.hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html 

[6] D. Hankerson, A. Menezes, and S.Vanstone. *Guide to Elliptic Curve Cryptography*, Springer Verlag, 2004.

[7] A. Faz-Hernández and J. López. *Fast Implementation of Curve25519 Using AVX2*, in LatinCrypt 2015.


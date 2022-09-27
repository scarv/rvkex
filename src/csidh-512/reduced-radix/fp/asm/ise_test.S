// void gfp_sub_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64

#include "ise2/ise2.h"
#include "ise3/ise3.h"

.section .text

.global test_maddlu
test_maddlu:
    madd57lu a0, a0, a1, a2
    ret
  
.global test_maddhu
test_maddhu:
    madd57hu a0, a0, a1, a2
    ret

.global test_sraiadd
test_sraiadd:
    sraiadd a0, a0, a1, 57
    ret

.global test_sub
test_sub:
    csidh.sub.p512.57 a0, a0, 8
    ret 

.global test_andadd
test_andadd:
    csidh.and.p512.add57 a0, a0, a1, 8
    ret 

.global test_subadd
test_subadd:
    csidh.sub.p512.add57 a0, a0, a1, 8
    ret 

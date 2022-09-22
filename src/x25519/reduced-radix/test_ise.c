#include <stdio.h>

static uint64_t lfsr(uint64_t x)
{
  uint64_t bit = (x ^ (x >> 1)) & 1;
  return (x >> 1) | (bit << 62);
}

extern uint64_t test_maddhu(uint64_t a, uint64_t b, uint64_t c);
extern uint64_t test_maddlu(uint64_t a, uint64_t b, uint64_t c);
extern uint64_t test_sraiadd(uint64_t a, uint64_t b);

uint64_t gold_maddhu(uint64_t a, uint64_t b, uint64_t c){
    unsigned __int128 p = (__uint128_t) a * (__uint128_t) b;
    uint64_t r = ((p>>51)) + c;
    return r;
}

uint64_t gold_maddlu(uint64_t a, uint64_t b, uint64_t c){
    uint64_t m = ((uint64_t)1 << 51) - 1;  
    uint64_t r = ((a * b) & m) + c;
    return r;
}

uint64_t gold_sraiadd(uint64_t a, uint64_t b){
    uint64_t r = a + (b>>7);
    return r;
}

uint64_t gold_maddu(uint64_t a, uint64_t b, uint64_t * c){
    unsigned __int128 m = (__uint128_t) a * (__uint128_t) b + (__uint128_t) *c;
    uint64_t r = (uint64_t)m;
    *c = (m >>64); 
    return r;
}

void test_ise() 
{
    int fail = 0;  
#if RV64_TYPE2
    uint64_t lhs = 0xABCDEF0123456789; 
    uint64_t rhs = 0xCAFECAFEDEADBEAD;

    uint64_t r3 = 0x0000000000000007;

    printf("# RV64 ISE Instruction Test \n");

    test_maddhu(lhs, rhs,r3);
    test_maddlu(lhs, rhs,r3);

    for (uint64_t i=0;i<30;i++){

    printf("\nlhs: %llx, rhs: %llx\n", lhs, rhs);
     
    // maddhu    
    uint64_t result = test_maddhu(lhs, rhs, i);
    uint64_t expect = gold_maddhu(lhs, rhs, i);

    if(result != expect) {
        printf("test_maddhu [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // maddlu
    result = test_maddlu(lhs, rhs, i);
    expect = gold_maddlu(lhs, rhs, i);

    if(result != expect) {
        printf("test_maddlu [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // sraiadd
    result = test_sraiadd(lhs, rhs);    
    expect = gold_sraiadd(lhs, rhs);

    if(result != expect) {
        printf("test_sraiadd [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    rhs = lfsr(lhs);
    lhs = lfsr(rhs);
    r3  = lfsr(r3);
    }
#endif
}

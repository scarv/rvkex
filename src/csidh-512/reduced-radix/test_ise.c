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
    uint64_t r = ((p>>57)) + c;
    return r;
}

uint64_t gold_maddlu(uint64_t a, uint64_t b, uint64_t c){
    uint64_t m = ((uint64_t)1 << 57) - 1;  
    uint64_t r = ((a * b) & m) + c;
    return r;
}

uint64_t gold_sraiadd(uint64_t a, uint64_t b){
    uint64_t r = a + (b>>57);
    return r;
}

/*uint64_t gold_maddu(uint64_t a, uint64_t b, uint64_t * c){
    unsigned __int128 m = (__uint128_t) a * (__uint128_t) b + (__uint128_t) *c;
    uint64_t r = (uint64_t)m;
    *c = (m >>64); 
    return r;
}*/

uint64_t gold_sub(   uint64_t a,          uint8_t imm){
    imm &= 0xF;
    uint64_t r;

    if      ( imm == 0 ) { r = a - 0x181B90533C6C87B; }
    else if ( imm == 1 ) { r = a - 0x10DFA2BD6541A8D; }
    else if ( imm == 2 ) { r = a - 0x03307C2D3C9709C; }
    else if ( imm == 3 ) { r = a - 0x0ACFE6AA0EA2CE6; }
    else if ( imm == 4 ) { r = a - 0x1322C9CDA7AAC6C; }
    else if ( imm == 5 ) { r = a - 0x0446212D7DFE634; }
    else if ( imm == 6 ) { r = a - 0x1312AD0B420EBB7; }
    else if ( imm == 7 ) { r = a - 0x17FF91561A2BC7C; }
    else if ( imm == 8 ) { r = a - 0x065B48E8F740F89; }
    return r;
}

uint64_t gold_subadd(uint64_t a, uint64_t b, uint8_t imm){
    imm &= 0xF;
    uint64_t r;

    if      ( imm == 0 ) { r = a - 0x181B90533C6C87B + b; }
    else if ( imm == 1 ) { r = a - 0x10DFA2BD6541A8D + b; }
    else if ( imm == 2 ) { r = a - 0x03307C2D3C9709C + b; }
    else if ( imm == 3 ) { r = a - 0x0ACFE6AA0EA2CE6 + b; }
    else if ( imm == 4 ) { r = a - 0x1322C9CDA7AAC6C + b; }
    else if ( imm == 5 ) { r = a - 0x0446212D7DFE634 + b; }
    else if ( imm == 6 ) { r = a - 0x1312AD0B420EBB7 + b; }
    else if ( imm == 7 ) { r = a - 0x17FF91561A2BC7C + b; }
    else if ( imm == 8 ) { r = a - 0x065B48E8F740F89 + b; }
    return r;
}

uint64_t gold_andadd(uint64_t a, uint64_t b, uint8_t imm){
    imm &= 0xF;
    uint64_t r;

    if      ( imm == 0 ) { r = (a & 0x181B90533C6C87B) + b; }
    else if ( imm == 1 ) { r = (a & 0x10DFA2BD6541A8D) + b; }
    else if ( imm == 2 ) { r = (a & 0x03307C2D3C9709C) + b; }
    else if ( imm == 3 ) { r = (a & 0x0ACFE6AA0EA2CE6) + b; }
    else if ( imm == 4 ) { r = (a & 0x1322C9CDA7AAC6C) + b; }
    else if ( imm == 5 ) { r = (a & 0x0446212D7DFE634) + b; }
    else if ( imm == 6 ) { r = (a & 0x1312AD0B420EBB7) + b; }
    else if ( imm == 7 ) { r = (a & 0x17FF91561A2BC7C) + b; }
    else if ( imm == 8 ) { r = (a & 0x065B48E8F740F89) + b; }
    return r;
}

void test_ise() 
{
    int fail = 0;  
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

    // test_sub
    result = test_sub(lhs);    
    expect = gold_sub(lhs, 8);

    if(result != expect) {
        printf("test_sub [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // test_subadd
    result = test_subadd(lhs, rhs);    
    expect = gold_subadd(lhs, rhs, 8);

    if(result != expect) {
        printf("test_subadd [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    // test_andadd
    result = test_andadd(lhs, rhs);    
    expect = gold_andadd(lhs, rhs, 8);

    if(result != expect) {
        printf("test_andadd [FAIL]\n");
        printf("Expected: %llx, got: %llx\n", expect, result);
        fail = 1;
    }

    rhs = lfsr(lhs);
    lhs = lfsr(rhs);
    r3  = lfsr(r3);
    }

}

// void gfp_sqr_4x1w(vec4 *r, const vec4 *a);
// radix-25.5 + vwmaccu vwmulu


// meaningful names for registers and constants

// result "r" (Ri is a wide vector)
#define R0 v12
#define R1 v14
#define R2 v16
#define R3 v18
#define R4 v20
#define R5 v22
#define R6 v24
#define R7 v26
#define R8 v28
#define R9 v30

// operand "b", in fact "a" 
#define B0 v0
#define B1 v1
#define B2 v2
#define B3 v3
#define B4 v4
#define B5 v5
#define B6 v6
#define B7 v7
#define B8 v8
#define B9 v9

// operand "a"
#define A0 v0
#define A1 v1
#define A2 v2
#define A3 v3
#define A4 v4
#define A5 v4                           // re-use "A4" as "19*A5"
#define A6 v3                           // re-use "A3" as "19*A6"
#define A7 v2                           // re-use "A2" as "19*A7"
#define A8 v1                           // re-use "A1" as "19*A8"
#define A9 v0                           // re-use "A0" as "19*A9"
#define A_ v10                          // "A_" means any limb of "a"
#define _A v11                          // "_A" means the mirror image of "A_"

// carry   
#define CL v10                          // the Lower  part of Carry bits
#define CH v11                          // the Higher part of Carry bits  

// constants and masks
#define C19 t2                          // 19  
#define C51 t3                          // 51
#define M26 t4                          // 2^26 - 1
#define M25 t5                          // 2^25 - 1


// load operand "b" + store result "r" 

.macro LOAD_OPERAND_B_LMUL1 
  vle32.v  B0, (a1) 
  addi     a1,  a1, 16 
  vle32.v  B1, (a1)
  addi     a1,  a1, 16 
  vle32.v  B2, (a1) 
  addi     a1,  a1, 16 
  vle32.v  B3, (a1)
  addi     a1,  a1, 16 
  vle32.v  B4, (a1) 
  addi     a1,  a1, 16 
  vle32.v  B5, (a1)
  addi     a1,  a1, 16 
  vle32.v  B6, (a1) 
  addi     a1,  a1, 16 
  vle32.v  B7, (a1)
  addi     a1,  a1, 16 
  vle32.v  B8, (a1) 
  addi     a1,  a1, 16 
  vle32.v  B9, (a1)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse32.v  B0, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B1, (a0)
  addi     a0,  a0, 16 
  vse32.v  B2, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B3, (a0)
  addi     a0,  a0, 16 
  vse32.v  B4, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B5, (a0)
  addi     a0,  a0, 16 
  vse32.v  B6, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B7, (a0)
  addi     a0,  a0, 16 
  vse32.v  B8, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B9, (a0)
.endm


// interleaved squaring and reduction (based on operand-scanning)

// R0 =   A0A0 + 76A1A9 + 38A2A8 + 76A3A7 + 38A4A6 + 38A5A5
// R1 =  2A0A1          + 38A2A9 + 38A3A8 + 38A4A7 + 38A5A6
// R2 =  2A0A2 +  2A1A1          + 76A3A9 + 38A4A8 + 76A5A7 + 19A6A6
// R3 =  2A0A3 +  2A1A2                   + 38A4A9 + 38A5A8 + 38A6A7
// R4 =  2A0A4 +  4A1A3 +   A2A2                   + 76A5A9 + 38A6A8 + 38A7A7
// R5 =  2A0A5 +  2A1A4 +  2A2A3                            + 38A6A9 + 38A7A8
// R6 =  2A0A6 +  4A1A5 +  2A2A4 +  2A3A3                            + 76A7A9 + 19A8A8
// R7 =  2A0A7 +  2A1A6 +  2A2A5 +  2A3A4                                     + 38A8A9
// R8 =  2A0A8 +  4A1A7 +  2A2A6 +  4A3A5 +  A4A4                                      + 38A9A9
// R9 =  2A0A9 +  2A1A8 +  2A2A7 +  2A3A6 + 2A4A5

.macro MULTIPLY_A0_LMUL1
  vwmulu.vv  R0, A0, B0                 // R0  =   A0A0
  vadd.vv    A_, A0, A0                 // A_  =  2A0
  vwmulu.vv  R1, A_, B1                 // R1  =  2A0A1
  vwmulu.vv  R2, A_, B2                 // R2  =  2A0A2
  vwmulu.vv  R3, A_, B3                 // R3  =  2A0A3
  vwmulu.vv  R4, A_, B4                 // R4  =  2A0A4
  vwmulu.vv  R5, A_, B5                 // R5  =  2A0A5
  vwmulu.vv  R6, A_, B6                 // R6  =  2A0A6
  vwmulu.vv  R7, A_, B7                 // R7  =  2A0A7
  vwmulu.vv  R8, A_, B8                 // R8  =  2A0A8
  vwmulu.vv  R9, A_, B9                 // R9  =  2A0A9
.endm

.macro MULTIPLY_A1_LMUL1
  vmul.vx    A9, B9, C19                // A9  = 19  A9
  vadd.vv    A_, A1, A1                 // A_  =  2A1
  vwmaccu.vv R2, A_, B1                 // R2 +=  2A1A1
  vwmaccu.vv R3, A_, B2                 // R3 +=  2A1A2
  vwmaccu.vv R5, A_, B4                 // R5 +=  2A1A4
  vwmaccu.vv R7, A_, B6                 // R7 +=  2A1A6
  vwmaccu.vv R9, A_, B8                 // R9 +=  2A1A8
  vadd.vv    A_, A_, A_                 // A_  =  4A1
  vwmaccu.vv R4, A_, B3                 // R4 +=  4A1A3
  vwmaccu.vv R6, A_, B5                 // R6 +=  4A1A5  
  vwmaccu.vv R8, A_, B7                 // R8 +=  4A1A7
  vwmaccu.vv R0, A_, A9                 // R0 += 76A1A9
.endm

.macro MULTIPLY_A2_LMUL1
  vmul.vx    A8, B8, C19                // A8  = 19  A8
  vwmaccu.vv R4, A2, B2                 // R4 +=   A2A2
  vadd.vv    A_, A2, A2                 // A_  =  2A2
  vwmaccu.vv R5, A_, B3                 // R5 +=  2A2A3
  vwmaccu.vv R6, A_, B4                 // R6 +=  2A2A4
  vwmaccu.vv R7, A_, B5                 // R7 +=  2A2A5
  vwmaccu.vv R8, A_, B6                 // R8 +=  2A2A6
  vwmaccu.vv R9, A_, B7                 // R9 +=  2A2A7
  vwmaccu.vv R0, A_, A8                 // R0 += 38A2A8
  vwmaccu.vv R1, A_, A9                 // R1 += 38A2A9
.endm

.macro MULTIPLY_A3_LMUL1
  vmul.vx    A7, B7, C19                // A7  = 19  A7
  vadd.vv    A_, A3, A3                 // A_  =  2A3
  vwmaccu.vv R6, A_, B3                 // R6 +=  2A3A3
  vwmaccu.vv R7, A_, B4                 // R7 +=  2A3A4
  vwmaccu.vv R9, A_, B6                 // R9 +=  2A3A6
  vwmaccu.vv R1, A_, A8                 // R1 += 38A3A8
  vadd.vv    A_, A_, A_                 // A_  =  4A3
  vwmaccu.vv R8, A_, B5                 // R8 +=  4A3A5   
  vwmaccu.vv R0, A_, A7                 // R0 += 76A3A7  
  vwmaccu.vv R2, A_, A9                 // R2 += 76A3A9  
.endm 

.macro MULTIPLY_A4_LMUL1
  vmul.vx    A6, B6, C19                // A6  = 19  A6 
  vwmaccu.vv R8, A4, A4                 // R8 +=   A4A4 
  vadd.vv    A_, A4, A4                 // A_  =  2A4
  vwmaccu.vv R9, A_, B5                 // R9 +=  2A4A5
  vwmaccu.vv R0, A_, A6                 // R0 += 38A4A6
  vwmaccu.vv R1, A_, A7                 // R1 += 38A2A7
  vwmaccu.vv R2, A_, A8                 // R2 += 38A2A8
  vwmaccu.vv R3, A_, A9                 // R3 += 38A2A9
.endm

.macro MULTIPLY_A5_LMUL1
  vmul.vx    A5, B5, C19                // A5  = 19  A5 
  vadd.vv    A_, B5, B5                 // A_  =  2A5
  vwmaccu.vv R0, A_, A5                 // R0 += 38A5A5
  vwmaccu.vv R1, A_, A6                 // R1 += 38A5A6
  vwmaccu.vv R3, A_, A8                 // R3 += 38A5A8
  vadd.vv    A_, A_, A_                 // A_  =  4A5
  vwmaccu.vv R2, A_, A7                 // R2 += 76A5A7
  vwmaccu.vv R4, A_, A9                 // R4 += 76A5A9  
.endm

.macro MULTIPLY_A6_LMUL1
  vwmaccu.vv R2, B6, A6                 // R2 += 19A6A6
  vadd.vv    A_, B6, B6                 // A_  =  2A6
  vwmaccu.vv R3, A_, A7                 // R3 += 38A6A7
  vwmaccu.vv R4, A_, A8                 // R4 += 38A6A8
  vwmaccu.vv R5, A_, A9                 // R5 += 38A6A9
.endm

.macro MULTIPLY_A7_LMUL1
  vadd.vv    A_, B7, B7                 // A_  =  2A7
  vwmaccu.vv R4, A_, A7                 // R4 += 38A7A7
  vwmaccu.vv R5, A_, A8                 // R5 += 38A7A8
  vadd.vv    A_, A_, A_                 // A_  =  4A7
  vwmaccu.vv R6, A_, A9                 // R1 += 76A7A9
.endm

.macro MULTIPLY_A8_LMUL1
  vwmaccu.vv R6, B8, A8                 // R6 += 19A8A8
  vadd.vv    A_, B8, B8                 // A_  =  2A8
  vwmaccu.vv R7, A_, A9                 // R7 += 38A8A9
.endm

.macro MULTIPLY_A9_LMUL1
  vadd.vv    A_, B9, B9                 // A_  =  2A9
  vwmaccu.vv R8, A_, A9                 // R8 += 38A9A9
.endm

// carry propagation (working on Wide VECtor)
// TODO: optimize the conversion between wide vector and single-length vector

.macro CARRY_PROPAGATION_WVEC_LMUL1 
  vnsrl.wi   B0, R0, 0                 
  vnsrl.wi   CL, R0, 26
  vnsrl.wx   CH, R0, C51
  vand.vx    CL, CL, M25
  vand.vx    B0, B0, M26             

  vwaddu.wv  R1, R1, CL
  vwaddu.wv  R2, R2, CH
  vnsrl.wi   B1, R1, 0
  vnsrl.wi   CL, R1, 25
  vnsrl.wx   CH, R1, C51
  vand.vx    CL, CL, M26
  vand.vx    B1, B1, M25

  vwaddu.wv  R2, R2, CL
  vwaddu.wv  R3, R3, CH
  vnsrl.wi   B2, R2, 0
  vnsrl.wi   CL, R2, 26
  vnsrl.wx   CH, R2, C51
  vand.vx    CL, CL, M25
  vand.vx    B2, B2, M26

  vwaddu.wv  R3, R3, CL
  vwaddu.wv  R4, R4, CH
  vnsrl.wi   B3, R3, 0
  vnsrl.wi   CL, R3, 25
  vnsrl.wx   CH, R3, C51
  vand.vx    CL, CL, M26
  vand.vx    B3, B3, M25

  vwaddu.wv  R4, R4, CL
  vwaddu.wv  R5, R5, CH
  vnsrl.wi   B4, R4, 0
  vnsrl.wi   CL, R4, 26
  vnsrl.wx   CH, R4, C51
  vand.vx    CL, CL, M25
  vand.vx    B4, B4, M26

  vwaddu.wv  R5, R5, CL
  vwaddu.wv  R6, R6, CH
  vnsrl.wi   B5, R5, 0
  vnsrl.wi   CL, R5, 25
  vnsrl.wx   CH, R5, C51
  vand.vx    CL, CL, M26
  vand.vx    B5, B5, M25

  vwaddu.wv  R6, R6, CL
  vwaddu.wv  R7, R7, CH
  vnsrl.wi   B6, R6, 0
  vnsrl.wi   CL, R6, 26
  vnsrl.wx   CH, R6, C51
  vand.vx    CL, CL, M25
  vand.vx    B6, B6, M26

  vwaddu.wv  R7, R7, CL
  vwaddu.wv  R8, R8, CH
  vnsrl.wi   B7, R7, 0
  vnsrl.wi   CL, R7, 25
  vnsrl.wx   CH, R7, C51
  vand.vx    CL, CL, M26
  vand.vx    B7, B7, M25

  vwaddu.wv  R8, R8, CL
  vwaddu.wv  R9, R9, CH
  vnsrl.wi   B8, R8, 0
  vnsrl.wi   CL, R8, 26
  vnsrl.wx   CH, R8, C51
  vand.vx    CL, CL, M25
  vand.vx    B8, B8, M26

  vmul.vx    CH, CH, C19
  vadd.vv    B0, B0, CH 

  vwaddu.wv  R9, R9, CL
  vnsrl.wi   B9, R9, 0
  vnsrl.wi   CL, R9, 25
  vnsrl.wx   CH, R9, C51
  vand.vx    CL, CL, M26
  vand.vx    B9, B9, M25

  vmul.vx    CL, CL, C19
  vadd.vv    B0, B0, CL 

  vmul.vx    CH, CH, C19
  vadd.vv    B1, B1, CH 

  vsrl.vi    CL, B0, 26
  vand.vx    B0, B0, M26

  vadd.vv    B1, B1, CL
.endm


// (4x1)-way field squaring 

.section .text

// v0: conventional operand-scanning 

.global gfp_sqr_4x1w_v0

gfp_sqr_4x1w_v0:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  // 
  LOAD_OPERAND_B_LMUL1                  // load operand "a" to B0-B9
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  MULTIPLY_A5_LMUL1                     //
  MULTIPLY_A6_LMUL1                     //
  MULTIPLY_A7_LMUL1                     //
  MULTIPLY_A8_LMUL1                     //
  MULTIPLY_A9_LMUL1                     //
  CARRY_PROPAGATION_WVEC_LMUL1          //
  STORE_RESULT_R_LMUL1                  // store result "r" R0-R9 to memory 
  //
  ret  


// v1: uses register group to load/store (LMUL = 8, 2)

.macro LOAD_OPERAND_B_LMUL82 
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vle32.v B0, (a1)                      // load 8 LS-limbs of "a" to B0-B7
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a1, a1, 128                   // 
  vle32.v B8, (a1)                      // load 2 MS-limbs of "a" to B8-B9
.endm

.macro STORE_RESULT_R_LMUL82
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vse32.v B0, (a0)                      // store 8 LS-limbs of "r" to memory
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a0, a0, 128                   // 
  vse32.v B8, (a0)                      // store 2 MS-limbs of "r" to memory
.endm


.global gfp_sqr_4x1w_v1

gfp_sqr_4x1w_v1:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  // 
  LOAD_OPERAND_B_LMUL82                 // load operand "a" to B0-B9
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  MULTIPLY_A5_LMUL1                     //
  MULTIPLY_A6_LMUL1                     //
  MULTIPLY_A7_LMUL1                     //
  MULTIPLY_A8_LMUL1                     //
  MULTIPLY_A9_LMUL1                     //
  CARRY_PROPAGATION_WVEC_LMUL1          //
  STORE_RESULT_R_LMUL82                 // store result "r" R0-R9 to memory 
  //
  ret  


// v2: uses register group to load/store (LUML = 8, 2) and arithmetic computation (LMUL = 2, 1)

.macro MULTIPLY_A0_LMUL2
  vwmulu.vv  R0, A0, B0                 // R0         =   A0A0
  vadd.vv    A_, A0, A0                 // A_         =  2A0
  vwmulu.vv  R1, A_, A1                 // R1         =  2A0A1  
  vmv1r.v    _A, A_                     // _A || A_   =  2A0   ||  2A0
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmulu.vv  R2, A_, B2                 // R3 || R2   =  2A0A3 ||  2A0A2 
  vwmulu.vv  R4, A_, B4                 // R6 || R4   =  2A0A5 ||  2A0A4 
  vwmulu.vv  R6, A_, B6                 // R7 || R6   =  2A0A7 ||  2A0A6 
  vwmulu.vv  R8, A_, B8                 // R9 || R8   =  2A0A9 ||  2A0A8 
  vsetvli    t0, t1, e32, m1            // LMUL = 1
.endm

.macro CARRY_PROPAGATION_WVEC_LMUL2
  vsetvli    t0, t1, e64, m2
  vsrl.vi    CL, R0, 26
  vadd.vv    R1, R1, CL
  vsrl.vi    CL, R1, 25
  vadd.vv    R2, R2, CL 
  vsrl.vi    CL, R2, 26
  vadd.vv    R3, R3, CL
  vsrl.vi    CL, R3, 25
  vadd.vv    R4, R4, CL
  vsrl.vi    CL, R4, 26
  vadd.vv    R5, R5, CL
  vsrl.vi    CL, R5, 25
  vadd.vv    R6, R6, CL
  vsrl.vi    CL, R6, 26
  vadd.vv    R7, R7, CL
  vsrl.vi    CL, R7, 25
  vadd.vv    R8, R8, CL
  vsrl.vi    CL, R8, 26
  vadd.vv    R9, R9, CL
  vsrl.vi    CL, R9, 25
  vmul.vx    CL, CL, C19
  vsetvli    t0, t1, e32, m1

  vnsrl.wi   B0, R0, 0 
  vand.vx    B0, B0, M26
  vnsrl.wi   B1, R1, 0
  vand.vx    B1, B1, M25
  vnsrl.wi   B2, R2, 0
  vand.vx    B2, B2, M26
  vnsrl.wi   B3, R3, 0
  vand.vx    B3, B3, M25
  vnsrl.wi   B4, R4, 0
  vand.vx    B4, B4, M26
  vnsrl.wi   B5, R5, 0
  vand.vx    B5, B5, M25
  vnsrl.wi   B6, R6, 0
  vand.vx    B6, B6, M26
  vnsrl.wi   B7, R7, 0
  vand.vx    B7, B7, M25
  vnsrl.wi   B8, R8, 0
  vand.vx    B8, B8, M26
  vnsrl.wi   B9, R9, 0
  vand.vx    B9, B9, M25

  vnsrl.wi   R1, CL, 26
  vnsrl.wi   R0, CL, 0
  vand.vx    R0, R0, M26
  vadd.vv    B0, B0, R0
  vadd.vv    B1, B1, R1 
.endm


.global gfp_sqr_4x1w_v2

gfp_sqr_4x1w_v2:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  // 
  LOAD_OPERAND_B_LMUL82                 // load operand "a" to B0-B9
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  MULTIPLY_A0_LMUL2                     //          
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  MULTIPLY_A5_LMUL1                     //
  MULTIPLY_A6_LMUL1                     //
  MULTIPLY_A7_LMUL1                     //
  MULTIPLY_A8_LMUL1                     //
  MULTIPLY_A9_LMUL1                     //
  CARRY_PROPAGATION_WVEC_LMUL2          //
  STORE_RESULT_R_LMUL82                 // store result "r" R0-R9 to memory 
  //
  ret  

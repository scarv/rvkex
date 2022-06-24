// void gfp_mul_4x1w(vec4 *r, const vec4 *a, const vec4 *b);
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

// operand "b"
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


// load operands "a" "b" + store result "r" 

.macro LOAD_OPERAND_A_LMUL1
  vle32.v  A_, (a1)
  addi     a1,  a1, 16
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle32.v  B0, (a2) 
  addi     a2,  a2, 16 
  vle32.v  B1, (a2)
  addi     a2,  a2, 16 
  vle32.v  B2, (a2) 
  addi     a2,  a2, 16 
  vle32.v  B3, (a2)
  addi     a2,  a2, 16 
  vle32.v  B4, (a2) 
  addi     a2,  a2, 16 
  vle32.v  B5, (a2)
  addi     a2,  a2, 16 
  vle32.v  B6, (a2) 
  addi     a2,  a2, 16 
  vle32.v  B7, (a2)
  addi     a2,  a2, 16 
  vle32.v  B8, (a2) 
  addi     a2,  a2, 16 
  vle32.v  B9, (a2)
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

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A0
  vwmulu.vv  R0, A_, B0                 // R0  =   A0B0
  vwmulu.vv  R1, A_, B1                 // R1  =   A0B1
  vwmulu.vv  R2, A_, B2                 // R2  =   A0B2
  vwmulu.vv  R3, A_, B3                 // R3  =   A0B3
  vwmulu.vv  R4, A_, B4                 // R4  =   A0B4
  vwmulu.vv  R5, A_, B5                 // R5  =   A0B5
  vwmulu.vv  R6, A_, B6                 // R6  =   A0B6
  vwmulu.vv  R7, A_, B7                 // R7  =   A0B7
  vwmulu.vv  R8, A_, B8                 // R8  =   A0B8
  vwmulu.vv  R9, A_, B9                 // R9  =   A0B9
.endm

.macro MULTIPLY_A1_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A1
  vmul.vx    B9, B9, C19                // B9  = 19  B9
  vwmaccu.vv R1, A_, B0                 // R1 +=   A1B0
  vwmaccu.vv R3, A_, B2                 // R3 +=   A1B2
  vwmaccu.vv R5, A_, B4                 // R5 +=   A1B4
  vwmaccu.vv R7, A_, B6                 // R7 +=   A1B6
  vwmaccu.vv R9, A_, B8                 // R9 +=   A1B8
  vadd.vv    A_, A_, A_                 // A_  =  2A1
  vwmaccu.vv R2, A_, B1                 // R2 +=  2A1B1
  vwmaccu.vv R4, A_, B3                 // R4 +=  2A1B3
  vwmaccu.vv R6, A_, B5                 // R6 +=  2A1B5
  vwmaccu.vv R8, A_, B7                 // R8 +=  2A1B7
  vwmaccu.vv R0, A_, B9                 // R0 += 38A1B9
.endm

.macro MULTIPLY_A2_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A2
  vmul.vx    B8, B8, C19                // B8  = 19  B8
  vwmaccu.vv R2, A_, B0                 // R2 +=   A2B0
  vwmaccu.vv R3, A_, B1                 // R3 +=   A2B1
  vwmaccu.vv R4, A_, B2                 // R4 +=   A2B2
  vwmaccu.vv R5, A_, B3                 // R5 +=   A2B3
  vwmaccu.vv R6, A_, B4                 // R6 +=   A2B4
  vwmaccu.vv R7, A_, B5                 // R7 +=   A2B5
  vwmaccu.vv R8, A_, B6                 // R8 +=   A2B6
  vwmaccu.vv R9, A_, B7                 // R9 +=   A2B7
  vwmaccu.vv R0, A_, B8                 // R0 += 19A2B8
  vwmaccu.vv R1, A_, B9                 // R1 += 19A2B9
.endm

.macro MULTIPLY_A3_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A3
  vmul.vx    B7, B7, C19                // B7  = 19  B7
  vwmaccu.vv R3, A_, B0                 // R3 +=   A3B0
  vwmaccu.vv R5, A_, B2                 // R5 +=   A3B2
  vwmaccu.vv R7, A_, B4                 // R7 +=   A3B4
  vwmaccu.vv R9, A_, B6                 // R9 +=   A3B6
  vwmaccu.vv R1, A_, B8                 // R1 += 19A3B8
  vadd.vv    A_, A_, A_                 // A_  =  2A3
  vwmaccu.vv R4, A_, B1                 // R4 +=  2A3B1
  vwmaccu.vv R6, A_, B3                 // R6 +=  2A3B3
  vwmaccu.vv R8, A_, B5                 // R8 +=  2A3B5
  vwmaccu.vv R0, A_, B7                 // R0 += 38A3B7
  vwmaccu.vv R2, A_, B9                 // R2 += 38A3B9  
.endm

.macro MULTIPLY_A4_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A4
  vmul.vx    B6, B6, C19                // B6  = 19  B6
  vwmaccu.vv R4, A_, B0                 // R4 +=   A4B0
  vwmaccu.vv R5, A_, B1                 // R5 +=   A4B1
  vwmaccu.vv R6, A_, B2                 // R6 +=   A4B2
  vwmaccu.vv R7, A_, B3                 // R7 +=   A4B3
  vwmaccu.vv R8, A_, B4                 // R8 +=   A4B4
  vwmaccu.vv R9, A_, B5                 // R9 +=   A4B5
  vwmaccu.vv R0, A_, B6                 // R0 += 19A4B6
  vwmaccu.vv R1, A_, B7                 // R1 += 19A4B7
  vwmaccu.vv R2, A_, B8                 // R2 += 19A4B8
  vwmaccu.vv R3, A_, B9                 // R3 += 19A4B9
.endm

.macro MULTIPLY_A5_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A5
  vmul.vx    B5, B5, C19                // B5  = 19  B5
  vwmaccu.vv R5, A_, B0                 // R5 +=   A5B0
  vwmaccu.vv R7, A_, B2                 // R7 +=   A5B2
  vwmaccu.vv R9, A_, B4                 // R9 +=   A5B4
  vwmaccu.vv R1, A_, B6                 // R1 += 19A5B6
  vwmaccu.vv R3, A_, B8                 // R3 += 19A5B8
  vadd.vv    A_, A_, A_                 // A_  =  2A5
  vwmaccu.vv R6, A_, B1                 // R6 +=  2A5B1
  vwmaccu.vv R8, A_, B3                 // R8 +=  2A5B3
  vwmaccu.vv R0, A_, B5                 // R0 += 38A5B5
  vwmaccu.vv R2, A_, B7                 // R2 += 38A5B7
  vwmaccu.vv R4, A_, B9                 // R4 += 38A5B9
.endm

.macro MULTIPLY_A6_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A6
  vmul.vx    B4, B4, C19                // B4  = 19  B4
  vwmaccu.vv R6, A_, B0                 // R6 +=   A6B0
  vwmaccu.vv R7, A_, B1                 // R7 +=   A6B1
  vwmaccu.vv R8, A_, B2                 // R8 +=   A6B2
  vwmaccu.vv R9, A_, B3                 // R9 +=   A6B3
  vwmaccu.vv R0, A_, B4                 // R0 += 19A6B4
  vwmaccu.vv R1, A_, B5                 // R1 += 19A6B5
  vwmaccu.vv R2, A_, B6                 // R2 += 19A6B6
  vwmaccu.vv R3, A_, B7                 // R3 += 19A6B7
  vwmaccu.vv R4, A_, B8                 // R4 += 19A6B8
  vwmaccu.vv R5, A_, B9                 // R5 += 19A6B9
.endm

.macro MULTIPLY_A7_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A7
  vmul.vx    B3, B3, C19                // A_  = 19  B3
  vwmaccu.vv R7, A_, B0                 // R7 +=   A7B0
  vwmaccu.vv R9, A_, B2                 // R9 +=   A7B2
  vwmaccu.vv R1, A_, B4                 // R1 += 19A7B4
  vwmaccu.vv R3, A_, B6                 // R3 += 19A7B6
  vwmaccu.vv R5, A_, B8                 // R5 += 19A7B8
  vadd.vv    A_, A_, A_                 // A_  =  2A7
  vwmaccu.vv R8, A_, B1                 // R8 +=  2A7B1
  vwmaccu.vv R0, A_, B3                 // R0 += 38A7B3
  vwmaccu.vv R2, A_, B5                 // R2 += 38A7B5
  vwmaccu.vv R4, A_, B7                 // R4 += 38A7B7
  vwmaccu.vv R6, A_, B9                 // R6 += 38A7B9

.endm

.macro MULTIPLY_A8_LMUL1
  LOAD_OPERAND_A_LMUL1                  // A_  =   A8
  vmul.vx    B2, B2, C19                // B2  = 19  B2
  vwmaccu.vv R8, A_, B0                 // R8 +=   A8B0
  vwmaccu.vv R9, A_, B1                 // R9 +=   A8B1
  vwmaccu.vv R0, A_, B2                 // R0 += 19A8B2
  vwmaccu.vv R1, A_, B3                 // R1 += 19A8B3
  vwmaccu.vv R2, A_, B4                 // R2 += 19A8B4
  vwmaccu.vv R3, A_, B5                 // R3 += 19A8B5
  vwmaccu.vv R4, A_, B6                 // R4 += 19A8B6
  vwmaccu.vv R5, A_, B7                 // R5 += 19A8B7
  vwmaccu.vv R6, A_, B8                 // R6 += 19A8B8
  vwmaccu.vv R7, A_, B9                 // R7 += 19A8B9
.endm

.macro MULTIPLY_A9_LMUL1
  vle32.v    A_, (a1)                   // A_  =   A9
  vmul.vx    B1, B1, C19                // B1  = 19B1
  vwmaccu.vv R9, A_, B0                 // R9 +=   A9B0
  vwmaccu.vv R1, A_, B2                 // R1 += 19A9B2
  vwmaccu.vv R3, A_, B4                 // R3 += 19A9B4
  vwmaccu.vv R5, A_, B6                 // R5 += 19A9B6
  vwmaccu.vv R7, A_, B8                 // R7 += 19A9B8
  vadd.vv    A_, A_, A_                 // A_  =  2A9
  vwmaccu.vv R0, A_, B1                 // R0 += 38A9B1
  vwmaccu.vv R2, A_, B3                 // R2 += 38A9B3
  vwmaccu.vv R4, A_, B5                 // R4 += 38A9B5
  vwmaccu.vv R6, A_, B7                 // R6 += 38A9B7
  vwmaccu.vv R8, A_, B9                 // R8 += 38A9B9
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


// (4x1)-way field multiplication 

.section .text

// v0: conventional operand-scanning 

.global gfp_mul_4x1w_v0

gfp_mul_4x1w_v0:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  //
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B9
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
  vle32.v B0, (a2)                      // load 8 LS-limbs of "b" to B0-B7
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a2, a2, 128                   // 
  vle32.v B8, (a2)                      // load 2 MS-limbs of "b" to B8-B9
.endm

.macro STORE_RESULT_R_LMUL82
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vse32.v B0, (a0)                      // store 8 LS-limbs of "r" to memory
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a0, a0, 128                   // 
  vse32.v B8, (a0)                      // store 2 MS-limbs of "r" to memory
.endm


.global gfp_mul_4x1w_v1

gfp_mul_4x1w_v1:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  //
  LOAD_OPERAND_B_LMUL82                 // load operand "b" to B0-B9
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
  LOAD_OPERAND_A_LMUL1                  // A_         =   A0
  vmv1r.v    _A, A_                     // _A || A_   =   A0   ||   A0
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmulu.vv  R0, A_, B0                 // R1 || R0   =   A0B1 ||   A0B0 
  vwmulu.vv  R2, A_, B2                 // R3 || R2   =   A0B3 ||   A0B2 
  vwmulu.vv  R4, A_, B4                 // R5 || R4   =   A0B5 ||   A0B4 
  vwmulu.vv  R6, A_, B6                 // R7 || R6   =   A0B7 ||   A0B6 
  vwmulu.vv  R8, A_, B8                 // R9 || R8   =   A0B9 ||   A0B8   
  vsetvli    t0, t1, e32, m1            // LMUL = 1
.endm 

.macro MULTIPLY_A2_LMUL2
  LOAD_OPERAND_A_LMUL1                  // A_         =   A2
  vmv1r.v    _A, A_                     // _A || A_   =   A2   ||   A2
  vmul.vx    B8, B8, C19                // B8         = 19  B8
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmaccu.vv R2, A_, B0                 // R3  || R2 +=   A2B1 ||   A2B0
  vwmaccu.vv R4, A_, B2                 // R5  || R4 +=   A2B3 ||   A2B1
  vwmaccu.vv R6, A_, B4                 // R7  || R6 +=   A2B5 ||   A2B4
  vwmaccu.vv R8, A_, B6                 // R9  || R8 +=   A2B7 ||   A2B6
  vwmaccu.vv R0, A_, B8                 // R1  || R0 += 19A2B9 || 19A2B8
  vsetvli    t0, t1, e32, m1            // LMUL = 1
.endm

.macro MULTIPLY_A4_LMUL2 
  LOAD_OPERAND_A_LMUL1                  // A_         =   A4
  vmv1r.v    _A, A_                     // _A || A_   =   A4   ||   A4
  vmul.vx    B6, B6, C19                // B6         = 19  B6
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmaccu.vv R4, A_, B0                 // R5  || R4 +=   A4B1 ||   A4B0
  vwmaccu.vv R6, A_, B2                 // R7  || R6 +=   A4B3 ||   A4B2
  vwmaccu.vv R8, A_, B4                 // R9  || R8 +=   A4B5 ||   A4B4
  vwmaccu.vv R0, A_, B6                 // R1  || R0 += 19A4B7 || 19A4B6
  vwmaccu.vv R2, A_, B8                 // R3  || R2 += 19A4B9 || 19A4B8
  vsetvli    t0, t1, e32, m1            // LMUL = 1
.endm

.macro MULTIPLY_A6_LMUL2 
  LOAD_OPERAND_A_LMUL1                  // A_         =   A6
  vmv1r.v    _A, A_                     // _A || A_   =   A6   ||   A6
  vmul.vx    B4, B4, C19                // B4         = 19  B4
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmaccu.vv R6, A_, B0                 // R7  || R6 +=   A6B1 ||   A6B0
  vwmaccu.vv R8, A_, B2                 // R9  || R8 +=   A6B3 ||   A6B2
  vwmaccu.vv R0, A_, B4                 // R1  || R0 += 19A6B5 || 19A6B4
  vwmaccu.vv R2, A_, B6                 // R3  || R2 += 19A6B7 || 19A6B6
  vwmaccu.vv R4, A_, B8                 // R5  || R4 += 19A6B9 || 19A6B8
  vsetvli    t0, t1, e32, m1            // LMUL = 1
.endm 

.macro MULTIPLY_A8_LMUL2                
  LOAD_OPERAND_A_LMUL1                  // A_         =   A8
  vmv1r.v    _A, A_                     // _A  || A_  =   A8   ||   A8
  vmul.vx    B2, B2, C19                // B2         = 19  B2
  vsetvli    t0, t1, e32, m2            // LMUL = 2
  vwmaccu.vv R8, A_, B0                 // R9  || R8 +=   A8B1 ||   A8B0
  vwmaccu.vv R0, A_, B2                 // R1  || R0 += 19A8B3 || 19A8B2
  vwmaccu.vv R2, A_, B4                 // R3  || R2 += 19A8B5 || 19A8B4
  vwmaccu.vv R4, A_, B6                 // R5  || R4 += 19A8B7 || 19A8B6
  vwmaccu.vv R6, A_, B8                 // R7  || R6 += 19A8B9 || 19A8B8
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


.global gfp_mul_4x1w_v2

gfp_mul_4x1w_v2:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  li      t1,  -1                       // VL  = VLMAX
  //
  LOAD_OPERAND_B_LMUL82                 // load operand "b" to B0-B9
  vsetvli t0, t1, e32, m1               // LMUL = 1
  MULTIPLY_A0_LMUL2                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL2                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL2                     //
  MULTIPLY_A5_LMUL1                     //
  MULTIPLY_A6_LMUL2                     //
  MULTIPLY_A7_LMUL1                     //
  MULTIPLY_A8_LMUL2                     //
  MULTIPLY_A9_LMUL1                     //
  CARRY_PROPAGATION_WVEC_LMUL2          //
  STORE_RESULT_R_LMUL82                 // store result "r" R0-R9 to memory 
  //
  ret

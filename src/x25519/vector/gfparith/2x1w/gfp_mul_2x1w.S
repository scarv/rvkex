// void gfp_mul_2x1w(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
// radix-51 + vmul vmulhu


// meaningful names for registers and constants

// result "r"
#define R0L v16
#define R0H v17
#define R1L v18
#define R1H v19
#define R2L v20
#define R2H v21
#define R3L v22
#define R3H v23
#define R4L v6
#define R4H v7

// operand "b"
#define B0  v8 
#define B1  v9 
#define B2  v10 
#define B3  v11
#define B4  v12 

// operand "a"
#define A0  v24
#define A1  v25 
#define A2  v26
#define A3  v27
#define A4  v28

// temp "t"
#define TL  v4
#define TH  v5

// carry 
#define C_  v0
#define CL  v2 
#define CH  v3

// constants and masks
#define C19 t3                          // 19
#define C51 t4                          // 51
#define M51 v1                          // 2^51 - 1 || 2^51 - 1


// load operands "a" "b" + store result "r" 

.macro LOAD_OPERAND_A_LMUL1
  vle64.v  A0, (a1)
  addi     a1,  a1, 16
  vle64.v  A1, (a1)
  addi     a1,  a1, 16
  vle64.v  A2, (a1)
  addi     a1,  a1, 16
  vle64.v  A3, (a1)
  addi     a1,  a1, 16
  vle64.v  A4, (a1)
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle64.v  B0, (a2)
  addi     a2,  a2, 16
  vle64.v  B1, (a2)
  addi     a2,  a2, 16
  vle64.v  B2, (a2)
  addi     a2,  a2, 16
  vle64.v  B3, (a2)
  addi     a2,  a2, 16
  vle64.v  B4, (a2)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse64.v  B0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  B1, (a0)
  addi     a0,  a0, 16 
  vse64.v  B2, (a0) 
  addi     a0,  a0, 16 
  vse64.v  B3, (a0)
  addi     a0,  a0, 16 
  vse64.v  B4, (a0) 
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  vmul.vv   R0L, A0, B0                 // R0  =   A0B0
  vmulhu.vv R0H, A0, B0                 
  vmul.vv   R1L, A0, B1                 // R1  =   A0B1
  vmulhu.vv R1H, A0, B1
  vmul.vv   R2L, A0, B2                 // R2  =   A0B2 
  vmulhu.vv R2H, A0, B2
  vmul.vv   R3L, A0, B3                 // R3  =   A0B3
  vmulhu.vv R3H, A0, B3 
  vmul.vv   R4L, A0, B4                 // R4  =   A0B4
  vmulhu.vv R4H, A0, B4 
.endm

.macro MULTIPLY_A1_LMUL1
  vmul.vx   B4,  B4, C19                // B4  = 19  B4
  vmul.vv   TL,  A1, B0                 // T   =   A1B0
  vmulhu.vv TH,  A1, B0
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 +=   A1B0
  vadc.vvm  R1H, TH, R1H, C_ 
  vmul.vv   TL,  A1, B1                 // T   =   A1B1
  vmulhu.vv TH,  A1, B1 
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 +=   A1B1
  vadc.vvm  R2H, TH, R2H, C_
  vmul.vv   TL,  A1, B2                 // T   =   A1B2
  vmulhu.vv TH,  A1, B2 
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 +=   A1B2
  vadc.vvm  R3H, TH, R3H, C_
  vmul.vv   TL,  A1, B3                 // T   =   A1B3
  vmulhu.vv TH,  A1, B3 
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=   A1B3
  vadc.vvm  R4H, TH, R4H, C_
  vmul.vv   TL,  A1, B4                 // T   = 19A1B4
  vmulhu.vv TH,  A1, B4 
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 19A1B4
  vadc.vvm  R0H, TH, R0H, C_
.endm

.macro MULTIPLY_A2_LMUL1
  vmul.vx   B3,  B3, C19                // B3  = 19  B3
  vmul.vv   TL,  A2, B0                 // T   =   A2B0
  vmulhu.vv TH,  A2, B0
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 +=   A2B0
  vadc.vvm  R2H, TH, R2H, C_ 
  vmul.vv   TL,  A2, B1                 // T   =   A2B1
  vmulhu.vv TH,  A2, B1
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 +=   A2B1
  vadc.vvm  R3H, TH, R3H, C_ 
  vmul.vv   TL,  A2, B2                 // T   =   A2B2
  vmulhu.vv TH,  A2, B2
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=   A2B2
  vadc.vvm  R4H, TH, R4H, C_ 
  vmul.vv   TL,  A2, B3                 // T   = 19A2B3
  vmulhu.vv TH,  A2, B3
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 19A2B3
  vadc.vvm  R0H, TH, R0H, C_  
  vmul.vv   TL,  A2, B4                 // T   = 19A2B4
  vmulhu.vv TH,  A2, B4
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 += 19A2B4
  vadc.vvm  R1H, TH, R1H, C_   
.endm

.macro MULTIPLY_A3_LMUL1
  vmul.vx   B2,  B2, C19                // B2  = 19  B2
  vmul.vv   TL,  A3, B0                 // T   =   A3B0
  vmulhu.vv TH,  A3, B0
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 +=   A3B0
  vadc.vvm  R3H, TH, R3H, C_   
  vmul.vv   TL,  A3, B1                 // T   =   A3B1
  vmulhu.vv TH,  A3, B1
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=   A3B1
  vadc.vvm  R4H, TH, R4H, C_   
  vmul.vv   TL,  A3, B2                 // T   = 19A3B2
  vmulhu.vv TH,  A3, B2
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 19A3B2
  vadc.vvm  R0H, TH, R0H, C_
  vmul.vv   TL,  A3, B3                 // T   = 19A3B3
  vmulhu.vv TH,  A3, B3
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 += 19A3B3
  vadc.vvm  R1H, TH, R1H, C_
  vmul.vv   TL,  A3, B4                 // T   = 19A3B4
  vmulhu.vv TH,  A3, B4
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 += 19A3B4
  vadc.vvm  R2H, TH, R2H, C_
.endm

.macro MULTIPLY_A4_LMUL1
  vmul.vx   B1,  B1, C19                // B1  = 19  B1
  vmul.vv   TL,  A4, B0                 // T   =   A4B0
  vmulhu.vv TH,  A4, B0
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=   A4B0
  vadc.vvm  R4H, TH, R4H, C_ 
  vmul.vv   TL,  A4, B1                 // T   = 19A4B1
  vmulhu.vv TH,  A4, B1
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 19A4B1
  vadc.vvm  R0H, TH, R0H, C_ 
  vmul.vv   TL,  A4, B2                 // T   = 19A4B2
  vmulhu.vv TH,  A4, B2
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 += 19A4B2
  vadc.vvm  R1H, TH, R1H, C_   
  vmul.vv   TL,  A4, B3                 // T   = 19A4B3
  vmulhu.vv TH,  A4, B3
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 += 19A4B3
  vadc.vvm  R2H, TH, R2H, C_
  vmul.vv   TL,  A4, B4                 // T   = 19A4B4
  vmulhu.vv TH,  A4, B4
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 += 19A4B4
  vadc.vvm  R3H, TH, R3H, C_      
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  vle64.v  M51, (a3)
  vxor.vv  TL,  TL,  TL

  vand.vv  B0,  R0L, M51                // B0 = R0 & M51              
  vsrl.vx  CL,  R0L, C51                // CL = R0 >> 51
  vsll.vi  CH,  R0H, 13    
  vxor.vv  CL,  CL,  CH                 // CL = R0 >> 51 & (2^64-1)
  
  vmadc.vv C_,  R1L, CL               
  vadd.vv  R1L, R1L, CL                 // R1 = R1 + CL
  vadc.vvm R1H, R1H, TL, C_

  vand.vv  B1,  R1L, M51                // B1 = R1 & M51
  vsrl.vx  CL,  R1L, C51                // C  = R1 >> 51
  vsll.vi  CH,  R1H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R2L, CL               
  vadd.vv  R2L, R2L, CL                 // R2 = R2 + CL
  vadc.vvm R2H, R2H, TL, C_
  vand.vv  B2,  R2L, M51                // B2 = R2 & M51
  vsrl.vx  CL,  R2L, C51                // C  = R2 >> 51
  vsll.vi  CH,  R2H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R3L, CL               
  vadd.vv  R3L, R3L, CL                 // R3 = R3 + CL
  vadc.vvm R3H, R3H, TL, C_
  vand.vv  B3,  R3L, M51                // B3 = R3 & M51
  vsrl.vx  CL,  R3L, C51                // CL = R3 >> 51
  vsll.vi  CH,  R3H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R4L, CL               
  vadd.vv  R4L, R4L, CL                 // R4 = R4 + CL
  vadc.vvm R4H, R4H, TL, C_ 
  vand.vv  B4,  R4L, M51                // B4 = R4 & M51
  vsrl.vx  CL,  R4L, C51                // CL = R4 >> 51
  vsll.vi  CH,  R4H, 13                 // R4 < 110b < 51+64 
  vxor.vv  CL,  CL,  CH

  vmacc.vx B0,  C19, CL                 // B0 = B0 + 19CL
  vsrl.vx  CL,  B0,  C51
  vand.vv  B0,  B0,  M51 
  vadd.vv  B1,  B1,  CL
.endm


// (2x1)-way field multiplication 

.section .text

// v0: conventional operand-scanning 

.global gfp_mul_2x1w_v0

gfp_mul_2x1w_v0: 
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B4
  MULTIPLY_A0_LMUL1                     // 
  MULTIPLY_A1_LMUL1                     // 
  MULTIPLY_A2_LMUL1                     // 
  MULTIPLY_A3_LMUL1                     // 
  MULTIPLY_A4_LMUL1                     // 
  CARRY_PROPAGATION                     //  
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  // 
  ret 


// v1: uses register group to load/store (LMUL = 5)

.global gfp_mul_2x1w_v1

gfp_mul_2x1w_v1:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  10                       // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5  
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vle64.v B0, (a2)                      // load operand "b" to B0-B4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  CARRY_PROPAGATION                     //
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v B0, (a0)                      // store result "r" to memory 
  //
  ret 

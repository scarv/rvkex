// void gfp_sqr_2x1w(vec2 *r, const vec2 *a, const vec2 *m);
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
#define R4L v24
#define R4H v25

// operand "a"
#define A0  v8
#define A1  v9 
#define A2  v10
#define A3  v11
#define A4  v12

// temp "t"
#define TL  v4
#define TH  v5

// carry 
#define C_  v0
#define CL  v2
#define CH  v3

// constants and masks
#define C19 t2                          // 19
#define C51 t3                          // 51  
#define M51 v1                          // 2^51 - 1 || 2^51 - 1


// load operand "a" + store result "r" 

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

.macro STORE_RESULT_R_LMUL1 
  vse64.v  A0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  A1, (a0)
  addi     a0,  a0, 16 
  vse64.v  A2, (a0) 
  addi     a0,  a0, 16 
  vse64.v  A3, (a0)
  addi     a0,  a0, 16 
  vse64.v  A4, (a0) 
.endm

// interleaved squaring and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  vmul.vv   R0L, A0, A0                 // R0  =   A0A0
  vmulhu.vv R0H, A0, A0 
  vadd.vv   A0,  A0, A0                 // A0  =  2A0
  vmul.vv   R1L, A0, A1                 // R1  =  2A0A1
  vmulhu.vv R1H, A0, A1 
  vmul.vv   R2L, A0, A2                 // R2  =  2A0A2 
  vmulhu.vv R2H, A0, A2
  vmul.vv   R3L, A0, A3                 // R3  =  2A0A3
  vmulhu.vv R3H, A0, A3 
  vmul.vv   R4L, A0, A4                 // R4  =  2A0A4
  vmulhu.vv R4H, A0, A4
.endm

.macro MULTIPLY_A1_LMUL1
  vmul.vx   A0,  A4, C19                // A0  = 19  A4
  vmul.vv   TL,  A1, A1                 // T   =   A1A1
  vmulhu.vv TH,  A1, A1 
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 +=   A1A1
  vadc.vvm  R2H, TH, R2H, C_
  vadd.vv   A1,  A1, A1                 // A1  =  2A1
  vmul.vv   TL,  A1, A2                 // T   =  2A1A2
  vmulhu.vv TH,  A1, A2 
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 +=  2A1A2
  vadc.vvm  R3H, TH, R3H, C_
  vmul.vv   TL,  A1, A3                 // T   =  2A1A3
  vmulhu.vv TH,  A1, A3 
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=  2A1A3
  vadc.vvm  R4H, TH, R4H, C_
  vmul.vv   TL,  A1, A0                 // T   = 38A1A4
  vmulhu.vv TH,  A1, A0 
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 38A1A4
  vadc.vvm  R0H, TH, R0H, C_
.endm

.macro MULTIPLY_A2_LMUL1
  vmul.vx   A1,  A3, C19                // A1  = 19  A3
  vmul.vv   TL,  A2, A2                 // T   =   A2A2
  vmulhu.vv TH,  A2, A2 
  vmadc.vv  C_,  TL, R4L
  vadd.vv   R4L, TL, R4L                // R4 +=   A2A2
  vadc.vvm  R4H, TH, R4H, C_
  vadd.vv   A2,  A2, A2                 // A2  =  2A2
  vmul.vv   TL,  A2, A1                 // T   = 38A2A3
  vmulhu.vv TH,  A2, A1 
  vmadc.vv  C_,  TL, R0L
  vadd.vv   R0L, TL, R0L                // R0 += 38A2A3
  vadc.vvm  R0H, TH, R0H, C_
  vmul.vv   TL,  A2, A0                 // T   = 38A2A4
  vmulhu.vv TH,  A2, A0 
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 += 38A2A4
  vadc.vvm  R1H, TH, R1H, C_  
.endm

.macro MULTIPLY_A3_LMUL1
  vmul.vv   TL,  A3, A1                 // T   = 19A3A3
  vmulhu.vv TH,  A3, A1 
  vmadc.vv  C_,  TL, R1L
  vadd.vv   R1L, TL, R1L                // R1 += 19A3A3
  vadc.vvm  R1H, TH, R1H, C_
  vadd.vv   A3,  A3, A3                 // A3  =  2A3
  vmul.vv   TL,  A3, A0                 // T   = 38A3A4
  vmulhu.vv TH,  A3, A0 
  vmadc.vv  C_,  TL, R2L
  vadd.vv   R2L, TL, R2L                // R2 += 38A3A4
  vadc.vvm  R2H, TH, R2H, C_  
.endm

.macro MULTIPLY_A4_LMUL1
  vmul.vv   TL,  A4, A0                 // T   = 19A4A4
  vmulhu.vv TH,  A4, A0 
  vmadc.vv  C_,  TL, R3L
  vadd.vv   R3L, TL, R3L                // R3 += 19A4A4
  vadc.vvm  R3H, TH, R3H, C_
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  vle64.v  M51, (a2)
  vxor.vv  TL,  TL,  TL

  vand.vv  A0,  R0L, M51                // A0 = R0 & M51              
  vsrl.vx  CL,  R0L, C51                // CL = R0 >> 51
  vsll.vi  CH,  R0H, 13    
  vxor.vv  CL,  CL,  CH                 // CL = R0 >> 51 & (2^64-1)
  
  vmadc.vv C_,  R1L, CL               
  vadd.vv  R1L, R1L, CL                 // R1 = R1 + CL
  vadc.vvm R1H, R1H, TL, C_

  vand.vv  A1,  R1L, M51                // A1 = R1 & M51
  vsrl.vx  CL,  R1L, C51                // C  = R1 >> 51
  vsll.vi  CH,  R1H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R2L, CL               
  vadd.vv  R2L, R2L, CL                 // R2 = R2 + CL
  vadc.vvm R2H, R2H, TL, C_
  vand.vv  A2,  R2L, M51                // A2 = R2 & M51
  vsrl.vx  CL,  R2L, C51                // C  = R2 >> 51
  vsll.vi  CH,  R2H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R3L, CL               
  vadd.vv  R3L, R3L, CL                 // R3 = R3 + CL
  vadc.vvm R3H, R3H, TL, C_
  vand.vv  A3,  R3L, M51                // A3 = R3 & M51
  vsrl.vx  CL,  R3L, C51                // CL = R3 >> 51
  vsll.vi  CH,  R3H, 13    
  vxor.vv  CL,  CL,  CH

  vmadc.vv C_,  R4L, CL               
  vadd.vv  R4L, R4L, CL                 // R4 = R4 + CL
  vadc.vvm R4H, R4H, TL, C_ 
  vand.vv  A4,  R4L, M51                // A4 = R4 & M51
  vsrl.vx  CL,  R4L, C51                // CL = R4 >> 51
  vsll.vi  CH,  R4H, 13                 // R4 < 110b < 51+64 
  vxor.vv  CL,  CL,  CH

  vmacc.vx A0,  C19, CL                 // A0 = A0 + 19CL
  vsrl.vx  CL,  A0,  C51
  vand.vv  A0,  A0,  M51 
  vadd.vv  A1,  A1,  CL
.endm


// (2x1)-way field squaring 

.section .text

// v0: conventional operand-scanning 

.global gfp_sqr_2x1w_v0

gfp_sqr_2x1w_v0: 
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  MULTIPLY_A0_LMUL1
  MULTIPLY_A1_LMUL1
  MULTIPLY_A2_LMUL1
  MULTIPLY_A3_LMUL1
  MULTIPLY_A4_LMUL1
  CARRY_PROPAGATION
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  // 
  ret 


// v1: uses register group to load/store (LMUL = 5)

.global gfp_sqr_2x1w_v1

gfp_sqr_2x1w_v1: 
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  10                       // VL  = VLMAX
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5  
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  MULTIPLY_A0_LMUL1
  MULTIPLY_A1_LMUL1
  MULTIPLY_A2_LMUL1
  MULTIPLY_A3_LMUL1
  MULTIPLY_A4_LMUL1
  CARRY_PROPAGATION
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v A0, (a0)                      // store result "r" to memory 
  // 
  ret 
// void gfp_mul51_2x1w(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
// radix-51 + vmul vmulhu


// meaningful names for registers and constants

// result "r"
#define R0L v16
#define R1L v17
#define R2L v18
#define R3L v19
#define R4L v28

#define R0H v20
#define R1H v21
#define R2H v22
#define R3H v23
#define R4H v29

// operand "b"
#define B0  v24
#define B1  v25
#define B2  v26
#define B3  v27 

// operand "a"
#define A0  v8
#define A1  v9 
#define A2  v10
#define A3  v11
#define A4  v12

// carry 
#define C_  v0
#define CL  v2 
#define CH  v3
#define TL  v4

// constants and masks
#define C19 t2                          // 19
#define C51 t3                          // 51  
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

// multiplication 

.macro MULTIPLY_B0_LMUL1
  vmul.vv   R0L, A0, B0                 // R0  =   A0B0
  vmulhu.vv R0H, A0, B0                 
  vmul.vv   R1L, A1, B0                 // R1  =   A1B0
  vmulhu.vv R1H, A1, B0
  vmul.vv   R2L, A2, B0                 // R2  =   A2B0 
  vmulhu.vv R2H, A2, B0
  vmul.vv   R3L, A3, B0                 // R3  =   A3B0
  vmulhu.vv R3H, A3, B0 
  vmul.vv   R4L, A4, B0                 // R4  =   A4B0
  vmulhu.vv R4H, A4, B0 
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  vle64.v  M51, (a3)
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


// (2x1)-way field mul51

.section .text

// v0: conventional one

.global gfp_mul51_2x1w_v0

gfp_mul51_2x1w_v0:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  //
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0
  MULTIPLY_B0_LMUL1                     //
  CARRY_PROPAGATION                     //
  STORE_RESULT_R_LMUL1                  // store result "r" to memory
  //
  ret 


// v2: uses register group to load/store and arithmetic computation (LMUL = 1, 4)

.macro MULTIPLY_B0_LMUL14
  vmul.vv   R4L, A4, B0                 // R4  =   A4B0
  vmulhu.vv R4H, A4, B0
  vmv1r.v   B1,  B0 
  vmv2r.v   B2,  B0
  vsetvli   t0,  t1, e64, m4            // LMUL = 4
  vmul.vv   R0L, A0, B0 
  vmulhu.vv R0H, A0, B0 
  vsetvli   t0,  t1, e64, m1            // LMUL = 4  
.endm

.global gfp_mul51_2x1w_v2 

gfp_mul51_2x1w_v2:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  li      t4,  10                       // AVL = 2 lanes * 5 registers = 10
  //
  vsetvli t0, t4, e64, m8               // SEW = 64, LMUL = 5
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  //
  vsetvli t0, t1, e64, m1               // LMUL = 1
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0
  MULTIPLY_B0_LMUL14                    //
  CARRY_PROPAGATION                     //
  // 
  vsetvli t0, t4, e64, m8               // LMUL = 5
  vse64.v A0, (a0)                      // store result "r" to memory 
  //
  ret 

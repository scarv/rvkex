// void gfp_sqr_2x1w_ise(vec2 *r, const vec2 *a, const vec2 *m);
// radix-51 + ISE (vmacc51lo + vmacc51hi)


#include "../ise.h"


// meaningful names for registers and constants

// result "r"
#define R0  v16
#define R1  v17 
#define R2  v18 
#define R3  v19 
#define R4  v20
#define R5  v21

// operand "a"
#define A0  v8
#define A1  v9 
#define A2  v10
#define A3  v11
#define A4  v12

// carry 
#define CL  v2 

// constants and masks
#define C19 t3                          // 19
#define C51 t4                          // 51
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
  VMUL51LO     R0, A0, A0               // R0  =   A0B0
  VMUL51HI     R1, A0, A0
  vadd.vv      A0, A0, A0               // A0  =  2A0
  VMAC51LO     R1, A0, A1               // R1  =  2A0A1 
  VMUL51HI     R2, A0, A1
  VMAC51LO     R2, A0, A2               // R2  =  2A0A2  
  VMUL51HI     R3, A0, A2
  VMAC51LO     R3, A0, A3               // R3  =  2A0A3 
  VMUL51HI     R4, A0, A3
  VMAC51LO     R4, A0, A4               // R4  =  2A0A4
  VMUL51HI     R5, A0, A4    
.endm

.macro MULTIPLY_A1_LMUL1
  vmul.vx      A0, A4, C19              // A0  = 19  A4
  VMAC51LO     R2, A1, A1               // R2 +=   A1A1
  VMAC51HI     R3, A1, A1
  vadd.vv      A1, A1, A1               // A1  =  2A1
  VMAC51LO     R3, A1, A2               // R3 +=  2A1A2
  VMAC51HI     R4, A1, A2
  VMAC51LO     R4, A1, A3               // R4 +=  2A1A3
  VMAC51HI     R5, A1, A3
  VMAC51LO     R0, A1, A0               // R0 += 38A1A4
  VMAC51HI     R1, A1, A0   
.endm

.macro MULTIPLY_A2_LMUL1
  vmul.vx      A1, A3, C19              // A1  = 19  A3
  VMAC51LO     R4, A2, A2               // R4 +=   A2A2
  VMAC51HI     R5, A2, A2
  vadd.vv      A2, A2, A2               // A2  =  2A2
  VMAC51LO     R0, A2, A1               // R0 += 38A2A3
  VMAC51HI     R1, A2, A1
  VMAC51LO     R1, A2, A0               // R1 += 38A2A4
  VMAC51HI     R2, A2, A0   
.endm 

.macro MULTIPLY_A3_LMUL1
  VMAC51LO     R1, A3, A1               // R1 += 19A3A3
  VMAC51HI     R2, A3, A1
  vadd.vv      A3, A3, A3               // A3  =  2A3
  VMAC51LO     R2, A3, A0               // R2 += 38A3A4
  VMAC51HI     R3, A3, A0  
.endm 

.macro MULTIPLY_A4_LMUL1
  VMAC51LO     R3, A4, A0               // R3 += 19A4A4
  VMAC51HI     R4, A4, A0
.endm 

// carry propagation 

.macro CARRY_PROPAGATION
  vle64.v      M51, (a2)
  vmacc.vx     R0, C19, R5              // R0 = R0 + 19R5
  vsrl51add.vv R1, R0, R1               // R1 = R1 + R0 >> 51
  vand.vv      A0, R0, M51              // A0 = R0 & M51 
  vsrl51add.vv R2, R1, R2               // R2 = R2 + R1 >> 51
  vand.vv      A1, R1, M51              // A1 = R1 & M51  
  vsrl51add.vv R3, R2, R3               // R3 = R3 + R2 >> 51
  vand.vv      A2, R2, M51              // A2 = R2 & M51
  vsrl51add.vv R4, R3, R4               // R4 = R4 + R3 >> 51 
  vand.vv      A3, R3, M51              // A3 = R3 & M51
  vsrl.vx      CL, R4, C51              // CL = R4 >> 51
  vand.vv      A4, R4, M51              // A4 = R4 & M51  
  vmacc.vx     A0, C19, CL              // A0 = A0 + 19CL
.endm


// (2x1)-way field squaring using ISE 

.section .text

// v0: conventional operand-scanning 

.global gfp_sqr_2x1w_v0_ise

gfp_sqr_2x1w_v0_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
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

.global gfp_sqr_2x1w_v1_ise

gfp_sqr_2x1w_v1_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  10                       // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5 
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  CARRY_PROPAGATION                     //
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v A0, (a0)                      // store result "r" to memory 
  //
  ret
 
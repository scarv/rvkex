// void gfp_mul_1x2w_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
// radix-51 + ISE (vmacc51lo + vmacc51hi)


#include "../ise.h"


// meaningful names for registers and constants

// result "r"
#define R0  v16
#define R1  v17 
#define R2  v18 

// tmp
#define T0  v19
#define T1  v20

// operand "b"
#define B0  v8 
#define B1  v9 
#define B2  v10 
#define D0  v11
#define D1  v12
#define D2  v13
#define B_  v14
#define B3  v15

// operand "a"
#define A0  v24
#define A1  v25 
#define A2  v26
#define A_  v27

// carry 
#define CL  v6 

// constants and masks
#define C19 t2                          // 19  
#define C51 t3                          // 51
#define C1  t4                          //  1
#define M00 v1                          //        0 ||        0
#define M11 v2                          //        1 ||        1
#define M01 v0                          //        0 ||        1
#define M0F v4                          //        0 ||      - 1
#define M51 v5                          // 2^51 - 1 || 2^51 - 1


// load operands "a" "b" + store result "r" + form mask "m"

.macro LOAD_OPERAND_A_LMUL1
  vle64.v  A0, (a1)
  addi     a1,  a1, 16
  vle64.v  A1, (a1)
  addi     a1,  a1, 16
  vle64.v  A2, (a1)
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle64.v  B0, (a2)
  addi     a2,  a2, 16
  vle64.v  B1, (a2)
  addi     a2,  a2, 16
  vle64.v  B2, (a2)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse64.v  B0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  B1, (a0)
  addi     a0,  a0, 16 
  vse64.v  B2, (a0) 
.endm

.macro FORM_MASK_M_LMUL1 
  vxor.vv  v0,  v0, v0                  // v0  = 0
  vmv.s.x  v0,  C1                      // v0.m= 0b01
  vxor.vv  M00, M00, M00                // M00 = 0 || 0
  vmv.v.i  M11, 1                       // M11 = 1 || 1
  vle64.v  M0F, (a3)                    // M0F = 0 || -1            
  addi     a3,   a3, 16
  vle64.v  M51, (a3)                        
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  vrgather.vv  A_, A0, M00              // A_  =   a0   ||   a0
  VMUL51LO     R0, A_, B0               // R0  =   a0b3 ||   a0b0
  VMUL51HI     R1, A_, B0
  VMAC51LO     R1, A_, B1               // R1  =   a0b4 ||   a0b1
  VMUL51HI     T0, A_, B1
  VMUL51LO     R2, A_, B2               // R2  =      0 ||   a0b2
  VMUL51HI     T1, A_, B2      
.endm

.macro MULTIPLY_A1_LMUL1
  vrgather.vv  A_, A1, M00              // A_  =   a1   ||   a1  
  vmul.vx      B3, B1, C19              // B3  = 19  b4 || 19  b1
  vmerge.vvm   B_, B3, B2, v0           // B_  = 19  b4 ||     b2
  vrgather.vv  D2, B_, M01              // D2  =     b2 || 19  b4
  VMAC51LO     R0, A_, D2               // R0 +=   a1b2 || 19a1b4
  VMAC51HI     R1, A_, D2
  VMAC51LO     R1, A_, B0               // R1 +=   a1b3 ||   a1b0
  VMAC51HI     T0, A_, B0
  VMAC51LO     R2, A_, B1               // R2 +=      % ||   a1b1
  VMAC51HI     T1, A_, B1      
.endm 

.macro MULTIPLY_A2_LMUL1
  vrgather.vv  A_, A2, M00              // A_  =   a2   ||   a2  
  vmul.vx      B_, B0, C19              // B_  = 19  b3 || 19  b0
  vmerge.vvm   B_, B_, B1, v0           // B_  = 19  b3 ||     b1
  vrgather.vv  D1, B_, M01              // D1  =     b1 || 19  b3
  VMAC51LO     R0, A_, D1               // R0 +=   a2b1 || 19a2b3
  VMAC51HI     R1, A_, D1
  VMAC51LO     R1, A_, D2               // R1 +=   a2b2 || 19a2b4
  VMAC51HI     T0, A_, D2
  VMAC51LO     R2, A_, B0               // R2 +=      % ||   a2b0
  VMAC51HI     T1, A_, B0
.endm

.macro MULTIPLY_A3_LMUL1
  vrgather.vv  A_, A0, M11              // A_  =   a3   ||   a3
  vmul.vx      B_, B2, C19              // B_  =        || 19  b2
  vrgather.vv  D0, B0, M00              // D0  =     b0 ||     b0
  vmerge.vvm   D0, D0, B_, v0           // D0  =     b0 || 19  b2
  VMAC51LO     R0, A_, D0               // R0 +=   a3b0 || 19a3b2
  VMAC51HI     R1, A_, D0
  VMAC51LO     R1, A_, D1               // R1 +=   a3b1 || 19a3b3
  VMAC51HI     T0, A_, D1
  VMAC51LO     R2, A_, D2               // R2 +=      % || 19a3b4
  VMAC51HI     T1, A_, D2
.endm

.macro MULTIPLY_A4_LMUL1
  vrgather.vv  A_, A1, M11              // A_  =   a4   ||   a4
  VMAC51LO     R0, A_, B3               // R0 += 19a4b4 || 19a4b1
  VMAC51HI     R1, A_, B3
  VMAC51LO     R1, A_, D0               // R1 +=   a4b0 || 19a4b2
  VMAC51HI     T0, A_, D0
  VMAC51LO     R2, A_, D1               // R2 +=      % || 19a4b3
  VMAC51HI     T1, A_, D1
  vand.vv      R2, R2, M0F              // R2  =      0 ||   r2
  vadd.vv      R2, T0, R2
  vand.vv      T1, T1, M0F 
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  vrgather.vv  CL, T1, M01                           
  vadd.vv      R0, R0, CL
  vand.vv      B0, R0, M51              // B0 =  r3&M51  ||  r0&M51
  vsrl51add.vv R1, R0, R1               // R1 =  r4+c3   ||  r1+c0
  vand.vv      B1, R1, M51              // B1 =  r4&M51  ||  r1&M51 
  vsrl51add.vv R2, R1, R2               // R2 =   0+c4   ||  r2+c1
  vand.vv      B2, R2, M51              // B2 =  c4&M51  ||  r2&M51
  vsrl.vx      CL, R2, C51              // CL =  c4>>51  ||  r2>>51 
  vand.vv      B_, CL, M0F              // B_ =       0  ||  r2>>51
  vrgather.vv  CL, B_, M01              // CL =  r2>>51  ||     0
  vadd.vv      B0, B0, CL               // B0 =  r3+c2   ||  r0+0
  vrgather.vv  CL, R2, M01              // CL =  r2      ||    c4 
  vand.vv      CL, CL, M0F              // CL =       0  ||    c4
  vmacc.vx     B0, C19, CL              // B0 =    0+r3  ||  19c4+r0 
  vsrl51add.vv B1, B0, B1              
  vand.vv      B0, B0, M51
.endm 


// (1x2)-way field multiplication 

.section .text

// v0: conventional operand-scanning 

.global gfp_mul_1x2w_v0_ise

gfp_mul_1x2w_v0_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      C1,   1                       // C1  =  1
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A3
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B3
  FORM_MASK_M_LMUL1                     // form the mask "m"
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  CARRY_PROPAGATION                     //
  STORE_RESULT_R_LMUL1                  // store result "r" to memory
  // 
  ret 

// void gfp_mul_1x2w(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
// radix-51 + vmul mulhu


// meaningful names for registers and constants

// result "r"
#define R0L v16
#define R0H v17
#define R1L v18
#define R1H v19
#define R2L v20
#define R2H v21

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

// temp "t"
#define TL  v22
#define TH  v23

// carry 
#define C_  v0
#define CL  v6 
#define CH  v7

// constants and masks
#define C19 t2                          // 19  
#define C51 t3                          // 51
#define C1  t4                          //  1
#define M00 v1                          //        0 ||        0
#define M11 v2                          //        1 ||        1
#define M01 v3                          //        0 ||        1
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
  vxor.vv      M00, M00, M00            // M00 = 0 || 0
  vslide1up.vx M01, M00, C1             // M01 = 0 || 1
  vmv.v.i      M11, 1                   // M11 = 1 || 1
  vle64.v      M0F, (a3)                // M0F = 0 || -1            
  addi         a3,   a3, 16
  vle64.v      M51, (a3)                        
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  vrgather.vv A_,  A0, M00              // A_  =   a0   ||   a0   
  vmul.vv     R0L, A_, B0               // R0  =   a0b3 ||   a0b0
  vmulhu.vv   R0H, A_, B0
  vmul.vv     R1L, A_, B1               // R1  =   a0b4 ||   a0b1
  vmulhu.vv   R1H, A_, B1
  vmul.vv     R2L, A_, B2               // R2  =      % ||   a0b2 
  vmulhu.vv   R2H, A_, B2      
.endm

.macro MULTIPLY_A1_LMUL1
  vrgather.vv A_,  A1, M00              // A_  =   a1   ||   a1  
  vmul.vx     B3,  B1, C19              // B3  = 19  b4 || 19  b1
  vmv.s.x     v0,  C1                   // v0.m= 0b01
  vmerge.vvm  B_,  B3, B2, v0           // B_  = 19  b4 ||     b2
  vrgather.vv D2,  B_, M01              // D2  =     b2 || 19  b4 
  vmul.vv     TL,  A_, D2               // T   =   a1b2 || 19a1b4
  vmulhu.vv   TH,  A_, D2
  vmadc.vv    C_,  TL, R0L
  vadd.vv     R0L, TL, R0L              // R0 +=   a1b2 || 19a1b4
  vadc.vvm    R0H, TH, R0H, C_
  vmul.vv     TL,  A_, B0               // T   =   a1b3 ||   a1b0
  vmulhu.vv   TH,  A_, B0
  vmadc.vv    C_,  TL, R1L
  vadd.vv     R1L, TL, R1L              // R1 +=   a1b3 ||   a1b0
  vadc.vvm    R1H, TH, R1H, C_ 
  vmul.vv     TL,  A_, B1               // T   =      % ||   a1b1
  vmulhu.vv   TH,  A_, B1 
  vmadc.vv    C_,  TL, R2L
  vadd.vv     R2L, TL, R2L              // R2 +=      % ||   a1b1
  vadc.vvm    R2H, TH, R2H, C_
.endm

.macro MULTIPLY_A2_LMUL1
  vrgather.vv A_,  A2, M00              // A_  =   a2   ||   a2  
  vmul.vx     B_,  B0, C19              // B_  = 19  b3 || 19  b0
  vmv.s.x     v0,  C1                   // v0.m= 0b01
  vmerge.vvm  B_,  B_, B1, v0           // B_  = 19  b3 ||     b1
  vrgather.vv D1,  B_, M01              // D1  =     b1 || 19  b3 
  vmul.vv     TL,  A_, D1               // T   =   a2b1 || 19a2b3
  vmulhu.vv   TH,  A_, D1
  vmadc.vv    C_,  TL, R0L
  vadd.vv     R0L, TL, R0L              // R0 +=   a2b1 || 19a2b3
  vadc.vvm    R0H, TH, R0H, C_
  vmul.vv     TL,  A_, D2               // T   =   a2b2 || 19a2b4
  vmulhu.vv   TH,  A_, D2
  vmadc.vv    C_,  TL, R1L
  vadd.vv     R1L, TL, R1L              // R1 +=   a2b2 || 19a2b4
  vadc.vvm    R1H, TH, R1H, C_ 
  vmul.vv     TL,  A_, B0               // T   =      % ||   a2b0
  vmulhu.vv   TH,  A_, B0 
  vmadc.vv    C_,  TL, R2L
  vadd.vv     R2L, TL, R2L              // R2 +=      % ||   a2b0
  vadc.vvm    R2H, TH, R2H, C_

.endm

.macro MULTIPLY_A3_LMUL1
  vrgather.vv A_,  A0, M11              // A_  =   a3   ||   a3
  vmul.vx     B_,  B2, C19              // B_  =        || 19  b2
  vrgather.vv TL,  B0, M00              // TL  =     b0 ||     b0
  vmv.s.x     v0,  C1                   // v0.m= 0b01
  vmerge.vvm  D0,  TL, B_, v0           // D0  =     b0 || 19  b2
  vmul.vv     TL,  A_, D0               // T   =   a3b0 || 19a3b2
  vmulhu.vv   TH,  A_, D0
  vmadc.vv    C_,  TL, R0L
  vadd.vv     R0L, TL, R0L              // R0 +=   a3b0 || 19a3b2
  vadc.vvm    R0H, TH, R0H, C_   
  vmul.vv     TL,  A_, D1               // T   =   a3b1 || 19a3b3
  vmulhu.vv   TH,  A_, D1
  vmadc.vv    C_,  TL, R1L
  vadd.vv     R1L, TL, R1L              // R1 +=   a3b1 || 19a3b3
  vadc.vvm    R1H, TH, R1H, C_ 
  vmul.vv     TL,  A_, D2               // T   =      % || 19a3b4
  vmulhu.vv   TH,  A_, D2 
  vmadc.vv    C_,  TL, R2L
  vadd.vv     R2L, TL, R2L              // R2 +=      % || 19a3b4
  vadc.vvm    R2H, TH, R2H, C_
.endm

.macro MULTIPLY_A4_LMUL1
  vrgather.vv A_,  A1, M11              // A_  =   a4   ||   a4
  vmul.vv     TL,  A_, B3               // T   = 19a4b4 || 19a4b1
  vmulhu.vv   TH,  A_, B3
  vmadc.vv    C_,  TL, R0L
  vadd.vv     R0L, TL, R0L              // R0 += 19a4b4 || 19a4b1
  vadc.vvm    R0H, TH, R0H, C_   
  vmul.vv     TL,  A_, D0               // T   =   a4b0 || 19a4b2
  vmulhu.vv   TH,  A_, D0
  vmadc.vv    C_,  TL, R1L
  vadd.vv     R1L, TL, R1L              // R1 +=   a4b0 || 19a4b2
  vadc.vvm    R1H, TH, R1H, C_ 
  vmul.vv     TL,  A_, D1               // T   =      % || 19a4b3
  vmulhu.vv   TH,  A_, D1 
  vmadc.vv    C_,  TL, R2L
  vadd.vv     R2L, TL, R2L              // R2 +=      % || 19a4b3
  vadc.vvm    R2H, TH, R2H, C_

  vand.vv     R2L, R2L, M0F             // R2  =      0 ||    r2
  vand.vv     R2H, R2H, M0F 
.endm

.macro CARRY_PROPAGATION
  vand.vv     B0,  R0L, M51             // B0 =  r3&M51  ||  r0&M51 
  vsrl.vx     CL,  R0L, C51             // CL =  r3>>51  ||  r0>>51
  vsll.vi     CH,  R0H, 13  
  vxor.vv     CL,  CL,  CH              // CL =  r3>>51  ||  r0>>51
  vsrl.vx     CH,  R0H, C51             // CH =  r3>>115 ||  r0>>115

  vmadc.vv    C_,  R1L, CL               
  vadd.vv     R1L, R1L, CL              // R1 =  r4+c3   ||  r1+c0
  vadc.vvm    R1H, R1H, CH, C_ 
  vand.vv     B1,  R1L, M51             // B1 =  r4&M51  ||  r1&M51 
  vsrl.vx     CL,  R1L, C51             // CL =  r4>>51  ||  r1>>51
  vsll.vi     CH,  R1H, 13  
  vxor.vv     CL,  CL,  CH              // CL =  r4>>51  ||  r1>>51
  vsrl.vx     CH,  R1H, C51             // CH =  r4>>115 ||  r1>>115

  vmadc.vv    C_,  R2L, CL               
  vadd.vv     R2L, R2L, CL              // R2 =   0+c4   ||  r2+c1
  vadc.vvm    R2H, R2H, CH, C_
  vand.vv     B2,  R2L, M51             // B2 =  c4&M51  ||  r2&M51 
  vsrl.vx     CL,  R2L, C51             // CL =  c4>>51  ||  r2>>51
  vsll.vi     CH,  R2H, 13               
  vxor.vv     CL,  CL,  CH              // CL =  c4>>51  ||  r2>>51
  vsrl.vx     CH,  R1H, C51             // CH =       0  ||  r2>>115
  vsll.vi     CH,  CH,  13

  vand.vv     CL,  CL,  M0F             // CL =       0  ||  r2>>51
  vrgather.vv TL,  CL,  M01             // CL =  r2>>51  ||       0
  vrgather.vv TH,  CH,  M01             // TH =  r2>>115 ||       0
  vadd.vv     B0,  B0,  TL              // B0 =  r3+c2   ||  r0+0
  vadd.vv     B1,  B1,  TH              // B1 =  r4+c2'  ||  r1+0

  vrgather.vv CL,  R2L, M01             // CL =  r2      ||    c4 
  vand.vv     CL,  CL,  M0F             // CL =       0  ||    c4

  vmul.vx     CL,  CL,  C19             // CL =       0  ||  19c4
  vadd.vv     B0,  B0,  CL              // B0 =    0+r3  ||  19c4+r0
  vsrl.vx     CL,  B0,  C51 
  vand.vv     B0,  B0,  M51
  vadd.vv     B1,  B1,  CL 
.endm


// (1x2)-way field multiplication 

.section .text

// v0: conventional operand-scanning 

.global gfp_mul_1x2w_v0

gfp_mul_1x2w_v0: 
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
  
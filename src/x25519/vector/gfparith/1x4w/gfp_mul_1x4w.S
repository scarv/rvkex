// void gfp_mul_1x4w(vec4 *r, const vec4 *a, const vec4 *b, const vec4 *m);
// radix-25.5 + vwmaccu vwmulu


// meaningful names for registers and constants

// result "r" (Ri is a wide vector) 
#define R0 v16
#define R1 v18
#define R2 v20
#define S0 v22
#define S1 v24
#define S2 v26

#define R0L v16
#define R0H v17
#define R1L v18
#define R1H v19
#define R2L v20
#define R2H v21
#define S0L v22
#define S0H v23
#define S1L v24
#define S1H v25
#define S2L v26
#define S2H v27

// operand "b"
#define B0 v8 
#define B1 v9 
#define B2 v10
#define BS t6                           // scalar limb
#define T0 v11
#define T1 v12
#define T2 v13

// operand "a"
#define A_ v14                          // vector limb
#define AS t6                           // scalar limb

// carry "c"
#define CL v14                          // the Lower  part of Carry bits
#define CH v15                          // the Higher part of Carry bits

// mask "m"
#define M0 v2 
#define M1 v3 
#define M2 v4
#define M3 v5
#define M4 v6

// constants
#define C19 t2                          // 19  
#define C51 t3                          // 51


// load operands "a" "b" + store result "r" 

.macro LOAD_LIMB_A imm
  lw       AS, 4*\imm(a1)               // AS  =   ai 
  vmv.v.x  A_, AS                       // A_  =   ai   ||   ai   ||   ai   ||   ai
.endm 

.macro LOAD_LIMB_B imm
  lw       BS, 4*\imm(a2)               // BS  =     bi 
  mul      BS, BS, C19                  // BS  = 19  bi
.endm 

.macro LOAD_OPERAND_B_LMUL1 
  vle32.v  B0, (a2)                     // B0  =     b9 ||     b6 ||     b3 ||     b0
  addi     a2,  a2, 16 
  vle32.v  B1, (a2)                     // B1  =        ||     b7 ||     b4 ||     b1
  addi     a2,  a2, 16 
  vle32.v  B2, (a2)                     // B2  =        ||     b8 ||     b5 ||     b2
  addi     a2,  a2, -32
.endm

.macro STORE_RESULT_R_LMUL1 
  vse32.v  B0, (a0) 
  addi     a0,  a0, 16 
  vse32.v  B1, (a0)
  addi     a0,  a0, 16 
  vse32.v  B2, (a0) 
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  LOAD_LIMB_A  0                        // A_  =   a0   ||   a0   ||   a0   ||   a0
  vwmulu.vv    R0, A_, B0               // R0  =   a0b9 ||   a0b6 ||   a0b3 ||   a0b0 
  vwmulu.vv    R1, A_, B1               // R1  =        ||   a0b7 ||   a0b4 ||   a0b1 
  vwmulu.vv    R2, A_, B2               // R2  =        ||   a0b8 ||   a0b5 ||   a0b2 
.endm

.macro MULTIPLY_A1_LMUL1
  LOAD_LIMB_A  4                        // A_  =   a1   ||   a1   ||   a1   ||   a1
  LOAD_LIMB_B  3                        // BS  =                               19  b9
  vslide1up.vx T2, B2, BS               // T2  =     b8 ||     b5 ||     b2 || 19  b9
  vwmulu.vv    S0, A_, T2               // S0  =   a1b8 ||   a1b5 ||   a1b2 || 19a1b9
  vwmulu.vv    S1, A_, B0               // S1  =        ||   a1b6 ||   a1b3 ||   a1b0
  vwmulu.vv    S2, A_, B1               // S2  =        ||   a1b7 ||   a1b4 ||   a1b1   
.endm

.macro MULTIPLY_A2_LMUL1
  LOAD_LIMB_A  8                        // A_  =   a2   ||   a2   ||   a2   ||   a2
  LOAD_LIMB_B  10                       // BS  =                               19  b8
  vslide1up.vx T1, B1, BS               // T1  =     b7 ||     b4 ||     b1 || 19  b8
  vwmaccu.vv   R0, A_, T1               // R0 +=   a2b7 ||   a2b4 ||   a2b1 || 19a2b8
  vwmaccu.vv   R1, A_, T2               // R1 +=        ||   a2b5 ||   a2b2 || 19a2b9  
  vwmaccu.vv   R2, A_, B0               // R2 +=        ||   a2b6 ||   a2b3 ||   a2b0   
.endm

.macro MULTIPLY_A3_LMUL1
  LOAD_LIMB_A  1                        // A_  =   a3   ||   a3   ||   a3   ||   a3
  LOAD_LIMB_B  6                        // BS  =                               19  b7
  vslide1up.vx T0, B0, BS               // T0  =     b6 ||     b3 ||     b0 || 19  b7
  vwmaccu.vv   S0, A_, T0               // S0 +=   a3b6 ||   a3b3 ||   a3b0 || 19a3b7
  vwmaccu.vv   S1, A_, T1               // S1 +=        ||   a3b4 ||   a3b1 || 19a3b8 
  vwmaccu.vv   S2, A_, T2               // S2 +=        ||   a3b5 ||   a3b2 || 19a3b9   
.endm

.macro MULTIPLY_A4_LMUL1
  LOAD_LIMB_A  5                        // A_  =   a4   ||   a4   ||   a4   ||   a4
  LOAD_LIMB_B  2                        // BS  =                               19  b6
  vslide1up.vx B2, T2, BS               // B2  =     b5 ||     b2 || 19  b9 || 19  b6
  vwmaccu.vv   R0, A_, B2               // R0 +=   a4b5 ||   a4b2 || 19a4b9 || 19a4b6
  vwmaccu.vv   R1, A_, T0               // R1 +=        ||   a4b3 ||   a4b0 || 19a4b7
  vwmaccu.vv   R2, A_, T1               // R2 +=        ||   a4b4 ||   a4b1 || 19a4b8
.endm

.macro MULTIPLY_A5_LMUL1
  LOAD_LIMB_A  9                        // A_  =   a5   ||   a5   ||   a5   ||   a5
  LOAD_LIMB_B  9                        // BS  =                               19  b5
  vslide1up.vx B1, T1, BS               // B1  =     b4 ||     b1 || 19  b8 || 19  b5
  vwmaccu.vv   S0, A_, B1               // S0 +=   a5b4 ||   a5b1 || 19a5b8 || 19a5b5
  vwmaccu.vv   S1, A_, B2               // S1 +=        ||   a5b2 || 19a5b9 || 19a5b6
  vwmaccu.vv   S2, A_, T0               // S2 +=        ||   a5b3 ||   a5b0 || 19a5b7
.endm

.macro MULTIPLY_A6_LMUL1
  LOAD_LIMB_A  2                        // A_  =   a6   ||   a6   ||   a6   ||   a6
  LOAD_LIMB_B  5                        // BS  =                               19  b4
  vslide1up.vx B0, T0, BS               // B0  =     b3 ||     b0 || 19  b7 || 19  b4
  vwmaccu.vv   R0, A_, B0               // R0 +=   a6b3 ||   a6b0 || 19a6b7 || 19a6b4
  vwmaccu.vv   R1, A_, B1               // R1 +=        ||   a6b1 || 19a6b8 || 19a6b5 
  vwmaccu.vv   R2, A_, B2               // R2 +=        ||   a6b2 || 19a6b9 || 19a6b6
.endm

.macro MULTIPLY_A7_LMUL1
  LOAD_LIMB_A  6                        // A_  =   a7   ||   a7   ||   a7   ||   a7
  LOAD_LIMB_B  1                        // BS  =                               19  b3
  vslide1up.vx T2, B2, BS               // T2  =     b2 || 19  b9 || 19  b6 || 19  b3
  vwmaccu.vv   S0, A_, T2               // S0 +=   a7b2 || 19a7b9 || 19a7b6 || 19a7b3
  vwmaccu.vv   S1, A_, B0               // S1 +=        ||   a7b0 || 19a7b7 || 19a7b4
  vwmaccu.vv   S2, A_, B1               // S2 +=        ||   a7b1 || 19a7b8 || 19a7b5
.endm

.macro MULTIPLY_A8_LMUL1
  LOAD_LIMB_A  10                       // A_  =   a8   ||   a8   ||   a8   ||   a8
  LOAD_LIMB_B  8                        // BS  =                               19  b2
  vslide1up.vx T1, B1, BS               // T1  =     b1 || 19  b8 || 19  b5 || 19  b2
  vwmaccu.vv   R0, A_, T1               // R0 +=   a8b1 || 19a8b8 || 19a8b5 || 19a8b2
  vwmaccu.vv   R1, A_, T2               // R1 +=        || 19a8b9 || 19a8b6 || 19a8b3
  vwmaccu.vv   R2, A_, B0               // R2 +=        ||   a8b0 || 19a8b7 || 19a8b4
.endm

.macro MULTIPLY_A9_LMUL1
  LOAD_LIMB_A  3                        // A_  =   a9   ||   a9   ||   a9   ||   a9
  LOAD_LIMB_B  4                        // BS  =                               19  b1
  vslide1up.vx T0, B0, BS               // T0  =     b0 || 19  b7 || 19  b4 || 19  b1
  vwmaccu.vv   S0, A_, T0               // S0 +=   a9b0 || 19a9b7 || 19a9b4 || 19a9b1
  vwmaccu.vv   S1, A_, T1               // S1 +=        || 19a9b8 || 19a9b5 || 19a9b2
  vwmaccu.vv   S2, A_, T2               // S2 +=        || 19a9b9 || 19a9b6 || 19a9b3
.endm

.macro R_EQU_R_ADD_S_LMUL1 
  vle32.v M0, (a3)                      // M0  =    0   ||    1   ||    0   ||    2    
  addi    a3,  a3, 16                   //
  vle32.v M1, (a3)                      // M1  =    0   ||    2   ||    0   ||    1    
  addi    a3,  a3, 16                   //
  vle32.v M2, (a3)                      // M2  =    0   ||    0   ||   -1   ||   -1    
  addi    a3,  a3, 16                   //
  vsetvli t0, t1, e64, m1               // SEW = 64
  vmul.vv S0L, S0L, M0                  // S0  =     s9 ||    2s6 ||     s3 ||    2s0    
  vmul.vv S0H, S0H, M0                  // 
  vmul.vv S1L, S1L, M1                  // S1  =        ||     s7 ||    2s4 ||     s1
  vmul.vv S2L, S2L, M0                  // S2  =        ||    2s8 ||     s5 ||    2s2 
  vmul.vv S2H, S2H, M0                  // 
  vadd.vv R0L, R0L, S0L                 // R0  = r9+ s9 || r6+2s6 || r3+ s3 || r0+2s0
  vadd.vv R0H, R0H, S0H                 //
  vadd.vv R1L, R1L, S1L                 // R1  =        || r7+ s7 || r4+2s4 || r1+ s1
  vadd.vv R1H, R1H, S1H                 //
  vadd.vv R2L, R2L, S2L                 // R2  =        || r8+2s8 || r5+ s5 || r2+2s2
  vadd.vv R2H, R2H, S2H                 //
  vand.vv R1H, R1H, M2                  // R1  =      0 || r7+ s7 || r4+2s4 || r1+ s1
  vand.vv R2H, R2H, M2                  // R2  =      0 || r8+2s8 || r5+ s5 || r2+2s2
  vsetvli t0, t1, e32, m1               // SEW = 32
.endm 

// carry propagation 
// TODO: further optimize

.macro CARRY_PROPAGATION_WVEC
  vle32.v     M0, (a3)                  // M0  =     25 ||     26 ||     25 ||     26    
  addi        a3,  a3, 16               //
  vle32.v     M1, (a3)                  // M1  =     26 ||     25 ||     26 ||     25 
  addi        a3,  a3, 16               //
  vle32.v     M2, (a3)                  // M2  =    M25 ||    M26 ||    M25 ||    M26   
  addi        a3,  a3, 16               //
  vle32.v     M3, (a3)                  // M3  =    M26 ||    M25 ||    M26 ||    M25  
  addi        a3,  a3, 16               //
  vle32.v     M4, (a3)                  // M4  =      2 ||      1 ||      0 ||      3  
  addi        a3,  a3, 16               //

  vnsrl.wi    B0, R0, 0                 // B0  = r9     || r6     || r3     || r0
  vnsrl.wv    CL, R0, M0                // CL  = r9>>25 || r6>>26 || r3>>25 || r0>>26
  vnsrl.wx    CH, R0, C51               // CH  = r9>>51 || r6>>51 || r3>>51 || r0>>51
  vand.vv     CL, CL, M3                // CL  = c9&M26 || c6&M25 || c3&M26 || c0&M25
  vand.vv     B0, B0, M2                // B0  = r9&M25 || r6&M26 || r3&M25 || r0&M26

  vwaddu.wv   R1, R1, CL                // R1  =  0+c9  || r7+c6  || r4+c3  || r1+c0
  vwaddu.wv   R2, R2, CH                // R2  =  0+c9' || r8+c6' || r5+c3' || r2+c0'   
  vnsrl.wi    B1, R1, 0                 // B1  =  c9    || r7     || r4     || r1
  vnsrl.wv    CL, R1, M1                // CL  =   0    || r7>>25 || r4>>26 || r1>>25
  vnsrl.wx    CH, R1, C51               // CH  =   0    || r7>>51 || r4>>51 || r1>>51
  vand.vv     CL, CL, M2                // CL  =   0    || c7&M26 || c4&M25 || c1&M26
  vand.vv     B1, B1, M3                // B1  = c9&M26 || r7&M25 || r4&M26 || r1&M25

  vwaddu.wv   R2, R2, CL                // R2  = c9'+0  || r8+c7  || r5+c4  || r2+c1
  vrgather.vv T0, CH, M4                // T0  = r7>>51 || r4>>51 || r1>>51 ||  0
  vadd.vv     B0, B0, T0                // 
  vnsrl.wi    B2, R2, 0                 // B2  =  c9'   || r8     || r5     || r2
  vnsrl.wv    CL, R2, M0                // CL  =   0    || r8>>26 || r5>>25 || r2>>26
  vnsrl.wx    CH, R2, C51               // CH  =   0    || r8>>51 || r5>>51 || r2>>51 
  vand.vv     CL, CL, M3                // CL  =   0    || c8&M25 || c5&M26 || c2&M25
  vand.vv     B2, B2, M2                // B2  =c9'&M25 || r8&M26 || r5&M25 || r2&M26

  vrgather.vv T0, CL, M4                // T0  = r8>>26 || r5>>25 || r2>>26 ||  0
  vrgather.vv T1, CH, M4                // T1  = r8>>51 || r5>>51 || r2>>51 ||  0
  vadd.vv     B0, B0, T0                // 
  vadd.vv     B1, B1, T1                // 

  vmul.vx     CL, B1, C19               // CL  = 19c9   ||    %   ||    %   ||   %
  vmul.vx     CH, B2, C19               // CH  = 19c9'  ||    %   ||    %   ||   %    

  vle32.v     M3, (a3)                  // M3  =      0 ||     -1 ||     -1 ||     -1
  addi        a3, a3, 16                //
  vand.vv     B1, B1, M3                // 
  vand.vv     B2, B2, M3                // 

  vle32.v     M4, (a3)                  // M4  =     -1 ||     -1 ||     -1 ||      3
  vrgather.vv T0, CL, M4                // T0  =    0   ||    0   ||    0   || 19c9  
  vrgather.vv T1, CH, M4                // T1  =    0   ||    0   ||    0   || 19c9'

  vadd.vv     B0, B0, T0                // 
  vadd.vv     B1, B1, T1                // 

  vsrl.vv     CL, B0, M0                // CL  =    0   ||    0   ||    0   || r0>>26
  vand.vv     B0, B0, M2                // B0  = r9&M25 || r6&M26 || r3&M25 || r0&M26

  vadd.vv     B1, B1, CL 

  vmul.vx     CL, B1, C19               // CL  = 19c9   ||    %   ||    %   ||   %
  vrgather.vv T0, CL, M4                // T0  =    0   ||    0   ||    0   || 19c9  
  vadd.vv     B0, B0, T0                // 
.endm


// (1x4)-way field multiplication 

.section .text

// v0: uses both scalar ALU and vector ALU, which might have a larger overhead
//     than using a single vector ALU since it transmits the more data between 
//     two cores.

.global gfp_mul_1x4w_v0

gfp_mul_1x4w_v0:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  // 
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B2
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
  R_EQU_R_ADD_S_LMUL1                   // sum two accumulators "r" and "s"
  CARRY_PROPAGATION_WVEC                // 
  STORE_RESULT_R_LMUL1                  //
  // 
  ret 

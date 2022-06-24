// void mon_cswap_point_1x2x1w(vec2 *x3z3, vec2 *x2z2, int swap);
// radix-51


// meaningful names for registers and constants

// x3z3 
#define A0 v0
#define A1 v1
#define A2 v2
#define A3 v3
#define A4 v4

// x2z2 
#define B0 v8
#define B1 v9
#define B2 v10
#define B3 v11
#define B4 v12

// txtz
#define T0 v16
#define T1 v17
#define T2 v18
#define T3 v19
#define T4 v20

// mask 
#define M0 v24
#define M1 v25
#define M2 v26
#define M3 v27
#define M4 v28


// load operands  + store results + form mask

.macro LOAD_OPERAND_A_LMUL1
  vle64.v  A0, (a0)
  addi     a0,  a0, 16
  vle64.v  A1, (a0)
  addi     a0,  a0, 16
  vle64.v  A2, (a0)
  addi     a0,  a0, 16
  vle64.v  A3, (a0)
  addi     a0,  a0, 16
  vle64.v  A4, (a0)
  addi     a0,  a0, -64
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle64.v  B0, (a1)
  addi     a1,  a1, 16
  vle64.v  B1, (a1)
  addi     a1,  a1, 16
  vle64.v  B2, (a1)
  addi     a1,  a1, 16
  vle64.v  B3, (a1)
  addi     a1,  a1, 16
  vle64.v  B4, (a1)
  addi     a1,  a1, -64
.endm

.macro STORE_RESULT_A_LMUL1 
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

.macro STORE_RESULT_B_LMUL1 
  vse64.v  B0, (a1) 
  addi     a1,  a1, 16 
  vse64.v  B1, (a1)
  addi     a1,  a1, 16 
  vse64.v  B2, (a1) 
  addi     a1,  a1, 16 
  vse64.v  B3, (a1)
  addi     a1,  a1, 16 
  vse64.v  B4, (a1) 
.endm

.macro FORM_MASK_M_LMUL1 
  andi     t2, a2, 1
  vmv.v.x  T0, t2
  vxor.vv  M0, M0, M0 
  vsub.vv  M0, M0, T0  
.endm 

// cswap

.macro CSWAP_A_B_LMUL1 
  vxor.vv  T0, A0, B0 
  vxor.vv  T1, A1, B1
  vxor.vv  T2, A2, B2
  vxor.vv  T3, A3, B3
  vxor.vv  T4, A4, B4
  vand.vv  T0, T0, M0
  vand.vv  T1, T1, M0 
  vand.vv  T2, T2, M0 
  vand.vv  T3, T3, M0
  vand.vv  T4, T4, M0
  vxor.vv  A0, A0, T0 
  vxor.vv  A1, A1, T1 
  vxor.vv  A2, A2, T2 
  vxor.vv  A3, A3, T3 
  vxor.vv  A4, A4, T4 
  vxor.vv  B0, B0, T0 
  vxor.vv  B1, B1, T1 
  vxor.vv  B2, B2, T2 
  vxor.vv  B3, B3, T3 
  vxor.vv  B4, B4, T4  
.endm 


// (1x2x1)-way cswap 

.section .text

// v0: conventional one 

.global mon_cswap_point_1x2x1w_v0 

mon_cswap_point_1x2x1w_v0: 
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1
  LOAD_OPERAND_B_LMUL1
  FORM_MASK_M_LMUL1
  CSWAP_A_B_LMUL1
  STORE_RESULT_A_LMUL1
  STORE_RESULT_B_LMUL1
  // 
  ret 


// v2: use register group (LMUL = 5) 

.global mon_cswap_point_1x2x1w_v2 

mon_cswap_point_1x2x1w_v2: 
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5 
  //
  vle64.v A0, (a0)                      // load operand "a" to A0-A4
  vle64.v B0, (a1)                      // load operand "b" to B0-B4
  andi    t2, a2, 1                     // "swap" = "swap"&1 
  vmv.v.x T0, t2                        // splat to T0-T4
  vxor.vv M0, M0, M0                    // clear M0-M4  
  vsub.vv M0, M0, T0                    // "mask" = 0 - "t"
  vxor.vv T0, A0, B0                    // "t" =  "a" ^ "b"
  vand.vv T0, T0, M0                    // "t" = "t" & "mask"
  vxor.vv A0, A0, T0                    // "a" = "a" ^ "t" 
  vxor.vv B0, B0, T0                    // "b" = "b" ^ "m"
  vse64.v A0, (a0)                      // store result "a" to memory 
  vse64.v B0, (a1)                      // store result "b" to memory 
  //
  ret 

// void gfp_addsub_2x1w(vec2 *r, const vec2 *a, const vec2 *b);
// radix-51 + no carry propagation, no reduction
// lane       :      1    ||    0    
// input  "a" =      x    ||    w         
//        "b" =      z    ||    y 
// output "r" =    x+z    || w+2p-y 


// meaningful names for registers and constants

// result "r" 
#define R0 v16
#define R1 v17
#define R2 v18
#define R3 v19
#define R4 v20

// operand "b"
#define B0 v8 
#define B1 v9 
#define B2 v10 
#define B3 v11
#define B4 v12 

// operand "a"
#define A0 v24
#define A1 v25 
#define A2 v26
#define A3 v27
#define A4 v28

// modulus "2p" (re-use registers for "r")
#define P0 v16                         
#define P1 v17                         


// load operands "a" "b" + store result "r" + load modulus "2p"

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
  vse64.v  R0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  R1, (a0)
  addi     a0,  a0, 16 
  vse64.v  R2, (a0) 
  addi     a0,  a0, 16 
  vse64.v  R3, (a0)
  addi     a0,  a0, 16 
  vse64.v  R4, (a0) 
.endm

.macro LOAD_MODULUS_2P_LMUL1
  vle64.v  P0, (a3)
  addi     a3,  a3, 16
  vle64.v  P1, (a3)
.endm

// integer arithmetic computation

.macro R_EQU_2P_SUB_B_LMUL1 
  vsub.vv     R4, P1, B4
  vsub.vv     R3, P1, B3
  vsub.vv     R2, P1, B2
  vsub.vv     R1, P1, B1                // will update P1
  vsub.vv     R0, P0, B0                // will update P0
.endm

.macro R_EQU_BLD_B_R_LMUL1
  li          t2, 0x1                   // 0x1  =  0b01
  vmv.s.x     v0, t2                    // v0.m =  0 || 1
  vmerge.vvm  R0, B0, R0, v0
  vmerge.vvm  R1, B1, R1, v0
  vmerge.vvm  R2, B2, R2, v0
  vmerge.vvm  R3, B3, R3, v0
  vmerge.vvm  R4, B4, R4, v0
.endm

.macro R_EQU_A_ADD_R_LMUL1
  vadd.vv     R0, A0, R0
  vadd.vv     R1, A1, R1
  vadd.vv     R2, A2, R2
  vadd.vv     R3, A3, R3
  vadd.vv     R4, A4, R4
.endm


// (2x1)-way mixed addition and subtraction 

.section .text

// v0: conventional one

.global gfp_addsub_2x1w_v0

gfp_addsub_2x1w_v0:
  li      t1, -1                        // VL = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B4
  LOAD_MODULUS_2P_LMUL1                 // load modulus "2p"
  R_EQU_2P_SUB_B_LMUL1                  // "r" = 2p-z ||  2p-y
  R_EQU_BLD_B_R_LMUL1                   // "r" =   z  ||  2p-y
  R_EQU_A_ADD_R_LMUL1                   // "r" =  x+z || w+2p-y
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  //
  ret 


// v2: uses register group to load/store and arithmetic computation (LMUL = 5)

.macro R_EQU_BLD_B_R_LMUL5
  li          t2, 0x155                 // 0x155 =  0b01 0101 0101
  vmv.s.x     v0, t2                    
  vmerge.vvm  R0, B0, R0, v0
.endm


.global gfp_addsub_2x1w_v2

gfp_addsub_2x1w_v2:
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vle64.v B0, (a2)                      // load operand "b" to B0-B4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  LOAD_MODULUS_2P_LMUL1                 // load modulus "2p"
  R_EQU_2P_SUB_B_LMUL1                  // "r"  = 2p-z ||  2p-y
  vsetvli t0, t1, e64, m8               // LMUL = 5
  R_EQU_BLD_B_R_LMUL5                   // "r"  =   z  ||  2p-y
  vadd.vv R0, A0, R0                    // "r"  =  x+z || w+2p-y
  vse64.v R0, (a0)                      // store result "r" to memory 
  //
  ret 

// v3: optimized version based on v2 (using 5 registers for modulus 2p)

.global gfp_addsub_2x1w_v3

gfp_addsub_2x1w_v3:
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vle64.v B0, (a2)                      // load operand "b" to B0-B4
  vle64.v P0, (a3)                      // load operand "2p" to P0-P4 
  vsub.vv R0, P0, B0                    // "r"  = 2p-z ||  2p-y
  R_EQU_BLD_B_R_LMUL5                   // "r"  =   z  ||  2p-y
  vadd.vv R0, A0, R0                    // "r"  =  x+z || w+2p-y
  vse64.v R0, (a0)                      // store result "r" to memory 
  // 
  ret 

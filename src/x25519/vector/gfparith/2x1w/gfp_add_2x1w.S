// void gfp_add_2x1w(vec2 *r, const vec2 *a, const vec2 *b);
// radix-51 + no carry propagation, no reduction


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

// integer addition

.macro R_EQU_A_ADD_B_LMUL1
  vadd.vv  R0, A0, B0
  vadd.vv  R1, A1, B1
  vadd.vv  R2, A2, B2
  vadd.vv  R3, A3, B3
  vadd.vv  R4, A4, B4
.endm


// (2x1)-way field multiplication 

.section .text

// v0: conventional one

.global gfp_add_2x1w_v0

gfp_add_2x1w_v0:
  li      t1,  -1                       // VL = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  //
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B4
  R_EQU_A_ADD_B_LMUL1                   // "r" = "a" + "b"
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  // 
  ret


// v2: uses register group to load/store and arithmetic computation (LMUL = 5)

.global gfp_add_2x1w_v2

gfp_add_2x1w_v2:
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  //
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vle64.v B0, (a2)                      // load operand "b" to B0-B4
  vadd.vv R0, A0, B0                    // "r" = "a" + "b"
  vse64.v R0, (a0)                      // store result "r" to memory 
  // 
  ret

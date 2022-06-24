// void gfp_align_2x1w(vec2 *r, const vec2 *a, const vec2 *m);
// radix-51


// meaningful names for registers and constants

// result "r" 
#define R0 v8
#define R1 v9
#define R2 v10
#define R3 v11
#define R4 v12

// operand "a"
#define A0 v0 
#define A1 v1 
#define A2 v2 
#define A3 v3
#define A4 v4

// mask 
#define M_ v16                          // "M_" means the mask for any limb


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

// permuting

.macro R_EQU_PERM_A_LMUL1
  vid.v         M_                      // M_ = 1 || 0
  vslidedown.vi M_, M_, 1               // M_ = 0 || 1
  vrgather.vv   R0, A0, M_
  vrgather.vv   R1, A1, M_
  vrgather.vv   R2, A2, M_
  vrgather.vv   R3, A3, M_
  vrgather.vv   R4, A4, M_
.endm


// (2x1)-way aligning

.section .text

// v0: conventional one

.global gfp_align_2x1w_v0

gfp_align_2x1w_v0:  
  li      t1, -1                        // VL = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  R_EQU_PERM_A_LMUL1                    // 
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  //
  ret


// v2: uses register group to load/store and arithmetic computation (LMUL = 5)

.global gfp_align_2x1w_v2

gfp_align_2x1w_v2:
  li      t1, 10                        // AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  R_EQU_PERM_A_LMUL1                    //
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v R0, (a0)                      // store result "r" to memory 
  // 
  ret 

// v3: optimized version based on v2

.global gfp_align_2x1w_v3

gfp_align_2x1w_v3:
  li      t1, 10                        // AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v     A0, (a1)                  // load operand "a" to A0-A4
  vle64.v     M_, (a2)                  // load mask "m"
  vrgather.vv R0, A0, M_                // 
  vse64.v     R0, (a0)                  // store result "r" to memory 
  // 
  ret
 
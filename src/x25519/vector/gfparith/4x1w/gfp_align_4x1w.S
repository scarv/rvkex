// !!! this function can be integrated into gfp_mul to further reduce latency
// void gfp_align_4x1w(vec4 *r, const vec4 *a, const vec4 *m);
// radix-25.5 
// lane   :    3    ||    2    ||    1    ||    0    
// input  =    z    ||    y    ||    x    ||    w         
// output =    w    ||    x    ||    x    ||    w 


// meaningful names for registers and constants

// result "r" 
#define R0 v8
#define R1 v9
#define R2 v10
#define R3 v11
#define R4 v12
#define R5 v13
#define R6 v14
#define R7 v15
#define R8 v26
#define R9 v27

// operand "a"
#define A0 v0
#define A1 v1
#define A2 v2
#define A3 v3
#define A4 v4
#define A5 v5
#define A6 v6
#define A7 v7
#define A8 v24
#define A9 v25

// mask 
#define M_ v30                          // "M_" means the mask for any limb


// load operand "a" + store result "r" 

.macro LOAD_OPERAND_A_LMUL82 
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vle32.v A0, (a1)                      // load 8 LS-limbs of "a" to A0-A7
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a1, a1, 128                   // 
  vle32.v A8, (a1)                      // load 2 MS-limbs of "a" to A8-A9
.endm

.macro STORE_RESULT_R_LMUL82
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vse32.v R0, (a0)                      // store 8 LS-limbs of "r" to memory
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a0, a0, 128                   // 
  vse32.v R8, (a0)                      // store 2 MS-limbs of "r" to memory
.endm

.macro R_EQU_PERM_A_LMUL1
  vle32.v     M_, (a2)                  // M_ = 0 1 1 0  
  vrgather.vv R0, A0, M_
  vrgather.vv R1, A1, M_
  vrgather.vv R2, A2, M_
  vrgather.vv R3, A3, M_
  vrgather.vv R4, A4, M_
  vrgather.vv R5, A5, M_
  vrgather.vv R6, A6, M_
  vrgather.vv R7, A7, M_
  vrgather.vv R8, A8, M_
  vrgather.vv R9, A9, M_ 
.endm


// (4x1)-way aligning

.section .text

// v2: uses register group to load/store (LUML = 8, 2) and arithmetic computation (LMUL = 8, 2)

.global gfp_align_4x1w_v2

gfp_align_4x1w_v2:
  li      t1, -1                        // VL  = VLMAX
  //
  LOAD_OPERAND_A_LMUL82                 // "a" =  z || y || x || w
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  R_EQU_PERM_A_LMUL1                    // "r" =  w || x || x || w
  STORE_RESULT_R_LMUL82                 // store result "r" R0-R9 to memory
  //
  ret

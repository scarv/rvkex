// void gfp_mix0_2x1w(vec2 *r, vec2 *s, const vec2 *a, const vec2 *b);
// radix-51
// lane     :      1    ||    0    
// input  a =      x    ||    w         
//        b =      z    ||    y 
// output r =      x    ||    z 
//        s =      w    ||    y


#include "../ise.h"


// meaningful names for registers and constants

// result "r" 
#define R0 v16
#define R1 v17
#define R2 v18
#define R3 v19
#define R4 v20

// result "s" 
#define S0 v16
#define S1 v17
#define S2 v18
#define S3 v19
#define S4 v20

// operand "a"
#define A0 v8 
#define A1 v9
#define A2 v10
#define A3 v11
#define A4 v12

// operand "b"
#define B0 v24 
#define B1 v25 
#define B2 v26 
#define B3 v27
#define B4 v28 

// mask 
#define M_ v0                           // "M_" means the mask for any limb


// (4x1)-way mix0 using ISE

.section .text

// v2: uses register group to load/store and arithmetic computation (LMUL = 5)

.global gfp_mix0_2x1w_v2_ise

gfp_mix0_2x1w_v2_ise:
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v     A0, (a2)                  // load operand "a" to A0-A4
  vle64.v     B0, (a3)                  // load operand "b" to B0-B4
  li          t2,  1                    // 
  vmv.s.x     M_, t2                    // M_ =   || 1
  vmvidx1.s.x M_, x0                    // M_ = 0 || 1
  vpermute.vv R0, B0, M_                // 
  li          t3, 0x155                 // 
  vmv.s.x     v0, t3                    // 
  vmerge.vvm  R0, A0, R0, v0            // "r" =  x || z 
  vse64.v     R0, (a0)                  // store result "r" to memory 
  vmv.s.x     M_, t2                    // M_ =   || 1
  vpermute.vv S0, A0, M_                // 
  vmv.s.x     v0, t3                    // 
  vmerge.vvm  S0, S0, B0, v0            // "s" =  w || y
  vse64.v     S0, (a1)                  // store result "s" to memory 
  // 
  ret 

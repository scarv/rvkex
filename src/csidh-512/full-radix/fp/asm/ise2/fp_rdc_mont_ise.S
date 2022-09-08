// void fp_rdc_mont_ise(uint64_t *r, const uint64_t *a);
// radix-2^64, product-scanning


#include "ise2.h"


// registers 

// accumulator `z`
#define Z0 t0
#define Z1 t1
#define Z2 t2

// modulus `p`
#define P0 t4
#define P1 t5
#define P2 t6
#define P3 a2
#define P4 a3
#define P5 a6
#define P6 a7
#define P7 s0

// operand `a`
#define A0 s1
#define A1 s2
#define A2 s3
#define A3 s4
#define A4 s5
#define A5 s6
#define A6 s7
#define A7 t3
#define A_ a4

// temporary value `t`
#define T0 a4

// Montgomery reduction constant `w = -p^-1 mod 2^64`
#define W_ a5

// prologue + epilogue 

.macro PROLOGUE
  addi   sp, sp, -64
  sd     s0,  0(sp)
  sd     s1,  8(sp)
  sd     s2, 16(sp)
  sd     s3, 24(sp)
  sd     s4, 32(sp)
  sd     s5, 40(sp)
  sd     s6, 48(sp)
  sd     s7, 56(sp)
  li     W_, 0x66c1301f632e294d
.endm

.macro EPILOGUE
  ld     s0,  0(sp)
  ld     s1,  8(sp)
  ld     s2, 16(sp)
  ld     s3, 24(sp)
  ld     s4, 32(sp)
  ld     s5, 40(sp)
  ld     s6, 48(sp)
  ld     s7, 56(sp)
  addi   sp, sp, 64
  ret 
.endm

// load operand

.macro LOAD_A
  ld     A0,  0(a1)
  ld     A1,  8(a1)
  ld     A2, 16(a1)
  ld     A3, 24(a1)
  ld     A4, 32(a1)
  ld     A5, 40(a1)
  ld     A6, 48(a1)
  ld     A7, 56(a1)
.endm 

.macro LOAD_P
  la     a4, P512
  ld     P0,  0(a4)
  ld     P1,  8(a4)
  ld     P2, 16(a4)
  ld     P3, 24(a4)
  ld     P4, 32(a4)
  ld     P5, 40(a4)
  ld     P6, 48(a4)
  ld     P7, 56(a4)
.endm 

// first loop of Montgomery reduction (based on product-scanning)

.macro _ACCU_OPERAND L, M, H, A 
  add    \L, \L, \A
  sltu   T0, \L, \A
  add    \M, \M, T0
  sltu   \H, \M, T0
.endm

// L != 0, M = 0, H = 0
// L M H -> T M H
.macro _ACCU_PRDCT_0 L, M, H, T, A, B 
  maddhu \M, \A, \B, \L
  maddlu \L, \A, \B, \L
.endm

// L != 0, M != 0, H = 0
// L M H -> T M H
.macro _ACCU_PRDCT_1 L, M, H, T, A, B 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  add    \M, \M, \T
  sltu   \H, \M, \T
.endm

// L != 0, M != 0, H != 0
// L M H -> T M H 
.macro _ACCU_PRDCT_2 L, M, H, T, A, B 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  add    \M, \M, \T
  sltu   \T, \M, \T
  add    \H, \H, \T
.endm

.macro COMPUTE_A0
  mv     Z0, A0
  mul    A0, Z0, W_ 
  _ACCU_PRDCT_0  Z0, Z1, Z2, T0, A0, P0
.endm

.macro COMPUTE_A1
  add    Z1, Z1, A1
  sltu   Z2, Z1, A1
  _ACCU_PRDCT_1  Z1, Z2, Z0, T0, A0, P1
  mul    A1, Z1, W_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A1, P0
.endm

.macro COMPUTE_A2
  _ACCU_OPERAND  Z2, Z0, Z1, A2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A0, P2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A1, P1
  mul    A2, Z2, W_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A2, P0
.endm

.macro COMPUTE_A3
  _ACCU_OPERAND  Z0, Z1, Z2, A3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A0, P3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A1, P2
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A2, P1
  mul    A3, Z0, W_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A3, P0  
.endm

.macro COMPUTE_A4
  _ACCU_OPERAND  Z1, Z2, Z0, A4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A0, P4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A1, P3
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A2, P2
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A3, P1
  mul    A4, Z1, W_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A4, P0
.endm

.macro COMPUTE_A5
  _ACCU_OPERAND  Z2, Z0, Z1, A5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A0, P5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A1, P4
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A2, P3
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A3, P2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A4, P1
  mul    A5, Z2, W_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A5, P0
.endm

.macro COMPUTE_A6
  _ACCU_OPERAND  Z0, Z1, Z2, A6
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A0, P6
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A1, P5
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A2, P4
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A3, P3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A4, P2
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A5, P1
  mul    A6, Z0, W_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A6, P0
.endm

.macro COMPUTE_A7
  _ACCU_OPERAND  Z1, Z2, Z0, A7
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A0, P7
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A1, P6
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A2, P5
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A3, P4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A4, P3
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A5, P2
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A6, P1
  mul    A7, Z1, W_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A7, P0
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0 
  ld     A_, 64(a1)
  _ACCU_OPERAND  Z2, Z0, Z1, A_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A1, P7
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A2, P6
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A3, P5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A4, P4
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A5, P3
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A6, P2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A7, P1
  sd     Z2,  0(a0)
.endm

.macro COMPUTE_R1
  ld     A_, 72(a1)
  _ACCU_OPERAND  Z0, Z1, Z2, A_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A2, P7
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A3, P6
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A4, P5
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A5, P4
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A6, P3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A7, P2
  sd     Z0,  8(a0) 
.endm

.macro COMPUTE_R2
  ld     A_, 80(a1)
  _ACCU_OPERAND  Z1, Z2, Z0, A_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A3, P7
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A4, P6
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A5, P5
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A6, P4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A7, P3
  sd     Z1, 16(a0) 
.endm

.macro COMPUTE_R3
  ld     A_, 88(a1)
  _ACCU_OPERAND  Z2, Z0, Z1, A_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A4, P7
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A5, P6
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A6, P5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A7, P4
  sd     Z2, 24(a0) 
.endm

.macro COMPUTE_R4
  ld     A_, 96(a1)
  _ACCU_OPERAND  Z0, Z1, Z2, A_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A5, P7
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A6, P6
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A7, P5
  sd     Z0, 32(a0) 
.endm

.macro COMPUTE_R5
  ld     A_,104(a1)
  _ACCU_OPERAND  Z1, Z2, Z0, A_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A6, P7
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A7, P6
  sd     Z1, 40(a0) 
.endm

.macro COMPUTE_R6
  ld     A_,112(a1)
  add    Z2, Z2, A_
  sltu   T0, Z2, A_
  add    Z0, Z0, T0
  maddhu T0, A7, P7, Z2
  maddlu Z2, A7, P7, Z2
  add    Z0, Z0, T0
  sd     Z2, 48(a0)
.endm

.macro COMPUTE_R7 
  ld     A_,120(a1)
  add    Z0, Z0, A_ 
  sd     Z0, 56(a0)    
.endm


.section .text

.global fp_rdc_mont_ise

fp_rdc_mont_ise:
  PROLOGUE
  LOAD_A
  LOAD_P
  COMPUTE_A0
  COMPUTE_A1
  COMPUTE_A2
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  EPILOGUE


.section .data 

.balign 8 

P512: 
.dword 0x1b81b90533c6c87b               // P0 
.dword 0xc2721bf457aca835               // P1
.dword 0x516730cc1f0b4f25               // P2
.dword 0xa7aac6c567f35507               // P3
.dword 0x5afbfcc69322c9cd               // P4 
.dword 0xb42d083aedc88c42               // P5
.dword 0xfc8ab0d15e3e4c4a               // P6
.dword 0x65b48e8f740f89bf               // P7

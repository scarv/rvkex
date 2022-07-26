// void rdc_mont_v0_ise(uint64_t *r, const uint64_t *a);
// radix-2^64, product-scanning


#include "ise2.h"


// registers 

// accumulator "z"
#define Z0 t0
#define Z1 t1
#define Z2 t2

// result "r"
#define R_ t3

// modulus "p+1"
#define P3 a7
#define P4 t4
#define P5 t5
#define P6 t6

// operand "a"
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 a5
#define A4 a2
#define A5 a3
#define A6 a6

// temp "t"
#define T0 a4


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -24
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  addi  sp, sp, 24
  ret 
.endm

// load operand

.macro LOAD_A
  ld     A0,  0(a1)
  ld     A1,  8(a1)
  ld     A2, 16(a1)
  ld     T0, 24(a1)
  ld     A4, 32(a1)
  ld     A5, 40(a1)
  ld     A6, 48(a1)
.endm 

.macro LOAD_P
  la     a4, P434P1
  ld     P3,  0(a4)
  ld     P4,  8(a4)
  ld     P5, 16(a4)
  ld     P6, 24(a4)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _ACCU_A   A, L, M, H 
  add    \A, \L, \A 
  sltu   T0, \A, \L 
  add    \M, \M, T0 
  sltu   \H, \M, T0
.endm

// accu: H M L -> H M T 
.macro _ACCU_AIBJ_1 L, M, H, T, A, B 
  macclo \T, \A, \B, \L
  sltu   \L, \T, \L
  macchi \L, \A, \B, \L                 // no carry-out
  add    \M, \M, \L
  sltu   \L, \M, \L
  add    \H, \H, \L
.endm

.macro COMPUTE_A3
  macclo A3, A0, P3, T0 
  sltu   T0, A3, T0 
  macchi Z1, A0, P3, T0
.endm

.macro COMPUTE_A4 
  add    A4, Z1, A4 
  sltu   Z2, A4, Z1
  macclo T0, A0, P4, A4
  sltu   A4, T0, A4
  macchi A4, A0, P4, A4
  add    Z2, Z2, A4
  sltu   Z0, Z2, A4
  _ACCU_AIBJ_1   T0, Z2, Z0, A4, A1, P3 
.endm

.macro COMPUTE_A5
  _ACCU_A        A5, Z2, Z0, Z1 
  _ACCU_AIBJ_1   A5, Z0, Z1, T0, A0, P5 
  _ACCU_AIBJ_1   T0, Z0, Z1, Z2, A1, P4
  _ACCU_AIBJ_1   Z2, Z0, Z1, A5, A2, P3   
.endm

.macro COMPUTE_A6
  _ACCU_A        A6, Z0, Z1, Z2 
  _ACCU_AIBJ_1   A6, Z1, Z2, T0, A0, P6 
  _ACCU_AIBJ_1   T0, Z1, Z2, A6, A1, P5
  _ACCU_AIBJ_1   A6, Z1, Z2, T0, A2, P4
  _ACCU_AIBJ_1   T0, Z1, Z2, A6, A3, P3  
.endm

// second loop of Montgomery reduction (based on product-scanning)

.macro COMPUTE_R0 
  ld     R_, 56(a1)
  _ACCU_A        R_, Z1, Z2, Z0
  _ACCU_AIBJ_1   R_, Z2, Z0, T0, A1, P6
  _ACCU_AIBJ_1   T0, Z2, Z0, R_, A2, P5
  _ACCU_AIBJ_1   R_, Z2, Z0, T0, A3, P4
  _ACCU_AIBJ_1   T0, Z2, Z0, R_, A4, P3
  sd     R_,  0(a0)
.endm 

.macro COMPUTE_R1 
  ld     R_, 64(a1)
  _ACCU_A        R_, Z2, Z0, Z1
  _ACCU_AIBJ_1   R_, Z0, Z1, T0, A2, P6
  _ACCU_AIBJ_1   T0, Z0, Z1, R_, A3, P5
  _ACCU_AIBJ_1   R_, Z0, Z1, T0, A4, P4
  _ACCU_AIBJ_1   T0, Z0, Z1, R_, A5, P3
  sd     R_,  8(a0)
.endm

.macro COMPUTE_R2 
  ld     R_, 72(a1)
  _ACCU_A        R_, Z0, Z1, Z2
  _ACCU_AIBJ_1   R_, Z1, Z2, T0, A3, P6
  _ACCU_AIBJ_1   T0, Z1, Z2, R_, A4, P5
  _ACCU_AIBJ_1   R_, Z1, Z2, T0, A5, P4
  _ACCU_AIBJ_1   T0, Z1, Z2, R_, A6, P3
  sd     R_, 16(a0)
.endm

.macro COMPUTE_R3 
  ld     R_, 80(a1)
  _ACCU_A        R_, Z1, Z2, Z0
  _ACCU_AIBJ_1   R_, Z2, Z0, T0, A4, P6
  _ACCU_AIBJ_1   T0, Z2, Z0, Z1, A5, P5
  _ACCU_AIBJ_1   Z1, Z2, Z0, R_, A6, P4
  sd     R_, 24(a0)
.endm

.macro COMPUTE_R4 
  ld     R_, 88(a1)
  _ACCU_A        R_, Z2, Z0, Z1
  _ACCU_AIBJ_1   R_, Z0, Z1, T0, A5, P6
  _ACCU_AIBJ_1   T0, Z0, Z1, R_, A6, P5
  sd     R_, 32(a0)
.endm

.macro COMPUTE_R5
  ld     R_, 96(a1)
  add    Z0, Z0, R_ 
  sltu   T0, Z0, R_ 
  add    Z1, Z1, T0
  macclo R_, A6, P6, Z0
  sltu   T0, R_, Z0
  add    Z1, Z1, T0 
  macchi Z1, A6, P6, Z1 
  sd     R_, 40(a0)
.endm

.macro COMPUTE_R6 
  ld    R_,104(a1)
  add   R_, R_, Z1
  sd    R_, 48(a0)
.endm

// Montgomery reduction 

.section .text

// v0: conventional product-scanning

.global rdc_mont_v0_ise

rdc_mont_v0_ise:
  PROLOGUE
  LOAD_P
  LOAD_A
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  EPILOGUE


.section .data 

.balign 8 

P434P1: 
.dword 0xFDC1767AE3000000               // P3 
.dword 0x7BC65C783158AEA3               // P4
.dword 0x6CFC5FD681C52056               // P5
.dword 0x0002341F27177344               // P6

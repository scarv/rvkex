// void uint_sqr2_ps_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^57, product-scanning


#include "ise2.h"


// registers

// accumulator `z`
#define Z0 a1
#define Z1 a2

// partial product `y`
#define Y0 a4
#define Y1 a5

// operand `a`
#define A0 t0 
#define A1 t1
#define A2 t2 
#define A3 t3
#define A4 t4
#define A5 t5
#define A6 t6
#define A7 a7
#define A8 a3


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret
.endm

// load operand

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
  ld    A7, 56(a1)
  ld    A8, 64(a1)
.endm 

// integer multiplication (based on product-scanning)

.macro _ACCU_PRDT_0  
  add      Y0, Y0, Y0 
  add      Z0, Z0, Y0
  add      Z1, Y1, Y1
.endm

.macro _ACCU_PRDT_1  
  add      Y1, Y1, Y1 
  add      Z1, Z1, Y1
  add      Z0, Y0, Y0 
.endm

.macro COMPUTE_R0
  madd57lu Z0, A0, A0, x0
  madd57hu Z1, A0, A0, x0
  sd       Z0,  0(a0)
.endm

.macro COMPUTE_R1
  madd57lu Y1, A0, A1, x0
  madd57hu Y0, A0, A1, x0
  _ACCU_PRDT_1
  sd       Z1,  8(a0)
.endm

.macro COMPUTE_R2
  madd57lu Y0, A0, A2, x0
  madd57hu Y1, A0, A2, x0
  _ACCU_PRDT_0
  madd57lu Z0, A1, A1, Z0
  madd57hu Z1, A1, A1, Z1
  sd       Z0, 16(a0)
.endm

.macro COMPUTE_R3
  madd57lu Y1, A0, A3, x0
  madd57hu Y0, A0, A3, x0
  madd57lu Y1, A1, A2, Y1
  madd57hu Y0, A1, A2, Y0  
  _ACCU_PRDT_1
  sd       Z1, 24(a0)
.endm

.macro COMPUTE_R4
  madd57lu Y0, A0, A4, x0
  madd57hu Y1, A0, A4, x0
  madd57lu Y0, A1, A3, Y0
  madd57hu Y1, A1, A3, Y1
  _ACCU_PRDT_0
  madd57lu Z0, A2, A2, Z0
  madd57hu Z1, A2, A2, Z1
  sd       Z0, 32(a0)
.endm

.macro COMPUTE_R5
  madd57lu Y1, A0, A5, x0
  madd57hu Y0, A0, A5, x0
  madd57lu Y1, A1, A4, Y1
  madd57hu Y0, A1, A4, Y0
  madd57lu Y1, A2, A3, Y1
  madd57hu Y0, A2, A3, Y0
  _ACCU_PRDT_1
  sd       Z1, 40(a0)
.endm

.macro COMPUTE_R6
  madd57lu Y0, A0, A6, x0
  madd57hu Y1, A0, A6, x0
  madd57lu Y0, A1, A5, Y0
  madd57hu Y1, A1, A5, Y1
  madd57lu Y0, A2, A4, Y0
  madd57hu Y1, A2, A4, Y1
  _ACCU_PRDT_0
  madd57lu Z0, A3, A3, Z0
  madd57hu Z1, A3, A3, Z1
  sd       Z0, 48(a0)
.endm

.macro COMPUTE_R7
  madd57lu Y1, A0, A7, x0
  madd57hu Y0, A0, A7, x0
  madd57lu Y1, A1, A6, Y1
  madd57hu Y0, A1, A6, Y0
  madd57lu Y1, A2, A5, Y1
  madd57hu Y0, A2, A5, Y0
  madd57lu Y1, A3, A4, Y1
  madd57hu Y0, A3, A4, Y0
  _ACCU_PRDT_1
  sd       Z1, 56(a0)
.endm

.macro COMPUTE_R8
  madd57lu Y0, A0, A8, x0
  madd57hu Y1, A0, A8, x0
  madd57lu Y0, A1, A7, Y0
  madd57hu Y1, A1, A7, Y1
  madd57lu Y0, A2, A6, Y0
  madd57hu Y1, A2, A6, Y1
  madd57lu Y0, A3, A5, Y0
  madd57hu Y1, A3, A5, Y1
  _ACCU_PRDT_0
  madd57lu Z0, A4, A4, Z0
  madd57hu Z1, A4, A4, Z1
  sd       Z0, 64(a0)
.endm

.macro COMPUTE_R9
  madd57lu Y1, A1, A8, x0
  madd57hu Y0, A1, A8, x0
  madd57lu Y1, A2, A7, Y1
  madd57hu Y0, A2, A7, Y0
  madd57lu Y1, A3, A6, Y1
  madd57hu Y0, A3, A6, Y0
  madd57lu Y1, A4, A5, Y1
  madd57hu Y0, A4, A5, Y0
  _ACCU_PRDT_1
  sd       Z1, 72(a0)
.endm

.macro COMPUTE_R10
  madd57lu Y0, A2, A8, x0
  madd57hu Y1, A2, A8, x0
  madd57lu Y0, A3, A7, Y0
  madd57hu Y1, A3, A7, Y1
  madd57lu Y0, A4, A6, Y0
  madd57hu Y1, A4, A6, Y1
  _ACCU_PRDT_0
  madd57lu Z0, A5, A5, Z0
  madd57hu Z1, A5, A5, Z1
  sd       Z0, 80(a0)
.endm

.macro COMPUTE_R11
  madd57lu Y1, A3, A8, x0
  madd57hu Y0, A3, A8, x0
  madd57lu Y1, A4, A7, Y1
  madd57hu Y0, A4, A7, Y0
  madd57lu Y1, A5, A6, Y1
  madd57hu Y0, A5, A6, Y0
  _ACCU_PRDT_1
  sd       Z1, 88(a0)
.endm

.macro COMPUTE_R12
  madd57lu Y0, A4, A8, x0
  madd57hu Y1, A4, A8, x0
  madd57lu Y0, A5, A7, Y0
  madd57hu Y1, A5, A7, Y1
  _ACCU_PRDT_0
  madd57lu Z0, A6, A6, Z0
  madd57hu Z1, A6, A6, Z1
  sd       Z0, 96(a0)
.endm

.macro COMPUTE_R13
  madd57lu Y1, A5, A8, x0
  madd57hu Y0, A5, A8, x0
  madd57lu Y1, A6, A7, Y1
  madd57hu Y0, A6, A7, Y0
  _ACCU_PRDT_1
  sd       Z1,104(a0)
.endm

.macro COMPUTE_R14
  madd57lu Y0, A6, A8, x0
  madd57hu Y1, A6, A8, x0
  _ACCU_PRDT_0
  madd57lu Z0, A7, A7, Z0
  madd57hu Z1, A7, A7, Z1
  sd       Z0,112(a0)
.endm

.macro COMPUTE_R15
  madd57lu Y1, A7, A8, x0
  madd57hu Y0, A7, A8, x0
  _ACCU_PRDT_1
  sd       Z1,120(a0)
.endm

.macro COMPUTE_R16
  madd57lu Z0, A8, A8, Z0
  madd57hu Z1, A8, A8, x0
  sd       Z0,128(a0)
.endm

.macro COMPUTE_R17
  sd       Z1,136(a0)
.endm


.section .text

.global uint_sqr2_ps_ise

uint_sqr2_ps_ise:
  PROLOGUE
  LOAD_A
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  COMPUTE_R12
  COMPUTE_R13
  COMPUTE_R14
  COMPUTE_R15
  COMPUTE_R16
  COMPUTE_R17
  EPILOGUE

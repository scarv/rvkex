// void reduce_once_cs_ise(uint64_t *a)
// radix-2^64


#include "ise3.h"


// registers 

// result and operand `r`
#define R0 a5
#define R1 a6
#define R2 a7
#define R3 s0
#define R4 s1
#define R5 s2
#define R6 s3
#define R7 s4

// operand `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a1
#define P5 a2
#define P6 a3
#define P7 a4

// temporary value `t`
#define T0 t0
#define T1 t1
#define T2 t2


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -40
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  addi  sp, sp, 40
  ret 
.endm

// store result

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
  ld    R7, 56(a0)
.endm

.macro STORE_R 
  sd    P0,  0(a0)
  sd    P1,  8(a0)
  sd    P2, 16(a0)
  sd    P3, 24(a0)
  sd    P4, 32(a0)
  sd    P5, 40(a0)
  sd    P6, 48(a0)
  sd    P7, 56(a0)
.endm

// arithmetic computation

.macro _A_SUB_P_0 
  csidh.sub.p512 P0, R0, 0
  sltu           T0, R0, P0
.endm

.macro _A_SUB_P_I R, P, imm
  csidh.sub.p512 \P, \R, \imm
  sltu           T1, \R, \P
  sltu           T2, \P, T0 
  sub            \P, \P, T0
  or             T0, T1, T2
.endm

.macro A_SUB_P
  _A_SUB_P_0
  _A_SUB_P_I R1, P1, 1
  _A_SUB_P_I R2, P2, 2
  _A_SUB_P_I R3, P3, 3
  _A_SUB_P_I R4, P4, 4
  _A_SUB_P_I R5, P5, 5
  _A_SUB_P_I R6, P6, 6
  _A_SUB_P_I R7, P7, 7
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T0
  xor   \P, \P, \R
.endm

.macro CSWAP 
  sub   T0, x0, T0
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
  _CSWAP    R6, P6
  _CSWAP    R7, P7
.endm


.section .text

.global reduce_once_cs_ise

reduce_once_cs_ise:
  PROLOGUE
  LOAD_R
  A_SUB_P
  CSWAP
  STORE_R
  EPILOGUE


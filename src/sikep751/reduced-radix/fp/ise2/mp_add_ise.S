// void mp_add_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction


#include "ise2.h"


// registers

// result "r"
#define R0  t0
#define R1  t1
#define R2  t2
#define R3  t3
#define R4  t4
#define R5  t5
#define R6  t6
#define R7  a7
#define R8  s0
#define R9  s1
#define R10 s2
#define R11 s3
#define R12 s4
#define R13 a3

// operand "a"
#define A_ a4

// operand "b"
#define B_ a5

// constants and masks
#define M0 a6


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

.macro STORE_R 
  sd    R0,   0(a0)
  sd    R1,   8(a0)
  sd    R2,  16(a0)
  sd    R3,  24(a0)
  sd    R4,  32(a0)
  sd    R5,  40(a0)
  sd    R6,  48(a0)
  sd    R7,  56(a0)
  sd    R8,  64(a0)
  sd    R9,  72(a0)
  sd    R10, 80(a0)
  sd    R11, 88(a0)
  sd    R12, 96(a0)
  sd    R13,104(a0)
.endm

// arithmetic computation

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  add   \R, A_, B_
.endm

.macro ADDITION 
  _COMPUTE_R R0,  0
  _COMPUTE_R R1,  1
  _COMPUTE_R R2,  2
  _COMPUTE_R R3,  3
  _COMPUTE_R R4,  4
  _COMPUTE_R R5,  5
  _COMPUTE_R R6,  6
  _COMPUTE_R R7,  7
  _COMPUTE_R R8,  8
  _COMPUTE_R R9,  9
  _COMPUTE_R R10, 10
  _COMPUTE_R R11, 11
  _COMPUTE_R R12, 12
  _COMPUTE_R R13, 13
.endm

// carry propagation

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 56
  and     \A, \A, M0
.endm

.macro CARRY_PROPAGATION
  li    M0, 0xFFFFFFFFFFFFFFULL 
  _PROPAGATE_CARRY R0,  R1
  _PROPAGATE_CARRY R1,  R2
  _PROPAGATE_CARRY R2,  R3
  _PROPAGATE_CARRY R3,  R4
  _PROPAGATE_CARRY R4,  R5
  _PROPAGATE_CARRY R5,  R6
  _PROPAGATE_CARRY R6,  R7
  _PROPAGATE_CARRY R7,  R8
  _PROPAGATE_CARRY R8,  R9
  _PROPAGATE_CARRY R9,  R10
  _PROPAGATE_CARRY R10, R11
  _PROPAGATE_CARRY R11, R12
  _PROPAGATE_CARRY R12, R13
.endm


// integer addition using ISE

.section .text

// v0: conventional one

.global mp_add_v0_ise

mp_add_v0_ise:
  PROLOGUE
  ADDITION
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE

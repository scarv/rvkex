// void mp_sub_p2_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56


#include "../ise2/ise2.h"
#include "ise3.h"


// registers

// result "r"
#define R0 t0
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
#define R6 t6
#define R7 a7

// operand "a"
#define A_ a4

// operand "b"
#define B_ a5

// constants and masks
#define M0 a4


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret 
.endm

// store result 

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
  sd    R7, 56(a0)
.endm

// arithmetic computation

.macro _COMPUTE_R_2P R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sike.add.p434x2.sub56 \R, A_, B_, \imm
.endm

.macro _COMPUTE_R_4P R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sike.add.p434x4.sub56 \R, A_, B_, \imm
.endm

.macro COMPUTE_R P 
  _COMPUTE_R_\P R0, 0
  _COMPUTE_R_\P R1, 1
  _COMPUTE_R_\P R2, 2
  _COMPUTE_R_\P R3, 3
  _COMPUTE_R_\P R4, 4
  _COMPUTE_R_\P R5, 5
  _COMPUTE_R_\P R6, 6
  _COMPUTE_R_\P R7, 7
.endm

// carry propagation

.macro _PROPAGATE_CARRY A, B 
  sraadd \B, \B, \A, 56
  and    \A, \A, M0
.endm

.macro CARRY_PROPAGATION
  li    M0, 0xFFFFFFFFFFFFFFULL 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
  _PROPAGATE_CARRY R6, R7
.endm


// integer subtraction using ISE

.section .text

// v1: using specific-use ISE

.global mp_sub_p2_v1_ise

mp_sub_p2_v1_ise:
  PROLOGUE
  COMPUTE_R 2P
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE

.global mp_sub_p4_v1_ise

mp_sub_p4_v1_ise:
  PROLOGUE
  COMPUTE_R 4P
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE

// void mp_sub_p2_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_sub_p4_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void fpneg_v0_ise(uint64_t *r);
// radix-2^56


#include "ise2.h"


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
#define R8 a3

// operand "a"
#define A_ a4

// operand "b"
#define B_ a5

// modulus "2p" or "4p"
#define P_ a6

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
  sd    R8, 64(a0)
.endm

// arithmetic computation

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  ld    P_, 8*\imm-24(a3)
  add   \R, A_, P_
  sub   \R, \R, B_
.endm

.macro COMPUTE_R imm
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  ld    P_,  0(a3)
  add   R0, A_, P_
  sub   R0, R0, B_
  ld    A_,  8(a1)
  ld    B_,  8(a2)
  addi  P_, P_, \imm
  add   R1, A_, P_
  sub   R1, R1, B_
  ld    A_, 16(a1)
  ld    B_, 16(a2)
  add   R2, A_, P_
  sub   R2, R2, B_
  ld    A_, 24(a1)
  ld    B_, 24(a2)
  add   R3, A_, P_
  sub   R3, R3, B_
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
  _COMPUTE_R R8, 8
.endm

// carry propagation

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 56
  and     \A, \A, M0
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
  _PROPAGATE_CARRY R7, R8
.endm


// integer subtraction using ISE

.section .text

// v0: conventional one

.global mp_sub_p2_v0_ise

mp_sub_p2_v0_ise:
  PROLOGUE
  la a3, P503X2
  COMPUTE_R 1
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.global mp_sub_p4_v0_ise

mp_sub_p4_v0_ise:
  PROLOGUE
  la a3, P503X4
  COMPUTE_R 3
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


// modular negation using ISE

.macro _SUBTRACT R, imm
  ld    A_, 8*\imm(a0)
  ld    P_, 8*\imm-24(a3)
  sub   \R, P_, A_
.endm

.macro SUBTRACTION
  ld    A_,  0(a0)
  ld    P_,  0(a3)
  sub   R0, P_, A_
  ld    A_,  8(a0)
  addi  P_, P_, 1
  sub   R1, P_, A_
  ld    A_, 16(a0)
  sub   R2, P_, A_
  ld    A_, 24(a0)
  sub   R3, P_, A_
  _SUBTRACT R4, 4
  _SUBTRACT R5, 5
  _SUBTRACT R6, 6
  _SUBTRACT R7, 7
  _SUBTRACT R8, 8
.endm

.global fpneg_v0_ise

fpneg_v0_ise:
  PROLOGUE
  la a3, P503X2
  SUBTRACTION
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P503X2:
.dword 0xFFFFFFFFFFFFFE                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
.dword 0x23CF4157FFFFFF                 // P4
.dword 0xFB5E2610B7B444                 // P5
.dword 0xA03737ED90F6FC                 // P6
.dword 0xC08B8D7BB4EF49                 // P7
.dword 0x80CDEA83023C3C                 // P8

P503X4:
.dword 0xFFFFFFFFFFFFFC                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
.dword 0x479E82AFFFFFFF                 // P4
.dword 0xF6BC4C216F6888                 // P5
.dword 0x406E6FDB21EDF9                 // P6
.dword 0x81171AF769DE93                 // P7
.dword 0x1019BD506047879                // P8
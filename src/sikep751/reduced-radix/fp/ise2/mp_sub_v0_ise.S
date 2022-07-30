// void mp_sub_p2_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_sub_p4_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void fpneg_v0_ise(uint64_t *r);
// radix-2^56


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

// modulus "2p" or "4p"
#define P_ a6

// constants and masks
#define M0 a4


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
  ld    P_, 8*\imm-40(a3)
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
  ld    A_, 32(a1)
  ld    B_, 32(a2)
  add   R4, A_, P_
  sub   R4, R4, B_
  ld    A_, 40(a1)
  ld    B_, 40(a2)
  add   R5, A_, P_
  sub   R5, R5, B_
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


// integer subtraction using ISE

.section .text

// v0: conventional one

.global mp_sub_p2_v0_ise

mp_sub_p2_v0_ise:
  PROLOGUE
  la a3, P751X2
  COMPUTE_R 1
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.global mp_sub_p4_v0_ise

mp_sub_p4_v0_ise:
  PROLOGUE
  la a3, P751X4
  COMPUTE_R 3
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


// modular negation using ISE

.macro _SUBTRACT R, imm
  ld    A_, 8*\imm(a0)
  ld    P_, 8*\imm-40(a3)
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
  ld    A_, 32(a0)
  sub   R4, P_, A_
  ld    A_, 40(a0)
  sub   R5, P_, A_
  _SUBTRACT R6, 6
  _SUBTRACT R7, 7
  _SUBTRACT R8, 8
  _SUBTRACT R9, 9
  _SUBTRACT R10, 10
  _SUBTRACT R11, 11
  _SUBTRACT R12, 12
  _SUBTRACT R13, 13
.endm

.global fpneg_v0_ise

fpneg_v0_ise:
  PROLOGUE
  la a3, P751X2
  SUBTRACTION
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P751X2:
.dword 0xFFFFFFFFFFFFFE                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
// .dword 0xFFFFFFFFFFFFFF              // P4
// .dword 0xFFFFFFFFFFFFFF              // P5
.dword 0x51DD5FFFFFFFFF                 // P6
.dword 0xC7D92D0A93F0F1                 // P7
.dword 0x2B363427EF98ED                 // P8
.dword 0x30CFADD7D0EDB5                 // P9
.dword 0x08B964AE90109D                 // P10
.dword 0x2F75B8CD0AC56A                 // P11
.dword 0x83EE381C25213F                 // P12
.dword 0x00000000DFCBAA                 // P13


P751X4:
.dword 0xFFFFFFFFFFFFFC                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
// .dword 0xFFFFFFFFFFFFFF              // P4
// .dword 0xFFFFFFFFFFFFFF              // P5
.dword 0xA3BABFFFFFFFFF                 // P6
.dword 0x8FB25A1527E1E2                 // P7
.dword 0x566C684FDF31DB                 // P8
.dword 0x619F5BAFA1DB6A                 // P9
.dword 0x1172C95D20213A                 // P10
.dword 0x5EEB719A158AD4                 // P11
.dword 0x07DC70384A427E                 // P12
.dword 0x00000001BF9755                 // P13

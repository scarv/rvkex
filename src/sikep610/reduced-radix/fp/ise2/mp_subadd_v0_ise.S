// void mp_subadd_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction, no propagation


#include "ise2.h"


// registers

// result "r"
#define R0  a3
#define R1  a4
#define R2  a5
#define R3  a6
#define R4  a7
#define R5  t3
#define R6  t4
#define R7  t5
#define R8  t1
#define R9  t6
#define R10 s0
#define R11 s1
#define R12 s2
#define R13 s3
#define R14 s4
#define R15 s5
#define R16 s6
#define R17 s7
#define R18 s8
#define R19 s9
#define R20 s10
#define R21 t2

// modulus "p"
#define P0  a3
#define P1  a3
#define P2  a3
#define P3  a3
#define P4  a3
#define P5  a7
#define P6  t3 
#define P7  t4
#define P8  t5
#define P9  a6
#define P10 a4

// operand "a"
#define A_ t0

// operand "b"
#define B_ t2

// temp "t"
#define T_ t0


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -88
  sd    s0,   0(sp)
  sd    s1,   8(sp)
  sd    s2,  16(sp)
  sd    s3,  24(sp)
  sd    s4,  32(sp)
  sd    s5,  40(sp)
  sd    s6,  48(sp)
  sd    s7,  56(sp)
  sd    s8,  64(sp)
  sd    s9,  72(sp)
  sd    s10, 80(sp)
.endm

.macro EPILOGUE
  ld    s0,   0(sp)
  ld    s1,   8(sp)
  ld    s2,  16(sp)
  ld    s3,  24(sp)
  ld    s4,  32(sp)
  ld    s5,  40(sp)
  ld    s6,  48(sp)
  ld    s7,  56(sp)
  ld    s8,  64(sp)
  ld    s9,  72(sp)
  ld    s10, 80(sp)
  addi  sp, sp, 88
  ret 
.endm

// load modulus + store result 

.macro LOAD_P
  la    a2,    P610
  ld    P0,    0(a2)
  ld    P5,    8(a2)
  ld    P6,   16(a2)
  ld    P7,   24(a2)
  ld    P8,   32(a2)
  ld    P9,   40(a2)
  ld    P10,  48(a2)
.endm

.macro STORE_R1ST 
  sd    R0,    0(a0)
  sd    R1,    8(a0)
  sd    R2,   16(a0)
  sd    R3,   24(a0)
  sd    R4,   32(a0)
  sd    R5,   40(a0)
  sd    R6,   48(a0)
  sd    R7,   56(a0)
  sd    R8,   64(a0)
  sd    R9,   72(a0)
  sd    R10,  80(a0)
.endm 

.macro STORE_R2ND 
  sd    R11,  88(a0)
  sd    R12,  96(a0)
  sd    R13, 104(a0)
  sd    R14, 112(a0)
  sd    R15, 120(a0)
  sd    R16, 128(a0)
  sd    R17, 136(a0)
  sd    R18, 144(a0)
  sd    R19, 152(a0)
  sd    R20, 160(a0)
  sd    R21, 168(a0)
.endm

// arithmetic computation

.macro _SUBTRACT R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sub   \R, A_, B_
.endm

.macro SUBTRACTION
  _SUBTRACT R0,   0 
  _SUBTRACT R1,   1
  _SUBTRACT R2,   2
  _SUBTRACT R3,   3
  _SUBTRACT R4,   4
  _SUBTRACT R5,   5
  _SUBTRACT R6,   6
  _SUBTRACT R7,   7
  _SUBTRACT R8,   8 
  _SUBTRACT R9,   9
  _SUBTRACT R10, 10
  _SUBTRACT R11, 11
  _SUBTRACT R12, 12
  _SUBTRACT R13, 13
  _SUBTRACT R14, 14
  _SUBTRACT R15, 15
  _SUBTRACT R16, 16
  _SUBTRACT R17, 17
  _SUBTRACT R18, 18
  _SUBTRACT R19, 19
  _SUBTRACT R20, 20
  _SUBTRACT R21, 21
.endm

// carry propagation

.macro GET_SIGN 
  sraiadd T_, R1,  R0, 56
  sraiadd T_, R2,  T_, 56
  sraiadd T_, R3,  T_, 56
  sraiadd T_, R4,  T_, 56
  sraiadd T_, R5,  T_, 56
  sraiadd T_, R6,  T_, 56
  sraiadd T_, R7,  T_, 56
  sraiadd T_, R8,  T_, 56
  sraiadd T_, R9,  T_, 56
  sraiadd T_, R10, T_, 56
  sraiadd T_, R11, T_, 56
  sraiadd T_, R12, T_, 56
  sraiadd T_, R13, T_, 56
  sraiadd T_, R14, T_, 56
  sraiadd T_, R15, T_, 56
  sraiadd T_, R16, T_, 56
  sraiadd T_, R17, T_, 56
  sraiadd T_, R18, T_, 56
  sraiadd T_, R19, T_, 56
  sraiadd T_, R20, T_, 56
  sraiadd T_, R21, T_, 56
  srai    T_, T_, 63
.endm

.macro MASK_P
  and   P0, P0, T_
//and   P1, P1, T_
//and   P2, P2, T_
//and   P3, P3, T_
//and   P4, P4, T_
  and   P5, P5, T_
  and   P6, P6, T_
  and   P7, P7, T_
  and   P8, P8, T_
  and   P9, P9, T_
  and   P10, P10, T_
.endm

.macro ADD_MASK 
  add   R11, R11, P0
  add   R12, R12, P1
  add   R13, R13, P2
  add   R14, R14, P3
  add   R15, R15, P4
  add   R16, R16, P5
  add   R17, R17, P6
  add   R18, R18, P7
  add   R19, R19, P8
  add   R20, R20, P9
  add   R21, R21, P10
.endm

// integer subadd using ISE

.section .text

// v0: conventional one

.global mp_subadd_v0_ise

mp_subadd_v0_ise:
  PROLOGUE
  SUBTRACTION
  GET_SIGN
  STORE_R1ST
  LOAD_P
  MASK_P
  ADD_MASK
  STORE_R2ND
  EPILOGUE


.section .data 
.balign 8

P610:
.dword 0xFFFFFFFFFFFFFF                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
// .dword 0xFFFFFFFFFFFFFF              // P4
.dword 0xB02E6E01FFFFFF                 // P5
.dword 0xABB1784DE8AA5A                 // P6
.dword 0x9AE7BF45048FF9                 // P7
.dword 0x55B2FA10C4252A                 // P8
.dword 0x10C251E7D88CB2                 // P9
.dword 0x027BF6A7688190                 // P10
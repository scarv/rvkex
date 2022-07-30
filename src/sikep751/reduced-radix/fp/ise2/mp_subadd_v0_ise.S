// void mp_subadd_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction, no propagation


#include "ise2.h"


// registers

// result "r"
#define R0  t3
#define R1  t4
#define R2  t5
#define R3  t6
#define R4  a3
#define R5  a4
#define R6  a5
#define R7  a6
#define R8  a7
#define R9  s0
#define R10 s1
#define R11 s2
#define R12 s3
#define R13 s4

#define R14 s0
#define R15 s1
#define R16 s2
#define R17 s3
#define R18 s4
#define R19 s5
#define R20 s6
#define R21 s7
#define R22 s8
#define R23 s9
#define R24 s10
#define R25 s11
#define R26 t2
#define R27 a2


// modulus "p"
#define P0  t3
#define P1  t3
#define P2  t3
#define P3  t3
#define P4  t3
#define P5  t3
#define P6  t4 
#define P7  t5
#define P8  t6
#define P9  a3
#define P10 a4
#define P11 a5
#define P12 a6
#define P13 a7

// operand "a"
#define A_ t0

// operand "b"
#define B_ t1

// temp "t"
#define T_ t0


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -104
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
  sd    s11, 88(sp)
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
  ld    s11, 88(sp)
  addi  sp, sp, 104 
  ret 
.endm

// load modulus + store result 

.macro LOAD_P
  la    t0, P751
  ld    P0,   0(t0)
  ld    P6,   8(t0)
  ld    P7,  16(t0)
  ld    P8,  24(t0)
  ld    P9,  32(t0)
  ld    P10, 40(t0)
  ld    P11, 48(t0)
  ld    P12, 56(t0)
  ld    P13, 64(t0)
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
  sd    R11,  88(a0)
  sd    R12,  96(a0)
  sd    R13, 104(a0)
.endm 

.macro STORE_R2ND 
  sd    R14, 112(a0)
  sd    R15, 120(a0)
  sd    R16, 128(a0)
  sd    R17, 136(a0)
  sd    R18, 144(a0)
  sd    R19, 152(a0)
  sd    R20, 160(a0)
  sd    R21, 168(a0)
  sd    R22, 176(a0) 
  sd    R23, 184(a0)
  sd    R24, 192(a0)
  sd    R25, 200(a0)
  sd    R26, 208(a0)
  sd    R27, 216(a0)
.endm

// arithmetic computation

.macro _SUBTRACT R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sub   \R, A_, B_
.endm

.macro SUBTRACTION_R1ST
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
.endm

.macro SUBTRACTION_R2ND
  _SUBTRACT R14, 14
  _SUBTRACT R15, 15
  _SUBTRACT R16, 16
  _SUBTRACT R17, 17
  _SUBTRACT R18, 18
  _SUBTRACT R19, 19
  _SUBTRACT R20, 20
  _SUBTRACT R21, 21
  _SUBTRACT R22, 22
  _SUBTRACT R23, 23
  _SUBTRACT R24, 24
  _SUBTRACT R25, 25
  _SUBTRACT R26, 26
  _SUBTRACT R27, 27
.endm

// carry propagation

.macro GET_SIGN_R1ST 
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
.endm

.macro GET_SIGN_R2ND
  sraiadd T_, R14, T_, 56
  sraiadd T_, R15, T_, 56
  sraiadd T_, R16, T_, 56
  sraiadd T_, R17, T_, 56
  sraiadd T_, R18, T_, 56
  sraiadd T_, R19, T_, 56
  sraiadd T_, R20, T_, 56
  sraiadd T_, R21, T_, 56
  sraiadd T_, R22, T_, 56
  sraiadd T_, R23, T_, 56
  sraiadd T_, R24, T_, 56
  sraiadd T_, R25, T_, 56
  sraiadd T_, R26, T_, 56
  sraiadd T_, R27, T_, 56
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
  and   P11, P11, T_
  and   P12, P12, T_
  and   P13, P13, T_
.endm

.macro ADD_MASK
  add   R14, R14, P0
  add   R15, R15, P1
  add   R16, R16, P2
  add   R17, R17, P3
  add   R18, R18, P4
  add   R19, R19, P5
  add   R20, R20, P6
  add   R21, R21, P7
  add   R22, R22, P8
  add   R23, R23, P9
  add   R24, R24, P10
  add   R25, R25, P11
  add   R26, R26, P12
  add   R27, R27, P13
.endm

// integer subadd using ISE

.section .text

// v0: conventional one

.global mp_subadd_v0_ise

mp_subadd_v0_ise:
  PROLOGUE
  SUBTRACTION_R1ST
  GET_SIGN_R1ST
  STORE_R1ST
  sd T_, 96(sp)
  LOAD_P
  SUBTRACTION_R2ND
  ld T_, 96(sp)
  GET_SIGN_R2ND
  MASK_P
  ADD_MASK
  STORE_R2ND
  EPILOGUE


.section .data 
.balign 8

P751:
.dword 0xFFFFFFFFFFFFFF                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
// .dword 0xFFFFFFFFFFFFFF              // P4
// .dword 0xFFFFFFFFFFFFFF              // P5
.dword 0xA8EEAFFFFFFFFF                 // P6
.dword 0xE3EC968549F878                 // P7
.dword 0x959B1A13F7CC76                 // P8
.dword 0x9867D6EBE876DA                 // P9
.dword 0x045CB25748084E                 // P10
.dword 0x97BADC668562B5                 // P11
.dword 0x41F71C0E12909F                 // P12
.dword 0x000000006FE5D5                 // P13
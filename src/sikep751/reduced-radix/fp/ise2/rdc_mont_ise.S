// void rdc_mont_v0_ise(uint64_t *r, const uint64_t *a);
// radix-2^56, product-scanning


#include "ise2.h"


// registers

// accumulator "z"
#define ZL  t0
#define ZH  t1

// modulus "p+1"
#define P6  t3
#define P7  t4
#define P8  t5
#define P9  t6
#define P10 a7
#define P11 s6
#define P12 s7
#define P13 s8

// operand "a"
#define A0  s0
#define A1  s1
#define A2  s2
#define A3  t2
#define A4  a4
#define A5  a5
#define A6  a2
#define A7  a3
#define A8  s3
#define A9  s4
#define A10 s5
#define A11 s9
#define A12 s10
#define A13 s11

// constants and masks
#define M0  a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -96
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
  li    M0, 0xFFFFFFFFFFFFFFULL
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
  addi  sp, sp, 96 
  ret 
.endm

// load operand

.macro LOAD_A
  ld    A0,   0(a1)
  ld    A1,   8(a1)
  ld    A2,  16(a1)
  ld    A3,  24(a1)
  ld    A4,  32(a1)
  ld    A5,  40(a1)
  ld    A6,  48(a1)
  ld    A7,  56(a1)
  ld    A8,  64(a1)
  ld    A9,  72(a1)
  ld    A10, 80(a1)
  ld    A11, 88(a1)
  ld    A12, 96(a1)
  ld    A13,104(a1)
.endm 

.macro LOAD_P 
  la    t0, P751P1
  ld    P6,   0(t0)
  ld    P7,   8(t0)
  ld    P8,  16(t0)
  ld    P9,  24(t0)
  ld    P10, 32(t0)
  ld    P11, 40(t0)
  ld    P12, 48(t0)
  ld    P13, 56(t0)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 56
  and     \A, \A, M0
.endm

.macro PRE_PROPAGATION
  _PROPAGATE_CARRY A0, A1
  _PROPAGATE_CARRY A1, A2
  _PROPAGATE_CARRY A2, A3
  _PROPAGATE_CARRY A3, A4
  _PROPAGATE_CARRY A4, A5
  _PROPAGATE_CARRY A5, A6
.endm

.macro COMPUTE_A6
  madd56lu A6, A0, P6, A6
  madd56hu A7, A0, P6, A7
  _PROPAGATE_CARRY A6, A7
.endm

.macro COMPUTE_A7
  madd56lu A7, A0, P7, A7
  madd56hu A8, A0, P7, A8
  madd56lu A7, A1, P6, A7
  madd56hu A8, A1, P6, A8
  _PROPAGATE_CARRY A7, A8
.endm

.macro COMPUTE_A8
  madd56lu A8, A0, P8, A8
  madd56hu A9, A0, P8, A9
  madd56lu A8, A1, P7, A8
  madd56hu A9, A1, P7, A9
  madd56lu A8, A2, P6, A8
  madd56hu A9, A2, P6, A9
  _PROPAGATE_CARRY A8, A9
.endm

.macro COMPUTE_A9
  madd56lu A9,  A0, P9, A9
  madd56hu A10, A0, P9, A10
  madd56lu A9,  A1, P8, A9
  madd56hu A10, A1, P8, A10
  madd56lu A9,  A2, P7, A9
  madd56hu A10, A2, P7, A10
  madd56lu A9,  A3, P6, A9
  madd56hu A10, A3, P6, A10
  _PROPAGATE_CARRY  A9, A10
.endm

.macro COMPUTE_A10
  madd56lu A10, A0,  P10, A10
  madd56hu A11, A0,  P10, A11
  madd56lu A10, A1,  P9,  A10
  madd56hu A11, A1,  P9,  A11
  madd56lu A10, A2,  P8,  A10
  madd56hu A11, A2,  P8,  A11
  madd56lu A10, A3,  P7,  A10
  madd56hu A11, A3,  P7,  A11
  madd56lu A10, A4,  P6,  A10
  madd56hu A11, A4,  P6,  A11
  _PROPAGATE_CARRY   A10, A11
.endm

.macro COMPUTE_A11
  madd56lu A11, A0,  P11, A11
  madd56hu A12, A0,  P11, A12
  madd56lu A11, A1,  P10, A11
  madd56hu A12, A1,  P10, A12
  madd56lu A11, A2,  P9,  A11
  madd56hu A12, A2,  P9,  A12
  madd56lu A11, A3,  P8,  A11
  madd56hu A12, A3,  P8,  A12
  madd56lu A11, A4,  P7,  A11
  madd56hu A12, A4,  P7,  A12
  madd56lu A11, A5,  P6,  A11
  madd56hu A12, A5,  P6,  A12
  _PROPAGATE_CARRY   A11, A12
.endm

.macro COMPUTE_A12
  madd56lu A12, A0,  P12, A12
  madd56hu A13, A0,  P12, A13
  madd56lu A12, A1,  P11, A12
  madd56hu A13, A1,  P11, A13
  madd56lu A12, A2,  P10, A12
  madd56hu A13, A2,  P10, A13
  madd56lu A12, A3,  P9,  A12
  madd56hu A13, A3,  P9,  A13
  madd56lu A12, A4,  P8,  A12
  madd56hu A13, A4,  P8,  A13
  madd56lu A12, A5,  P7,  A12
  madd56hu A13, A5,  P7,  A13
  madd56lu A12, A6,  P6,  A12
  madd56hu A13, A6,  P6,  A13
  _PROPAGATE_CARRY   A12, A13
.endm

.macro COMPUTE_A13
  ld       ZL,112(a1)
  madd56lu A13, A0,  P13, A13
  madd56hu ZL,  A0,  P13, ZL
  madd56lu A13, A1,  P12, A13
  madd56hu ZL,  A1,  P12, ZL
  madd56lu A13, A2,  P11, A13
  madd56hu ZL,  A2,  P11, ZL
  madd56lu A13, A3,  P10, A13
  madd56hu ZL,  A3,  P10, ZL
  madd56lu A13, A4,  P9,  A13
  madd56hu ZL,  A4,  P9,  ZL
  madd56lu A13, A5,  P8,  A13
  madd56hu ZL,  A5,  P8,  ZL
  madd56lu A13, A6,  P7,  A13
  madd56hu ZL,  A6,  P7,  ZL
  madd56lu A13, A7,  P6,  A13
  madd56hu ZL,  A7,  P6,  ZL
  _PROPAGATE_CARRY   A13, ZL
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld       ZH,120(a1)
  madd56lu ZL, A1,  P13, ZL
  madd56hu ZH, A1,  P13, ZH
  madd56lu ZL, A2,  P12, ZL
  madd56hu ZH, A2,  P12, ZH
  madd56lu ZL, A3,  P11, ZL
  madd56hu ZH, A3,  P11, ZH
  madd56lu ZL, A4,  P10, ZL
  madd56hu ZH, A4,  P10, ZH
  madd56lu ZL, A5,  P9,  ZL
  madd56hu ZH, A5,  P9,  ZH
  madd56lu ZL, A6,  P8,  ZL
  madd56hu ZH, A6,  P8,  ZH
  madd56lu ZL, A7,  P7,  ZL
  madd56hu ZH, A7,  P7,  ZH
  madd56lu ZL, A8,  P6,  ZL
  madd56hu ZH, A8,  P6,  ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL,  0(a0)
.endm

.macro COMPUTE_R1
  ld       ZL,128(a1)
  madd56lu ZH, A2,  P13, ZH
  madd56hu ZL, A2,  P13, ZL
  madd56lu ZH, A3,  P12, ZH
  madd56hu ZL, A3,  P12, ZL
  madd56lu ZH, A4,  P11, ZH
  madd56hu ZL, A4,  P11, ZL
  madd56lu ZH, A5,  P10, ZH
  madd56hu ZL, A5,  P10, ZL
  madd56lu ZH, A6,  P9,  ZH
  madd56hu ZL, A6,  P9,  ZL
  madd56lu ZH, A7,  P8,  ZH
  madd56hu ZL, A7,  P8,  ZL
  madd56lu ZH, A8,  P7,  ZH
  madd56hu ZL, A8,  P7,  ZL
  madd56lu ZH, A9,  P6,  ZH
  madd56hu ZL, A9,  P6,  ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH,  8(a0)
.endm

.macro COMPUTE_R2
  ld       ZH,136(a1)
  madd56lu ZL, A3,  P13, ZL
  madd56hu ZH, A3,  P13, ZH
  madd56lu ZL, A4,  P12, ZL
  madd56hu ZH, A4,  P12, ZH
  madd56lu ZL, A5,  P11, ZL
  madd56hu ZH, A5,  P11, ZH
  madd56lu ZL, A6,  P10, ZL
  madd56hu ZH, A6,  P10, ZH
  madd56lu ZL, A7,  P9,  ZL
  madd56hu ZH, A7,  P9,  ZH
  madd56lu ZL, A8,  P8,  ZL
  madd56hu ZH, A8,  P8,  ZH
  madd56lu ZL, A9,  P7,  ZL
  madd56hu ZH, A9,  P7,  ZH
  madd56lu ZL, A10, P6,  ZL
  madd56hu ZH, A10, P6,  ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 16(a0)
.endm

.macro COMPUTE_R3
  ld       ZL,144(a1)
  madd56lu ZH, A4,  P13, ZH
  madd56hu ZL, A4,  P13, ZL
  madd56lu ZH, A5,  P12, ZH
  madd56hu ZL, A5,  P12, ZL
  madd56lu ZH, A6,  P11, ZH
  madd56hu ZL, A6,  P11, ZL
  madd56lu ZH, A7,  P10, ZH
  madd56hu ZL, A7,  P10, ZL
  madd56lu ZH, A8,  P9,  ZH
  madd56hu ZL, A8,  P9,  ZL
  madd56lu ZH, A9,  P8,  ZH
  madd56hu ZL, A9,  P8,  ZL
  madd56lu ZH, A10, P7,  ZH
  madd56hu ZL, A10, P7,  ZL
  madd56lu ZH, A11, P6,  ZH
  madd56hu ZL, A11, P6,  ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH, 24(a0)
.endm

.macro COMPUTE_R4
  ld       ZH,152(a1)
  madd56lu ZL, A5,  P13, ZL
  madd56hu ZH, A5,  P13, ZH
  madd56lu ZL, A6,  P12, ZL
  madd56hu ZH, A6,  P12, ZH
  madd56lu ZL, A7,  P11, ZL
  madd56hu ZH, A7,  P11, ZH
  madd56lu ZL, A8,  P10, ZL
  madd56hu ZH, A8,  P10, ZH
  madd56lu ZL, A9,  P9,  ZL
  madd56hu ZH, A9,  P9,  ZH
  madd56lu ZL, A10, P8,  ZL
  madd56hu ZH, A10, P8,  ZH
  madd56lu ZL, A11, P7,  ZL
  madd56hu ZH, A11, P7,  ZH
  madd56lu ZL, A12, P6,  ZL
  madd56hu ZH, A12, P6,  ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 32(a0)
.endm

.macro COMPUTE_R5
  ld       ZL,160(a1)
  madd56lu ZH, A6,  P13, ZH
  madd56hu ZL, A6,  P13, ZL
  madd56lu ZH, A7,  P12, ZH
  madd56hu ZL, A7,  P12, ZL
  madd56lu ZH, A8,  P11, ZH
  madd56hu ZL, A8,  P11, ZL
  madd56lu ZH, A9,  P10, ZH
  madd56hu ZL, A9,  P10, ZL
  madd56lu ZH, A10, P9,  ZH
  madd56hu ZL, A10, P9,  ZL
  madd56lu ZH, A11, P8,  ZH
  madd56hu ZL, A11, P8,  ZL
  madd56lu ZH, A12, P7,  ZH
  madd56hu ZL, A12, P7,  ZL
  madd56lu ZH, A13, P6,  ZH
  madd56hu ZL, A13, P6,  ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH, 40(a0)
.endm

.macro COMPUTE_R6
  ld       ZH,168(a1)
  madd56lu ZL, A7,  P13, ZL
  madd56hu ZH, A7,  P13, ZH
  madd56lu ZL, A8,  P12, ZL
  madd56hu ZH, A8,  P12, ZH
  madd56lu ZL, A9,  P11, ZL
  madd56hu ZH, A9,  P11, ZH
  madd56lu ZL, A10, P10, ZL
  madd56hu ZH, A10, P10, ZH
  madd56lu ZL, A11, P9,  ZL
  madd56hu ZH, A11, P9,  ZH
  madd56lu ZL, A12, P8,  ZL
  madd56hu ZH, A12, P8,  ZH
  madd56lu ZL, A13, P7,  ZL
  madd56hu ZH, A13, P7,  ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 48(a0)
.endm

.macro COMPUTE_R7
  ld       ZL,176(a1)
  madd56lu ZH, A8,  P13, ZH
  madd56hu ZL, A8,  P13, ZL
  madd56lu ZH, A9,  P12, ZH
  madd56hu ZL, A9,  P12, ZL
  madd56lu ZH, A10, P11, ZH
  madd56hu ZL, A10, P11, ZL
  madd56lu ZH, A11, P10, ZH
  madd56hu ZL, A11, P10, ZL
  madd56lu ZH, A12, P9,  ZH
  madd56hu ZL, A12, P9,  ZL
  madd56lu ZH, A13, P8,  ZH
  madd56hu ZL, A13, P8,  ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH, 56(a0)
.endm

.macro COMPUTE_R8
  ld       ZH,184(a1)
  madd56lu ZL, A9,  P13, ZL
  madd56hu ZH, A9,  P13, ZH
  madd56lu ZL, A10, P12, ZL
  madd56hu ZH, A10, P12, ZH
  madd56lu ZL, A11, P11, ZL
  madd56hu ZH, A11, P11, ZH
  madd56lu ZL, A12, P10, ZL
  madd56hu ZH, A12, P10, ZH
  madd56lu ZL, A13, P9,  ZL
  madd56hu ZH, A13, P9,  ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 64(a0)
.endm

.macro COMPUTE_R9
  ld       ZL,192(a1)
  madd56lu ZH, A10, P13, ZH
  madd56hu ZL, A10, P13, ZL
  madd56lu ZH, A11, P12, ZH
  madd56hu ZL, A11, P12, ZL
  madd56lu ZH, A12, P11, ZH
  madd56hu ZL, A12, P11, ZL
  madd56lu ZH, A13, P10, ZH
  madd56hu ZL, A13, P10, ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH, 72(a0)
.endm

.macro COMPUTE_R10
  ld       ZH,200(a1)
  madd56lu ZL, A11, P13, ZL
  madd56hu ZH, A11, P13, ZH
  madd56lu ZL, A12, P12, ZL
  madd56hu ZH, A12, P12, ZH
  madd56lu ZL, A13, P11, ZL
  madd56hu ZH, A13, P11, ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 80(a0)
.endm

.macro COMPUTE_R11
  ld       ZL,208(a1)
  madd56lu ZH, A12, P13, ZH
  madd56hu ZL, A12, P13, ZL
  madd56lu ZH, A13, P12, ZH
  madd56hu ZL, A13, P12, ZL
  _PROPAGATE_CARRY  ZH,  ZL
  sd       ZH, 88(a0)
.endm

.macro COMPUTE_R12
  ld       ZH,216(a1)
  madd56lu ZL, A13, P13, ZL
  madd56hu ZH, A13, P13, ZH
  _PROPAGATE_CARRY  ZL,  ZH
  sd       ZL, 96(a0)
.endm

.macro COMPUTE_R13
  sd       ZH,104(a0)
.endm


// Montgomery reduction using ISE

.section .text

// v0: conventional product-scanning

.global rdc_mont_v0_ise

rdc_mont_v0_ise:
  PROLOGUE
  LOAD_A
  LOAD_P
  PRE_PROPAGATION
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_A8
  COMPUTE_A9
  COMPUTE_A10
  COMPUTE_A11
  COMPUTE_A12
  COMPUTE_A13
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
  EPILOGUE


.section .data 

.balign 8 

P751P1:
.dword 0xA8EEB000000000                 // P6
.dword 0xE3EC968549F878                 // P7
.dword 0x959B1A13F7CC76                 // P8
.dword 0x9867D6EBE876DA                 // P9
.dword 0x045CB25748084E                 // P10
.dword 0x97BADC668562B5                 // P11
.dword 0x41F71C0E12909F                 // P12
.dword 0x000000006FE5D5                 // P13

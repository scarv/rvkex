// void rdc_mont_v0_ise(uint64_t *r, const uint64_t *a);
// radix-2^56, product-scanning


#include "ise.h"


// registers

// accumulator "z"
#define ZL t0
#define ZH t1

// modulus "p+1"
#define P3 t3
#define P4 t4
#define P5 t5
#define P6 t6
#define P7 a7

// operand "a"
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 t2
#define A4 a4
#define A5 a5
#define A6 a2
#define A7 a3

// constants and masks
#define M0 a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -24
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  li    M0, 0xFFFFFFFFFFFFFFULL
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
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
  ld    A7, 56(a1)
.endm 

.macro LOAD_P
  la    t0, P434P1
  ld    P3,  0(t0)
  ld    P4,  8(t0)
  ld    P5, 16(t0)
  ld    P6, 24(t0)
  ld    P7, 32(t0)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _PROPAGATE_CARRY A, B 
  sraadd \B, \B, \A, 56
  and    \A, \A, M0
.endm

.macro PRE_PROPAGATION
  _PROPAGATE_CARRY A0, A1
  _PROPAGATE_CARRY A1, A2
  _PROPAGATE_CARRY A2, A3
.endm

.macro COMPUTE_A3
  macc56lo A3, A0, P3, A3
  macc56hi A4, A0, P3, A4
  _PROPAGATE_CARRY A3, A4
.endm

.macro COMPUTE_A4
  macc56lo A4, A0, P4, A4
  macc56hi A5, A0, P4, A5
  macc56lo A4, A1, P3, A4
  macc56hi A5, A1, P3, A5
  _PROPAGATE_CARRY A4, A5
.endm

.macro COMPUTE_A5
  macc56lo A5, A0, P5, A5
  macc56hi A6, A0, P5, A6
  macc56lo A5, A1, P4, A5
  macc56hi A6, A1, P4, A6
  macc56lo A5, A2, P3, A5
  macc56hi A6, A2, P3, A6
  _PROPAGATE_CARRY A5, A6
.endm

.macro COMPUTE_A6
  macc56lo A6, A0, P6, A6
  macc56hi A7, A0, P6, A7
  macc56lo A6, A1, P5, A6
  macc56hi A7, A1, P5, A7
  macc56lo A6, A2, P4, A6
  macc56hi A7, A2, P4, A7
  macc56lo A6, A3, P3, A6
  macc56hi A7, A3, P3, A7
  _PROPAGATE_CARRY A6, A7
.endm

.macro COMPUTE_A7
  ld       ZL, 64(a1)
  macc56lo A7, A0, P7, A7
  macc56hi ZL, A0, P7, ZL
  macc56lo A7, A1, P6, A7
  macc56hi ZL, A1, P6, ZL
  macc56lo A7, A2, P5, A7
  macc56hi ZL, A2, P5, ZL
  macc56lo A7, A3, P4, A7
  macc56hi ZL, A3, P4, ZL
  macc56lo A7, A4, P3, A7
  macc56hi ZL, A4, P3, ZL
  _PROPAGATE_CARRY A7, ZL
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld       ZH, 72(a1)
  macc56lo ZL, A1, P7, ZL
  macc56hi ZH, A1, P7, ZH
  macc56lo ZL, A2, P6, ZL
  macc56hi ZH, A2, P6, ZH
  macc56lo ZL, A3, P5, ZL
  macc56hi ZH, A3, P5, ZH
  macc56lo ZL, A4, P4, ZL
  macc56hi ZH, A4, P4, ZH
  macc56lo ZL, A5, P3, ZL
  macc56hi ZH, A5, P3, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL,  0(a0)
.endm

.macro COMPUTE_R1
  ld       ZL, 80(a1)
  macc56lo ZH, A2, P7, ZH
  macc56hi ZL, A2, P7, ZL
  macc56lo ZH, A3, P6, ZH
  macc56hi ZL, A3, P6, ZL
  macc56lo ZH, A4, P5, ZH
  macc56hi ZL, A4, P5, ZL
  macc56lo ZH, A5, P4, ZH
  macc56hi ZL, A5, P4, ZL
  macc56lo ZH, A6, P3, ZH
  macc56hi ZL, A6, P3, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH,  8(a0)
.endm

.macro COMPUTE_R2
  ld       ZH, 88(a1)
  macc56lo ZL, A3, P7, ZL
  macc56hi ZH, A3, P7, ZH
  macc56lo ZL, A4, P6, ZL
  macc56hi ZH, A4, P6, ZH
  macc56lo ZL, A5, P5, ZL
  macc56hi ZH, A5, P5, ZH
  macc56lo ZL, A6, P4, ZL
  macc56hi ZH, A6, P4, ZH
  macc56lo ZL, A7, P3, ZL
  macc56hi ZH, A7, P3, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 16(a0)
.endm

.macro COMPUTE_R3
  ld       ZL, 96(a1)
  macc56lo ZH, A4, P7, ZH
  macc56hi ZL, A4, P7, ZL
  macc56lo ZH, A5, P6, ZH
  macc56hi ZL, A5, P6, ZL
  macc56lo ZH, A6, P5, ZH
  macc56hi ZL, A6, P5, ZL
  macc56lo ZH, A7, P4, ZH
  macc56hi ZL, A7, P4, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH, 24(a0)
.endm

.macro COMPUTE_R4
  ld       ZH,104(a1)
  macc56lo ZL, A5, P7, ZL
  macc56hi ZH, A5, P7, ZH
  macc56lo ZL, A6, P6, ZL
  macc56hi ZH, A6, P6, ZH
  macc56lo ZL, A7, P5, ZL
  macc56hi ZH, A7, P5, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 32(a0)
.endm

.macro COMPUTE_R5
  ld       ZL,112(a1)
  macc56lo ZH, A6, P7, ZH
  macc56hi ZL, A6, P7, ZL
  macc56lo ZH, A7, P6, ZH
  macc56hi ZL, A7, P6, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH, 40(a0)
.endm

.macro COMPUTE_R6
  ld       ZH,120(a1)
  macc56lo ZL, A7, P7, ZL
  macc56hi ZH, A7, P7, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 48(a0)
.endm

.macro COMPUTE_R7
  sd       ZH, 56(a0)
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
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  EPILOGUE


.section .data 

.balign 8 

P434P1:
.dword 0xE3000000000000                 // P3
.dword 0x58AEA3FDC1767A                 // P4
.dword 0x20567BC65C7831                 // P5
.dword 0x446CFC5FD681C5                 // P6
.dword 0x0002341F271773                 // P7

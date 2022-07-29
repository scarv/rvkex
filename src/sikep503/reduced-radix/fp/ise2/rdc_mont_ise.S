// void rdc_mont_v0_ise(uint64_t *r, const uint64_t *a);
// radix-2^56, product-scanning


#include "ise2.h"


// registers

// accumulator "z"
#define ZL t0
#define ZH t1

// modulus "p+1"
#define P4 t3
#define P5 t4
#define P6 t5
#define P7 t6
#define P8 a7

// operand "a"
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 t2
#define A4 a4
#define A5 a5
#define A6 a2
#define A7 a3
#define A8 s3
#define A9 s4

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
  li    M0, 0xFFFFFFFFFFFFFFULL
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
  ld    A9, 72(a1)
.endm 

.macro LOAD_P
  la    t0, P503P1
  ld    P4,  0(t0)
  ld    P5,  8(t0)
  ld    P6, 16(t0)
  ld    P7, 24(t0)
  ld    P8, 32(t0)
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
.endm

.macro COMPUTE_A4
  madd56lu A4, A0, P4, A4
  madd56hu A5, A0, P4, A5
  _PROPAGATE_CARRY A4, A5
.endm

.macro COMPUTE_A5
  madd56lu A5, A0, P5, A5
  madd56hu A6, A0, P5, A6
  madd56lu A5, A1, P4, A5
  madd56hu A6, A1, P4, A6
  _PROPAGATE_CARRY A5, A6
.endm

.macro COMPUTE_A6
  madd56lu A6, A0, P6, A6
  madd56hu A7, A0, P6, A7
  madd56lu A6, A1, P5, A6
  madd56hu A7, A1, P5, A7
  madd56lu A6, A2, P4, A6
  madd56hu A7, A2, P4, A7
  _PROPAGATE_CARRY A6, A7
.endm

.macro COMPUTE_A7
  madd56lu A7, A0, P7, A7
  madd56hu A8, A0, P7, A8
  madd56lu A7, A1, P6, A7
  madd56hu A8, A1, P6, A8
  madd56lu A7, A2, P5, A7
  madd56hu A8, A2, P5, A8
  madd56lu A7, A3, P4, A7
  madd56hu A8, A3, P4, A8
  _PROPAGATE_CARRY A7, A8
.endm

.macro COMPUTE_A8
  madd56lu A8, A0, P8, A8
  madd56hu A9, A0, P8, A9
  madd56lu A8, A1, P7, A8
  madd56hu A9, A1, P7, A9
  madd56lu A8, A2, P6, A8
  madd56hu A9, A2, P6, A9
  madd56lu A8, A3, P5, A8
  madd56hu A9, A3, P5, A9
  madd56lu A8, A4, P4, A8
  madd56hu A9, A4, P4, A9
  _PROPAGATE_CARRY A8, A9
.endm

.macro COMPUTE_A9 
  ld       ZL, 80(a1)
  madd56lu A9, A1, P8, A9
  madd56hu ZL, A1, P8, ZL
  madd56lu A9, A2, P7, A9
  madd56hu ZL, A2, P7, ZL
  madd56lu A9, A3, P6, A9
  madd56hu ZL, A3, P6, ZL
  madd56lu A9, A4, P5, A9
  madd56hu ZL, A4, P5, ZL
  madd56lu A9, A5, P4, A9
  madd56hu ZL, A5, P4, ZL
  _PROPAGATE_CARRY A9, ZL
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld       ZH, 88(a1)
  madd56lu ZL, A2, P8, ZL
  madd56hu ZH, A2, P8, ZH
  madd56lu ZL, A3, P7, ZL
  madd56hu ZH, A3, P7, ZH
  madd56lu ZL, A4, P6, ZL
  madd56hu ZH, A4, P6, ZH
  madd56lu ZL, A5, P5, ZL
  madd56hu ZH, A5, P5, ZH
  madd56lu ZL, A6, P4, ZL
  madd56hu ZH, A6, P4, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL,  0(a0)
.endm

.macro COMPUTE_R1
  ld       ZL, 96(a1)
  madd56lu ZH, A3, P8, ZH
  madd56hu ZL, A3, P8, ZL
  madd56lu ZH, A4, P7, ZH
  madd56hu ZL, A4, P7, ZL
  madd56lu ZH, A5, P6, ZH
  madd56hu ZL, A5, P6, ZL
  madd56lu ZH, A6, P5, ZH
  madd56hu ZL, A6, P5, ZL
  madd56lu ZH, A7, P4, ZH
  madd56hu ZL, A7, P4, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH,  8(a0)
.endm

.macro COMPUTE_R2
  ld       ZH,104(a1)
  madd56lu ZL, A4, P8, ZL
  madd56hu ZH, A4, P8, ZH
  madd56lu ZL, A5, P7, ZL
  madd56hu ZH, A5, P7, ZH
  madd56lu ZL, A6, P6, ZL
  madd56hu ZH, A6, P6, ZH
  madd56lu ZL, A7, P5, ZL
  madd56hu ZH, A7, P5, ZH
  madd56lu ZL, A8, P4, ZL
  madd56hu ZH, A8, P4, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 16(a0)
.endm

.macro COMPUTE_R3
  ld       ZL,112(a1)
  madd56lu ZH, A5, P8, ZH
  madd56hu ZL, A5, P8, ZL
  madd56lu ZH, A6, P7, ZH
  madd56hu ZL, A6, P7, ZL
  madd56lu ZH, A7, P6, ZH
  madd56hu ZL, A7, P6, ZL
  madd56lu ZH, A8, P5, ZH
  madd56hu ZL, A8, P5, ZL
  madd56lu ZH, A9, P4, ZH
  madd56hu ZL, A9, P4, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH, 24(a0)
.endm

.macro COMPUTE_R4
  ld       ZH,120(a1)
  madd56lu ZL, A6, P8, ZL
  madd56hu ZH, A6, P8, ZH
  madd56lu ZL, A7, P7, ZL
  madd56hu ZH, A7, P7, ZH
  madd56lu ZL, A8, P6, ZL
  madd56hu ZH, A8, P6, ZH
  madd56lu ZL, A9, P5, ZL
  madd56hu ZH, A9, P5, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 32(a0)
.endm

.macro COMPUTE_R5
  ld       ZL,128(a1)
  madd56lu ZH, A7, P8, ZH
  madd56hu ZL, A7, P8, ZL
  madd56lu ZH, A8, P7, ZH
  madd56hu ZL, A8, P7, ZL
  madd56lu ZH, A9, P6, ZH
  madd56hu ZL, A9, P6, ZL
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH, 40(a0)
.endm

.macro COMPUTE_R6
  ld       ZH,136(a1)
  madd56lu ZL, A8, P8, ZL
  madd56hu ZH, A8, P8, ZH
  madd56lu ZL, A9, P7, ZL
  madd56hu ZH, A9, P7, ZH
  _PROPAGATE_CARRY ZL, ZH
  sd       ZL, 48(a0)
.endm

.macro COMPUTE_R7
  madd56lu ZH, A9, P8, ZH
  madd56hu ZL, A9, P8, x0
  _PROPAGATE_CARRY ZH, ZL
  sd       ZH, 56(a0)
.endm

.macro COMPUTE_R8
  sd       ZL, 64(a0)
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
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_A8
  COMPUTE_A9
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  EPILOGUE


.section .data 

.balign 8 

P503P1:
.dword 0x11E7A0AC000000                 // P4
.dword 0x7DAF13085BDA22                 // P5
.dword 0xD01B9BF6C87B7E                 // P6
.dword 0x6045C6BDDA77A4                 // P7
.dword 0x4066F541811E1E                 // P8

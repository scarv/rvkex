// void fp_rdc_mont_ise(uint64_t *r, const uint64_t *a);
// radix-2^57, product-scanning


#include "ise2.h"


// registers

// accumulator `z`
#define Z0 t0
#define Z1 t1

// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a2 
#define P5 a3
#define P6 a7
#define P7 a4
#define P8 a5

// operand `a`
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 s6
#define A7 s7
#define A8 s8

// mask `m`
#define M_ a6

// Montgomery reduction constant `w = -p^-1 mod 2^57`
#define W_ t2


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -80
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
  li    M_, 0x1FFFFFFFFFFFFFFULL
  li    W_, 0x0C1301F632E294DULL
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
  addi  sp, sp, 80
  ret 
.endm

// load operand and modulus

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
.endm 

.macro LOAD_P
  la    t0, P512
  ld    P0,  0(t0)
  ld    P1,  8(t0)
  ld    P2, 16(t0)
  ld    P3, 24(t0)
  ld    P4, 32(t0)
  ld    P5, 40(t0)
  ld    P6, 48(t0)
  ld    P7, 56(t0)
  ld    P8, 64(t0)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _PROPAGATE_CARRY A, B 
  # sraiadd  \B, \B, \A, 57
  srli     s9, \A, 57
  add      \B, \B, s9
  and      \A, \A, M_
.endm

.macro COMPUTE_A0
  mv       Z0, A0
  madd57lu A0, Z0, W_, x0
  madd57lu Z0, A0, P0, Z0 
  madd57hu Z1, A0, P0, A1
  _PROPAGATE_CARRY Z0, Z1
  # sraiadd  Z1, Z1, Z0, 57
.endm

.macro COMPUTE_A1 
  madd57lu Z1, A0, P1, Z1
  madd57hu Z0, A0, P1, A2
  madd57lu A1, Z1, W_, x0
  madd57lu Z1, A1, P0, Z1
  madd57hu Z0, A1, P0, Z0
  _PROPAGATE_CARRY Z1, Z0
  # sraiadd  Z0, Z0, Z1, 57
.endm

.macro COMPUTE_A2
  madd57lu Z0, A0, P2, Z0
  madd57hu Z1, A0, P2, A3
  madd57lu Z0, A1, P1, Z0
  madd57hu Z1, A1, P1, Z1
  madd57lu A2, Z0, W_, x0
  madd57lu Z0, A2, P0, Z0
  madd57hu Z1, A2, P0, Z1
  _PROPAGATE_CARRY Z0, Z1
  # sraiadd  Z1, Z1, Z0, 57
.endm

.macro COMPUTE_A3
  madd57lu Z1, A0, P3, Z1
  madd57hu Z0, A0, P3, A4
  madd57lu Z1, A1, P2, Z1
  madd57hu Z0, A1, P2, Z0
  madd57lu Z1, A2, P1, Z1
  madd57hu Z0, A2, P1, Z0
  madd57lu A3, Z1, W_, x0
  madd57lu Z1, A3, P0, Z1
  madd57hu Z0, A3, P0, Z0
  _PROPAGATE_CARRY Z1, Z0
  # sraiadd  Z0, Z0, Z1, 57
.endm

.macro COMPUTE_A4
  madd57lu Z0, A0, P4, Z0
  madd57hu Z1, A0, P4, A5
  madd57lu Z0, A1, P3, Z0
  madd57hu Z1, A1, P3, Z1
  madd57lu Z0, A2, P2, Z0
  madd57hu Z1, A2, P2, Z1
  madd57lu Z0, A3, P1, Z0
  madd57hu Z1, A3, P1, Z1
  madd57lu A4, Z0, W_, x0
  madd57lu Z0, A4, P0, Z0
  madd57hu Z1, A4, P0, Z1
  _PROPAGATE_CARRY Z0, Z1
  # sraiadd  Z1, Z1, Z0, 57
.endm

.macro COMPUTE_A5
  madd57lu Z1, A0, P5, Z1
  madd57hu Z0, A0, P5, A6
  madd57lu Z1, A1, P4, Z1
  madd57hu Z0, A1, P4, Z0
  madd57lu Z1, A2, P3, Z1
  madd57hu Z0, A2, P3, Z0
  madd57lu Z1, A3, P2, Z1
  madd57hu Z0, A3, P2, Z0
  madd57lu Z1, A4, P1, Z1
  madd57hu Z0, A4, P1, Z0
  madd57lu A5, Z1, W_, x0
  madd57lu Z1, A5, P0, Z1
  madd57hu Z0, A5, P0, Z0
  _PROPAGATE_CARRY Z1, Z0
.endm

.macro COMPUTE_A6
  madd57lu Z0, A0, P6, Z0
  madd57hu Z1, A0, P6, A7
  madd57lu Z0, A1, P5, Z0
  madd57hu Z1, A1, P5, Z1
  madd57lu Z0, A2, P4, Z0
  madd57hu Z1, A2, P4, Z1
  madd57lu Z0, A3, P3, Z0
  madd57hu Z1, A3, P3, Z1
  madd57lu Z0, A4, P2, Z0
  madd57hu Z1, A4, P2, Z1
  madd57lu Z0, A5, P1, Z0
  madd57hu Z1, A5, P1, Z1
  madd57lu A6, Z0, W_, x0
  madd57lu Z0, A6, P0, Z0
  madd57hu Z1, A6, P0, Z1
  _PROPAGATE_CARRY Z0, Z1
.endm

.macro COMPUTE_A7
  madd57lu Z1, A0, P7, Z1
  madd57hu Z0, A0, P7, A8
  madd57lu Z1, A1, P6, Z1
  madd57hu Z0, A1, P6, Z0
  madd57lu Z1, A2, P5, Z1
  madd57hu Z0, A2, P5, Z0
  madd57lu Z1, A3, P4, Z1
  madd57hu Z0, A3, P4, Z0
  madd57lu Z1, A4, P3, Z1
  madd57hu Z0, A4, P3, Z0
  madd57lu Z1, A5, P2, Z1
  madd57hu Z0, A5, P2, Z0
  madd57lu Z1, A6, P1, Z1
  madd57hu Z0, A6, P1, Z0
  madd57lu A7, Z1, W_, x0
  madd57lu Z1, A7, P0, Z1
  madd57hu Z0, A7, P0, Z0
  _PROPAGATE_CARRY Z1, Z0
.endm

.macro COMPUTE_A8
  ld       Z1, 72(a1)
  madd57lu Z0, A0, P8, Z0
  madd57hu Z1, A0, P8, Z1
  madd57lu Z0, A1, P7, Z0
  madd57hu Z1, A1, P7, Z1
  madd57lu Z0, A2, P6, Z0
  madd57hu Z1, A2, P6, Z1
  madd57lu Z0, A3, P5, Z0
  madd57hu Z1, A3, P5, Z1
  madd57lu Z0, A4, P4, Z0
  madd57hu Z1, A4, P4, Z1
  madd57lu Z0, A5, P3, Z0
  madd57hu Z1, A5, P3, Z1
  madd57lu Z0, A6, P2, Z0
  madd57hu Z1, A6, P2, Z1
  madd57lu Z0, A7, P1, Z0
  madd57hu Z1, A7, P1, Z1
  madd57lu A8, Z0, W_, x0
  madd57lu Z0, A8, P0, Z0
  madd57hu Z1, A8, P0, Z1
  _PROPAGATE_CARRY Z0, Z1
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld       Z0, 80(a1)
  madd57lu Z1, A1, P8, Z1
  madd57hu Z0, A1, P8, Z0
  madd57lu Z1, A2, P7, Z1
  madd57hu Z0, A2, P7, Z0
  madd57lu Z1, A3, P6, Z1
  madd57hu Z0, A3, P6, Z0
  madd57lu Z1, A4, P5, Z1
  madd57hu Z0, A4, P5, Z0
  madd57lu Z1, A5, P4, Z1
  madd57hu Z0, A5, P4, Z0
  madd57lu Z1, A6, P3, Z1
  madd57hu Z0, A6, P3, Z0
  madd57lu Z1, A7, P2, Z1
  madd57hu Z0, A7, P2, Z0
  madd57lu Z1, A8, P1, Z1
  madd57hu Z0, A8, P1, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1,  0(a0)
.endm

.macro COMPUTE_R1
  ld       Z1, 88(a1)
  madd57lu Z0, A2, P8, Z0
  madd57hu Z1, A2, P8, Z1
  madd57lu Z0, A3, P7, Z0
  madd57hu Z1, A3, P7, Z1
  madd57lu Z0, A4, P6, Z0
  madd57hu Z1, A4, P6, Z1
  madd57lu Z0, A5, P5, Z0
  madd57hu Z1, A5, P5, Z1
  madd57lu Z0, A6, P4, Z0
  madd57hu Z1, A6, P4, Z1
  madd57lu Z0, A7, P3, Z0
  madd57hu Z1, A7, P3, Z1
  madd57lu Z0, A8, P2, Z0
  madd57hu Z1, A8, P2, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0,  8(a0)
.endm

.macro COMPUTE_R2
  ld       Z0, 96(a1)
  madd57lu Z1, A3, P8, Z1
  madd57hu Z0, A3, P8, Z0
  madd57lu Z1, A4, P7, Z1
  madd57hu Z0, A4, P7, Z0
  madd57lu Z1, A5, P6, Z1
  madd57hu Z0, A5, P6, Z0
  madd57lu Z1, A6, P5, Z1
  madd57hu Z0, A6, P5, Z0
  madd57lu Z1, A7, P4, Z1
  madd57hu Z0, A7, P4, Z0
  madd57lu Z1, A8, P3, Z1
  madd57hu Z0, A8, P3, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1, 16(a0)
.endm

.macro COMPUTE_R3
  ld       Z1,104(a1)
  madd57lu Z0, A4, P8, Z0
  madd57hu Z1, A4, P8, Z1
  madd57lu Z0, A5, P7, Z0
  madd57hu Z1, A5, P7, Z1
  madd57lu Z0, A6, P6, Z0
  madd57hu Z1, A6, P6, Z1
  madd57lu Z0, A7, P5, Z0
  madd57hu Z1, A7, P5, Z1
  madd57lu Z0, A8, P4, Z0
  madd57hu Z1, A8, P4, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0, 24(a0)
.endm

.macro COMPUTE_R4
  ld       Z0,112(a1)
  madd57lu Z1, A5, P8, Z1
  madd57hu Z0, A5, P8, Z0
  madd57lu Z1, A6, P7, Z1
  madd57hu Z0, A6, P7, Z0
  madd57lu Z1, A7, P6, Z1
  madd57hu Z0, A7, P6, Z0
  madd57lu Z1, A8, P5, Z1
  madd57hu Z0, A8, P5, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1, 32(a0)
.endm

.macro COMPUTE_R5
  ld       Z1,120(a1)
  madd57lu Z0, A6, P8, Z0
  madd57hu Z1, A6, P8, Z1
  madd57lu Z0, A7, P7, Z0
  madd57hu Z1, A7, P7, Z1
  madd57lu Z0, A8, P6, Z0
  madd57hu Z1, A8, P6, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0, 40(a0)
.endm

.macro COMPUTE_R6
  ld       Z0,128(a1)
  madd57lu Z1, A7, P8, Z1
  madd57hu Z0, A7, P8, Z0
  madd57lu Z1, A8, P7, Z1
  madd57hu Z0, A8, P7, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1, 48(a0)
.endm

.macro COMPUTE_R7
  ld       Z1,136(a1)
  madd57lu Z0, A8, P8, Z0
  madd57hu Z1, A8, P8, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0, 56(a0)
.endm

.macro COMPUTE_R8
  sd       Z1, 64(a0)
.endm


.section .text

.global fp_rdc_mont_ise

fp_rdc_mont_ise:
  PROLOGUE
  LOAD_A
  LOAD_P
  COMPUTE_A0
  COMPUTE_A1
  COMPUTE_A2
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_A8
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

P512: 
.dword 0x181B90533C6C87B                // P0
.dword 0x10DFA2BD6541A8D                // P1
.dword 0x03307C2D3C9709C                // P2
.dword 0x0ACFE6AA0EA2CE6                // P3
.dword 0x1322C9CDA7AAC6C                // P4
.dword 0x0446212D7DFE634                // P5
.dword 0x1312AD0B420EBB7                // P6
.dword 0x17FF91561A2BC7C                // P7
.dword 0x065B48E8F740F89                // P8


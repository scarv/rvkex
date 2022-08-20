// void reduce_once_cs_sw(uint64_t *a)
// radix-2^64
// NOTE that due to the lack of carry flag on RISC-V, the `cswap-based` 
// `reduce_once` is more efficient than `addition-based` version.


// registers 

// result and operand `r`
#define R0 a5
#define R1 a6
#define R2 a7
#define R3 s0
#define R4 s1
#define R5 s2
#define R6 s3
#define R7 s4

// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a1
#define P5 a2
#define P6 a3
#define P7 a4

// temporary value `t`
#define T0 t0
#define T1 t1
#define T2 t2


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

// load modulus + store result

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
.endm

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
  ld    R7, 56(a0)
.endm

.macro STORE_R 
  sd    P0,  0(a0)
  sd    P1,  8(a0)
  sd    P2, 16(a0)
  sd    P3, 24(a0)
  sd    P4, 32(a0)
  sd    P5, 40(a0)
  sd    P6, 48(a0)
  sd    P7, 56(a0)
.endm

// arithmetic computation

.macro _R_SUB_P R, P
  sltu  T1, \R, \P
  sub   \P, \R, \P
  sltu  T2, \P, T0 
  sub   \P, \P, T0
  or    T0, T1, T2
.endm

.macro R_SUB_P 
  sltu  T0, R0, P0 
  sub   P0, R0, P0
  _R_SUB_P  R1, P1
  _R_SUB_P  R2, P2
  _R_SUB_P  R3, P3
  _R_SUB_P  R4, P4
  _R_SUB_P  R5, P5
  _R_SUB_P  R6, P6
  _R_SUB_P  R7, P7
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T0
  xor   \P, \P, \R
.endm

.macro CSWAP 
  sub   T0, x0, T0
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
  _CSWAP    R6, P6
  _CSWAP    R7, P7
.endm


.section .text

.global reduce_once_cs_sw

reduce_once_cs_sw:
  PROLOGUE
  LOAD_P
  LOAD_R
  R_SUB_P
  CSWAP
  STORE_R
  EPILOGUE


.section .data 

.balign 8 

P512: 
.dword 0x1b81b90533c6c87b               // P0
.dword 0xc2721bf457aca835               // P1
.dword 0x516730cc1f0b4f25               // P2
.dword 0xa7aac6c567f35507               // P3
.dword 0x5afbfcc69322c9cd               // P4
.dword 0xb42d083aedc88c42               // P5
.dword 0xfc8ab0d15e3e4c4a               // P6
.dword 0x65b48e8f740f89bf               // P7

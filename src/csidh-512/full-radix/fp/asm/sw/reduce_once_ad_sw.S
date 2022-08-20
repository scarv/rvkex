// void reduce_once_ad_sw(uint64_t *a)
// radix-2^64
// NOTE that due to the lack of carry flag on RISC-V, the `cswap-based` 
// `reduce_once` is more efficient than `addition-based` version.


// registers 

// result and operand `r`
#define R0 a4
#define R1 a5
#define R2 a6
#define R3 a7
#define R4 s0
#define R5 s1
#define R6 s2
#define R7 s3

// modulus `p`
#define P0 t2
#define P1 t3
#define P2 t4
#define P3 t5
#define P4 t6
#define P5 a1
#define P6 a2
#define P7 a3

// temporary value `t`
#define T0 t0
#define T1 t1


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  addi  sp, sp, 32
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

.macro _R_SUB_P R, P
  sltu  T1, \R, T0 
  sub   \R, \R, T0
  sltu  T0, \R, \P
  sub   \R, \R, \P 
  or    T0, T0, T1
.endm

.macro R_SUB_P
  sltu  T0, R0, P0
  sub   R0, R0, P0
  _R_SUB_P  R1, P1
  _R_SUB_P  R2, P2
  _R_SUB_P  R3, P3
  _R_SUB_P  R4, P4
  _R_SUB_P  R5, P5
  _R_SUB_P  R6, P6
  _R_SUB_P  R7, P7
.endm

.macro MASK_P
  sub   T0, x0, T0
  and   P0, P0, T0
  and   P1, P1, T0
  and   P2, P2, T0
  and   P3, P3, T0
  and   P4, P4, T0
  and   P5, P5, T0
  and   P6, P6, T0
  and   P7, P7, T0
.endm

.macro _R_ADD_P R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add  R0, R0, P0
  sltu T0, R0, P0
  _R_ADD_P R1, P1 
  _R_ADD_P R2, P2
  _R_ADD_P R3, P3
  _R_ADD_P R4, P4
  _R_ADD_P R5, P5
  _R_ADD_P R6, P6
  add  R7, R7, T0 
  add  R7, R7, P7
.endm


.section .text

.global reduce_once_ad_sw

reduce_once_ad_sw:
  PROLOGUE
  LOAD_P
  LOAD_R
  R_SUB_P
  MASK_P
  ADD_MASK
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

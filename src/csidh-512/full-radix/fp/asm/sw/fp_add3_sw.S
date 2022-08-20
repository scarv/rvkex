// void fp_add3_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64
// NOTE that due to the lack of carry flag on RISC-V, the `cswap-based` 
// `reduce_once` is more efficient than `addition-based` version.

// registers

// result `r`
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 s3
#define R4 s4
#define R5 s5
#define R6 s6
#define R7 s7 

// operand `a`
#define A_ t0

// operand `b`
#define B_ t1

// modulus `p`
#define P0 t4
#define P1 t5
#define P2 t6
#define P3 a3
#define P4 a4
#define P5 a5
#define P6 a6
#define P7 a7

// temporary value `t`
#define T0 t2
#define T1 t3
#define T2 t0


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -64
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  ld    s7, 56(sp)
  addi  sp, sp, 64
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

.macro _A_ADD_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  add   \R, A_, B_
  sltu  T1, \R, A_
  add   \R, \R, T0
  sltu  T0, \R, T0
  or    T0, T0, T1 
.endm

.macro _A_ADD_B_0
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  add   R0, A_, B_
  sltu  T0, R0, A_
.endm

.macro _A_ADD_B_7
  ld    A_, 56(a1)
  ld    B_, 56(a2)
  add   R7, A_, B_
  add   R7, R7, T0 
.endm

.macro A_ADD_B 
  _A_ADD_B_0
  _A_ADD_B_I R1, 1
  _A_ADD_B_I R2, 2
  _A_ADD_B_I R3, 3
  _A_ADD_B_I R4, 4
  _A_ADD_B_I R5, 5
  _A_ADD_B_I R6, 6
  _A_ADD_B_7
.endm

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

.global fp_add3_sw

fp_add3_sw:
  PROLOGUE
  LOAD_P
  A_ADD_B
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

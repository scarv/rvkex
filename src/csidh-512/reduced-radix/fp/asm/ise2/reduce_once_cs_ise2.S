// void reduce_once_cs_ise2(uint64_t *a)
// radix-2^57


#include "ise2.h"


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
#define R8 t1

// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a1
#define P5 a2
#define P6 a3
#define P7 a4
#define P8 t2

// temporary value `t`
#define T_ t0

// mask `m`
#define M_ s5


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  li    M_, 0x1FFFFFFFFFFFFFFULL
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  addi  sp, sp, 48
  ret 
.endm


// load operand/modulus + store result

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

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
  ld    R7, 56(a0)
  ld    R8, 64(a0)
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
  sd    P8, 64(a0)
.endm

// arithmetic computation

.macro R_SUB_P
  sub   P0, R0, P0
  sub   P1, R1, P1
  sub   P2, R2, P2
  sub   P3, R3, P3
  sub   P4, R4, P4
  sub   P5, R5, P5
  sub   P6, R6, P6
  sub   P7, R7, P7
  sub   P8, R8, P8
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T_
  xor   \P, \P, \R
.endm

.macro CSWAP 
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
  _CSWAP    R6, P6
  _CSWAP    R7, P7
  _CSWAP    R8, P8
.endm

// carry propagation

.macro GET_SIGN 
  sraiadd P1, P1, P0, 57
  and     P0, P0, M_
  sraiadd P2, P2, P1, 57
  and     P1, P1, M_
  sraiadd P3, P3, P2, 57
  and     P2, P2, M_
  sraiadd P4, P4, P3, 57
  and     P3, P3, M_
  sraiadd P5, P5, P4, 57
  and     P4, P4, M_
  sraiadd P6, P6, P5, 57
  and     P5, P5, M_
  sraiadd P7, P7, P6, 57
  and     P6, P6, M_
  sraiadd P8, P8, P7, 57
  and     P7, P7, M_
  srai    T_, P8, 63
.endm


.section .text

.global reduce_once_cs_ise2

reduce_once_cs_ise2:
  PROLOGUE
  LOAD_P
  LOAD_R
  R_SUB_P
  GET_SIGN
  CSWAP
  STORE_R
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

// void fp_add3_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^57


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

// operand `a`
#define A_ t3

// operand `b`
#define B_ t4

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
  ld    P8, 64(t0)
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
  sd    R8, 64(a0)
.endm

// arithmetic computation

.macro _A_ADD_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  add   \R, A_, B_
.endm

.macro A_ADD_B 
  _A_ADD_B_I R0, 0
  _A_ADD_B_I R1, 1
  _A_ADD_B_I R2, 2
  _A_ADD_B_I R3, 3
  _A_ADD_B_I R4, 4
  _A_ADD_B_I R5, 5
  _A_ADD_B_I R6, 6
  _A_ADD_B_I R7, 7
  _A_ADD_B_I R8, 8
.endm

.macro R_SUB_P
  sub   R0, R0, P0
  sub   R1, R1, P1
  sub   R2, R2, P2
  sub   R3, R3, P3
  sub   R4, R4, P4
  sub   R5, R5, P5
  sub   R6, R6, P6
  sub   R7, R7, P7
  sub   R8, R8, P8
.endm

.macro MASK_P
  and   P0, P0, T_
  and   P1, P1, T_
  and   P2, P2, T_
  and   P3, P3, T_
  and   P4, P4, T_
  and   P5, P5, T_
  and   P6, P6, T_
  and   P7, P7, T_
  and   P8, P8, T_
.endm

.macro ADD_MASK 
  add   R0, R0, P0
  add   R1, R1, P1
  add   R2, R2, P2
  add   R3, R3, P3
  add   R4, R4, P4
  add   R5, R5, P5
  add   R6, R6, P6
  add   R7, R7, P7
  add   R8, R8, P8
.endm

// carry propagation

.macro GET_SIGN 
  srai  T_, R0, 57
  add   T_, T_, R1
  srai  T_, T_, 57
  add   T_, T_, R2
  srai  T_, T_, 57
  add   T_, T_, R3
  srai  T_, T_, 57
  add   T_, T_, R4
  srai  T_, T_, 57
  add   T_, T_, R5
  srai  T_, T_, 57
  add   T_, T_, R6
  srai  T_, T_, 57
  add   T_, T_, R7
  srai  T_, T_, 57
  add   T_, T_, R8
  srai  T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  srai  T_, \A, 57
  add   \B, \B, T_
  and   \A, \A, M_
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
  _PROPAGATE_CARRY R6, R7
  _PROPAGATE_CARRY R7, R8
.endm


.section .text

.global fp_add3_sw

fp_add3_sw:
  PROLOGUE
  A_ADD_B
  LOAD_P
  R_SUB_P
  GET_SIGN
  MASK_P
  ADD_MASK
  CARRY_PROPAGATION
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

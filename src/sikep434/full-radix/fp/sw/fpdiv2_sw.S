// void fpdiv2_v0_sw(uint64_t *r, const uint64_t *a);
// radix-2^64


// registers 

#define R0 t0
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
#define R6 t6

// operand "a"
#define A_ a3

// modulus "p"
#define P_ a4

// temp "t"
#define T0 a5
#define T1 a6

// mask "m"
#define M_ a7


// prologue + epilogue 

.macro PROLOGUE
  la    a2, P434
.endm

.macro EPILOGUE
  ret 
.endm

// store result

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
.endm

// arithmetic computation

.macro GET_MASK 
  ld    A_,  0(a1)
  andi  M_, A_,  1
  sub   M_, x0, M_  
.endm

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    P_, 8*\imm(a2)
  and   P_, P_, M_
  add   \R, A_, P_
  sltu  T1, \R, P_
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  or    T0, T1, T0 
.endm

.macro ADD_MASKEDP 
  ld    P_,  0(a2)
  and   P_, P_, M_
  add   R0, A_, P_
  sltu  T0, R0, P_
  _COMPUTE_R R1, 1
  _COMPUTE_R R2, 2
  _COMPUTE_R R3, 3
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  ld    A_, 48(a1)
  ld    P_, 48(a2)
  and   P_, P_, M_
  add   R6, A_, P_
  add   R6, R6, T0
.endm

.macro _RIGHT_SHIFT A, B
  andi   T0, \B,  1
  slli   T0, T0, 63
  srli   \A, \A,  1
  xor    \A, \A, T0
.endm

.macro RIGHT_SHITF 
  _RIGHT_SHIFT R0, R1
  _RIGHT_SHIFT R1, R2
  _RIGHT_SHIFT R2, R3
  _RIGHT_SHIFT R3, R4
  _RIGHT_SHIFT R4, R5
  _RIGHT_SHIFT R5, R6
  srli   R6, R6,  1
.endm


// field division by 2

.section .text

.global fpdiv2_v0_sw

fpdiv2_v0_sw:
  PROLOGUE
  GET_MASK
  ADD_MASKEDP
  RIGHT_SHITF
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P434:
.dword  0xFFFFFFFFFFFFFFFF              // P0
.dword  0xFFFFFFFFFFFFFFFF              // P1
.dword  0xFFFFFFFFFFFFFFFF              // P2
.dword  0xFDC1767AE2FFFFFF              // P3
.dword  0x7BC65C783158AEA3              // P4
.dword  0x6CFC5FD681C52056              // P5
.dword  0x0002341F27177344              // P6

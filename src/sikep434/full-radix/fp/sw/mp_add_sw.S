// void mp_add_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers 

// result "r"
#define R0 t0
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
#define R6 t6

// operand "a"
#define A_ a3

// operand "b"
#define B_ a4

// temp "t"
#define T0 a5
#define T1 a6


// prologue + epilogue 

.macro PROLOGUE
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

.macro _AI_ADD_BI R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  add   \R, A_, B_
  sltu  T1, \R, A_
  add   \R, \R, T0
  sltu  T0, \R, T0
  or    T0, T0, T1
.endm 

.macro _A0_ADD_B0 
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  add   R0, A_, B_
  sltu  T0, R0, A_
.endm

.macro _A6_ADD_B6 
  ld    A_, 48(a1)
  ld    B_, 48(a2)
  add   R6, A_, B_
  add   R6, R6, T0 
.endm 

.macro A_ADD_B 
  _A0_ADD_B0
  _AI_ADD_BI R1, 1
  _AI_ADD_BI R2, 2
  _AI_ADD_BI R3, 3
  _AI_ADD_BI R4, 4
  _AI_ADD_BI R5, 5
  _A6_ADD_B6
.endm


// integer addition

.section .text

.global mp_add_v0_sw

mp_add_v0_sw:
  PROLOGUE
  A_ADD_B
  STORE_R
  EPILOGUE

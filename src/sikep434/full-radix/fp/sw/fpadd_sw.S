// void fpadd_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers

// result "r"
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 a7
#define R4 t4
#define R5 t5
#define R6 t6

// operand "a"
#define A_ t0

// operand "b"
#define B_ t1

// modulus "2p"
#define P0 t1
#define P1 a1
#define P2 a2
#define P3 a3
#define P4 a4
#define P5 a5
#define P6 a6

// temp "t"
#define T0 t2
#define T1 t3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -24
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  addi  sp, sp, 24 
  ret 
.endm

// load operand + store result

.macro LOAD_P
  la    t0, P434X2
  ld    P0,  0(t0)
  ld    P1,  8(t0)
  ld    P2, 16(t0)
  ld    P3, 24(t0)
  ld    P4, 32(t0)
  ld    P5, 40(t0)
  ld    P6, 48(t0)
.endm

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

.macro _RI_SUB_PI R, P
  sltu  T1, \R, T0
  sub   \R, \R, T0
  sltu  T0, \R, \P 
  sub   \R, \R, \P 
  or    T0, T0, T1
.endm

.macro R_SUB_P 
  sltu  T0, R0, P0
  sub   R0, R0, P0
  _RI_SUB_PI    R1, P1
  _RI_SUB_PI    R2, P2
  _RI_SUB_PI    R3, P3
  _RI_SUB_PI    R4, P4
  _RI_SUB_PI    R5, P5 
  _RI_SUB_PI    R6, P6
.endm

.macro MASK_2P
  sub   T0, x0, T0
  and   P0, P0, T0
  and   P1, P1, T0
  and   P2, P2, T0
  and   P3, P3, T0
  and   P4, P4, T0
  and   P5, P5, T0
  and   P6, P6, T0
.endm

.macro _RI_ADD_PJ R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add  R0, R0, P0
  sltu T0, R0, P0
  _RI_ADD_PJ   R1, P1 
  _RI_ADD_PJ   R2, P2
  _RI_ADD_PJ   R3, P3
  _RI_ADD_PJ   R4, P4
  _RI_ADD_PJ   R5, P5
  add  R6, R6, T0 
  add  R6, R6, P6
.endm


// field addition

.section .text

.global fpadd_v0_sw

fpadd_v0_sw:
  PROLOGUE
  A_ADD_B
  LOAD_P
  R_SUB_P
  MASK_2P
  ADD_MASK
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P434X2:
.dword  0xFFFFFFFFFFFFFFFE              // P0
.dword  0xFFFFFFFFFFFFFFFF              // P1
.dword  0xFFFFFFFFFFFFFFFF              // P2
.dword  0xFB82ECF5C5FFFFFF              // P3
.dword  0xF78CB8F062B15D47              // P4
.dword  0xD9F8BFAD038A40AC              // P5
.dword  0x0004683E4E2EE688              // P6

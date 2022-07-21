// void mp_sub_p2_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_sub_p4_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void fpneg_v0_sw(uint64_t *r);
// void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
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
#define A_ a4

// operand "b"
#define B_ a5

// modulus "2p" or "4p"
#define P_ a5

// temp "t"
#define T0 a6
#define T1 a7


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

.macro _AI_ADD_PI R, imm
  ld    A_, 8*\imm(a1)
  ld    P_, 8*\imm(a3)
  add   \R, A_, P_
  sltu  T1, \R, A_
  add   \R, \R, T0
  sltu  T0, \R, T0
  or    T0, T0, T1
.endm

.macro _A0_ADD_P0
  ld    A_,  0(a1)
  ld    P_,  0(a3)
  add   R0, A_, P_
  sltu  T0, R0, A_
.endm 

.macro _A6_ADD_P6
  ld    A_, 48(a1)
  ld    P_, 48(a3)
  add   R6, A_, P_
  add   R6, R6, T0 
.endm

.macro A_ADD_P 
  _A0_ADD_P0 
  _AI_ADD_PI R1, 1
  _AI_ADD_PI R2, 2
  _AI_ADD_PI R3, 3
  _AI_ADD_PI R4, 4
  _AI_ADD_PI R5, 5
  _A6_ADD_P6
.endm

.macro _RI_SUB_BI R, imm
  ld    B_, 8*\imm(a2)
  sltu  T1, \R, T0
  sub   \R, \R, T0
  sltu  T0, \R, B_ 
  sub   \R, \R, B_ 
  or    T0, T0, T1
.endm

.macro _R0_SUB_B0 
  ld    B_,  0(a2)
  sltu  T0, R0, B_
  sub   R0, R0, B_
.endm

.macro _R6_SUB_B6
  ld    B_, 48(a2)
  sub   R6, R6, T0
  sub   R6, R6, B_
.endm

.macro R_SUB_B
  _R0_SUB_B0 
  _RI_SUB_BI R1, 1
  _RI_SUB_BI R2, 2
  _RI_SUB_BI R3, 3
  _RI_SUB_BI R4, 4
  _RI_SUB_BI R5, 5
  _R6_SUB_B6
.endm

// integer subtraction 

.section .text

.global mp_sub_p2_v0_sw

mp_sub_p2_v0_sw:
  PROLOGUE
  la a3, P434X2
  A_ADD_P
  R_SUB_B
  STORE_R
  EPILOGUE


.global mp_sub_p4_v0_sw

mp_sub_p4_v0_sw:
  PROLOGUE
  la a3, P434X4
  A_ADD_P
  R_SUB_B
  STORE_R
  EPILOGUE


.global mp_dblsub_v0_sw

mp_dblsub_v0_sw:
  ld   t0,   0(a0)
  ld   t1,   0(a1)
  ld   t2,   0(a2)
  sltu T0, t0, t1 
  sub  t0, t0, t1 
  sltu T1, t0, t2 
  sub  t0, t0, t2 
  add  T0, T0, T1
  sd   t0,   0(a0)
  .set imm, 8
  .rept 12
  ld   t0, imm(a0)
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  sltu T1, t0, T0 
  sub  t0, t0, T0 
  sltu T0, t0, t1
  sub  t0, t0, t1 
  add  T0, T0, T1 
  sltu T1, t0, t2 
  sub  t0, t0, t2 
  add  T0, T0, T1
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ld   t0, 104(a0)
  ld   t1, 104(a1)
  ld   t2, 104(a2)
  sub  t0, t0, T0 
  sub  t0, t0, t1 
  sub  t0, t0, t2
  sd   t0, 104(a0)
  ret 
  

// field negation

.macro _PI_SUB_AI R, imm 
  ld    A_, 8*\imm(a0)
  ld    P_, 8*\imm(a3)
  sltu  T1, P_, T0
  sub   \R, P_, T0
  sltu  T0, \R, A_ 
  sub   \R, \R, A_ 
  or    T0, T0, T1
.endm

.macro _P0_SUB_A0
  ld    A_,  0(a0)
  ld    P_,  0(a3)
  sltu  T0, P_, A_ 
  sub   R0, P_, A_
.endm

.macro _P6_SUB_A6
  ld    A_, 48(a0)
  ld    P_, 48(a3)
  sub   R6, P_, A_
  sub   R6, R6, T0
.endm

.macro P_SUB_A
  _P0_SUB_A0
  _PI_SUB_AI R1, 1
  _PI_SUB_AI R2, 2
  _PI_SUB_AI R3, 3
  _PI_SUB_AI R4, 4
  _PI_SUB_AI R5, 5
  _P6_SUB_A6
.endm


.global fpneg_v0_sw

fpneg_v0_sw:
  PROLOGUE
  la a3, P434X2
  P_SUB_A
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

P434X4:
.dword  0xFFFFFFFFFFFFFFFC              // P0
.dword  0xFFFFFFFFFFFFFFFF              // P1
.dword  0xFFFFFFFFFFFFFFFF              // P2
.dword  0xF705D9EB8BFFFFFF              // P3
.dword  0xEF1971E0C562BA8F              // P4
.dword  0xB3F17F5A07148159              // P5
.dword  0x0008D07C9C5DCD11              // P6

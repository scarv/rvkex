// void mp_sub_p2_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_sub_p2_v1_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_sub_p4_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void fpneg_v0_sw(uint64_t *r);
// void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56


// registers

// result "r"
#define R0 t0
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
#define R6 t6
#define R7 a7

// operand "a"
#define A_ a4

// operand "b"
#define B_ a5

// modulus "2p" or "4p"
#define P_ a6

// constants and masks
#define M0 a4


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
  sd    R7, 56(a0)
.endm

// arithmetic computation

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  ld    P_, 8*\imm(a3)
  add   \R, A_, P_
  sub   \R, \R, B_
.endm

.macro COMPUTE_R 
  _COMPUTE_R R0, 0
  _COMPUTE_R R1, 1
  _COMPUTE_R R2, 2
  _COMPUTE_R R3, 3
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
.endm

// carry propagation

.macro _PROPAGATE_CARRY A, B 
  srai  P_, \A, 56
  add   \B, \B, P_
  and   \A, \A, M0
.endm

.macro CARRY_PROPAGATION
  li    M0, 0xFFFFFFFFFFFFFFULL 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
  _PROPAGATE_CARRY R6, R7
.endm


// integer subtraction

.section .text

// v0: conventional one

.global mp_sub_p2_v0_sw

mp_sub_p2_v0_sw:
  PROLOGUE
  la a3, P434X2
  COMPUTE_R
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.global mp_sub_p4_v0_sw

mp_sub_p4_v0_sw:
  PROLOGUE
  la a3, P434X4
  COMPUTE_R
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


// v1: no carry propagation

.macro _COMPUTE_R_ R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  add   \R, A_, a7
  sub   \R, \R, B_
.endm 

.macro _COMPUTE_RT R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  ld    P_, 8*\imm-24(a3)
  add   \R, A_, a7
  add   \R, \R, P_
  sub   \R, \R, B_
.endm 

.global mp_sub_p2_v1_sw

mp_sub_p2_v1_sw:
  PROLOGUE
  la a3, P434X2T
  li a7, 0x1FFFFFFFFFFFFFEULL
  _COMPUTE_R_ R0, 0
  _COMPUTE_R_ R1, 1
  _COMPUTE_R_ R2, 2
  _COMPUTE_RT R3, 3
  _COMPUTE_RT R4, 4
  _COMPUTE_RT R5, 5
  _COMPUTE_RT R6, 6
  li a7, 0x3FFFFFFFFFEULL 
  _COMPUTE_RT R7, 7
  STORE_R
  EPILOGUE


// field negation

.macro _SUBTRACT R, imm
  ld    A_, 8*\imm(a0)
  ld    P_, 8*\imm(a3)
  sub   \R, P_, A_
.endm

.macro SUBTRACTION
  _SUBTRACT R0, 0
  _SUBTRACT R1, 1
  _SUBTRACT R2, 2
  _SUBTRACT R3, 3
  _SUBTRACT R4, 4
  _SUBTRACT R5, 5
  _SUBTRACT R6, 6
  _SUBTRACT R7, 7
.endm

.global fpneg_v0_sw

fpneg_v0_sw:
  PROLOGUE
  la a3, P434X2
  SUBTRACTION
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


// integer double subtraction

.global mp_dblsub_v0_sw

mp_dblsub_v0_sw:
  .set imm, 0
  .rept 16
  ld   t0, imm(a0)
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  sub  t0, t0, t1
  sub  t0, t0, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret


.section .data 
.balign 8

P434X2:
.dword 0xFFFFFFFFFFFFFE                 // P0
.dword 0xFFFFFFFFFFFFFF                 // P1
.dword 0xFFFFFFFFFFFFFF                 // P2
.dword 0xC5FFFFFFFFFFFF                 // P3
.dword 0xB15D47FB82ECF5                 // P4
.dword 0x40ACF78CB8F062                 // P5
.dword 0x88D9F8BFAD038A                 // P6
.dword 0x0004683E4E2EE6                 // P7

P434X4:
.dword 0xFFFFFFFFFFFFFC                 // P0
.dword 0xFFFFFFFFFFFFFF                 // P1
.dword 0xFFFFFFFFFFFFFF                 // P2
.dword 0x8BFFFFFFFFFFFF                 // P3
.dword 0x62BA8FF705D9EB                 // P4
.dword 0x8159EF1971E0C5                 // P5
.dword 0x11B3F17F5A0714                 // P6
.dword 0x0008D07C9C5DCD                 // P7

// T = 2*(P434 - (2^433-1))
P434X2T:
.dword 0xC6000000000000                 // T3
.dword 0xB15D47FB82ECF5                 // T4
.dword 0x40ACF78CB8F062                 // T5
.dword 0x88D9F8BFAD038A                 // T6
.dword 0x0000683E4E2EE6                 // T7

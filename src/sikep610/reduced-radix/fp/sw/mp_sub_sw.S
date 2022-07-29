// void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56


// integer double subtraction

.global mp_dblsub_v0_sw

mp_dblsub_v0_sw:
  .set imm, 0
  .rept 22
  ld   t0, imm(a0)
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  sub  t0, t0, t1
  sub  t0, t0, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret

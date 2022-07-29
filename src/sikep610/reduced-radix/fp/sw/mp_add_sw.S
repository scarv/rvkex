// void mp_add_v1_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction, (no carry propagation)


// integer addition

.global mp_add_v1_sw

// v1: no carry propagation 

mp_add_v1_sw:
  .set imm, 0
  .rept 11
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  add  t0, t1, t2
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret

## Notation 

- `EXTS`: sign-extended

## Options

| Mnemonic            | Type                         | Meaning                                                          |
| :------------------ | :--------------------------- | :----------------------------------------------------------------|
| `X25519_TYPE1`      | pure-software, radix-$2^{51}$  | select RISC-V base ISA:          option 1, per description below |
| `X25519_TYPE2`      | ISE-assisted, radix-$2^{51}$   | select RISC-V base ISA plus ISE: option 2, per description below |
| `SIKE_TYPE1`        | pure-software, radix-$2^{56}$  | select RISC-V base ISA:          option 1, per description below |
| `SIKE_TYPE2`        | ISE-assisted, radix-$2^{56}$   | select RISC-V base ISA plus ISE: option 3, per description below |

## Details 

- `X25519_TYPE1` and `SIKE_TYPE1`: base ISA. 

- `X25519_TYPE2`: base ISA plus ISE. 

```
  sraadd   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- x + EXTS(y >> imm)
    GPR[rd] <- r
  }

  macc51lo rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 51) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  macc51hi rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 51) & m) + z 
    GPR[rd] <- r
  }
```

- `SIKE_TYPE2`: base ISA plus ISE. 

```
  sraadd   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- x + EXTS(y >> imm)
    GPR[rd] <- r
  }

  macc56lo rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 56) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  macc56hi rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 56) & m) + z 
    GPR[rd] <- r
  }
```

## Discussion

- It seems `redeced-radix` is more efficient than `full-radix` on RISC-V, because there is no carry flag. But this needs implementations and experiments to verify.

- Design integer `multiply-add` instructions for `reduced-radix`:
  - integer `multiply-add` should take the offset into account. 
  - therefore, the functionality is similar to AVX-512IFMA but should keep the multiplier to be full 64-bit to solve **the saturating issue** (see details in Sect 3.1 in [1]).
  - therefore, the instruction generating higher half should return more bits.

- RISC-V floating-point `multiply-add` instructions are the exception (using R4-type format) in terms of Requirement 2 (i.e., at most 2 source register addresses and 1 destination register address). See details about the floating-point multiply-add instructions `F[N]MADD/F[N]MSUB` on page 69 of [2]. We therefore also design our integer `multiply-add` in a similar manner (i.e., R4-type).

- Since it claimed that SIKE is "happy hybrids" [3], it would be interesting to see: whether SIKE is indeed "happy hybrids" **from an ISE point of view**?

## Ideas for more custom instructions 

- subtruction with hardcoded modulus `p` or `2p`

- squaring 

## References 

[1] H. Cheng, G. Fotiadis, J. Großschädl, and P. Y. A. Ryan. *Highly Vectorized SIKE for AVX-512*, in TCHES'2022. 

[2] https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf.

[3] C. Costello. *The Case for SIKE: A Decade of the Supersingular Isogeny Problem*, https://eprint.iacr.org/2021/543.pdf.

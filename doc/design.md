## Notation 

- `EXTS`: sign-extended

## Options

| Mnemonic            | Type                         | Meaning                                                          |
| :------------------ | :--------------------------- | :----------------------------------------------------------------|
| `RV64_RDCD_TYPE1`   | pure-software, reduced-radix | RISC-V base ISA                                                  |
| `RV64_RDCD_TYPE2`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-use ISE                                |
| `RV64_RDCD_TYPE3`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-use ISE + specific-use ISE             |
| `RV64_FULL_TYPE1`   | pure-software, full-radix    | RISC-V base ISA                                                  |
| `RV64_FULL_TYPE2`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-use ISE                                |
| `RV64_FULL_TYPE3`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-use ISE + specific-use ISE             |

## Details 

- `RV64_RDCD_TYPE1` and `RV64_FULL_TYPE1`: base ISA. 

- `RV64_RDCD_TYPE2`: RISC-V base ISA + general-use ISE shown below. 

```
  sraiadd  rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- x + EXTS(y >> imm)
    GPR[rd] <- r
  }

  madd51lu rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 51) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  madd51hu rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 51) & m) + z 
    GPR[rd] <- r
  }

  madd57lu rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 57) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  madd57hu rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 57) & m) + z 
    GPR[rd] <- r
  }
```

- `RV64_RDCD_TYPE3`: base ISA + general-use ISE shown above + specific-use ISE shown below. 

```
  csidh.sub.p512.57    rd, rs1,      imm {
    x       <- GPR[rs1]

    if      ( imm == 0 ) {
      r <- x - 0x181B90533C6C87B;
    }
    else if ( imm == 1 ) {
      r <- x - 0x10DFA2BD6541A8D;
    }
    else if ( imm == 2 ) {
      r <- x - 0x03307C2D3C9709C;
    }
    else if ( imm == 3 ) {
      r <- x - 0x0ACFE6AA0EA2CE6;
    }
    else if ( imm == 4 ) {
      r <- x - 0x1322C9CDA7AAC6C;
    }
    else if ( imm == 5 ) {
      r <- x - 0x0446212D7DFE634;
    }
    else if ( imm == 6 ) {
      r <- x - 0x1312AD0B420EBB7;
    }
    else if ( imm == 7 ) {
      r <- x - 0x17FF91561A2BC7C;
    }
    else if ( imm == 8 ) {
      r <- x - 0x065B48E8F740F89;
    }

    GPR[rd] <- r
  }

  csidh.and.p512.add57 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) {
      r <- ( x & 0x181B90533C6C87B ) + y;
    }
    else if ( imm == 1 ) {
      r <- ( x & 0x10DFA2BD6541A8D ) + y;
    }
    else if ( imm == 2 ) {
      r <- ( x & 0x03307C2D3C9709C ) + y;
    }
    else if ( imm == 3 ) {
      r <- ( x & 0x0ACFE6AA0EA2CE6 ) + y;
    }
    else if ( imm == 4 ) {
      r <- ( x & 0x1322C9CDA7AAC6C ) + y;
    }
    else if ( imm == 5 ) {
      r <- ( x & 0x0446212D7DFE634 ) + y;
    }
    else if ( imm == 6 ) {
      r <- ( x & 0x1312AD0B420EBB7 ) + y;
    }
    else if ( imm == 7 ) {
      r <- ( x & 0x17FF91561A2BC7C ) + y;
    }
    else if ( imm == 8 ) {
      r <- ( x & 0x065B48E8F740F89 ) + y;
    }

    GPR[rd] <- r
  }

  csidh.sub.p512.add57 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) {
      r <- x - 0x181B90533C6C87B + y;
    }
    else if ( imm == 1 ) {
      r <- x - 0x10DFA2BD6541A8D + y;
    }
    else if ( imm == 2 ) {
      r <- x - 0x03307C2D3C9709C + y;
    }
    else if ( imm == 3 ) {
      r <- x - 0x0ACFE6AA0EA2CE6 + y;
    }
    else if ( imm == 4 ) {
      r <- x - 0x1322C9CDA7AAC6C + y;
    }
    else if ( imm == 5 ) {
      r <- x - 0x0446212D7DFE634 + y;
    }
    else if ( imm == 6 ) {
      r <- x - 0x1312AD0B420EBB7 + y;
    }
    else if ( imm == 7 ) {
      r <- x - 0x17FF91561A2BC7C + y;
    }
    else if ( imm == 8 ) {
      r <- x - 0x065B48E8F740F89 + y;
    }

    GPR[rd] <- r
  }
```

- `RV64_FULL_TYPE2`: base ISA + general-use ISE shown below. 

```
  maddlu   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- ( (x * y + z)         & m) 
    GPR[rd] <- r
  }

  maddhu   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y  + z) >> 64) & m) 
    GPR[rd] <- r
  }

  cadd     rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    r       <- ((x + y) >> 64) + z
    GPR[rd] <- r
  }  

```

- `RV64_FULL_TYPE3`: base ISA + general-use ISE shown above + specific-use ISE shown below. 

```
  csidh.sub.p512       rd, rs1,      imm {
    x       <- GPR[rs1]

    if      ( imm == 0 ) {
      r <- x - 0x1b81b90533c6c87b;
    }
    else if ( imm == 1 ) {
      r <- x - 0xc2721bf457aca835;
    }
    else if ( imm == 2 ) {
      r <- x - 0x516730cc1f0b4f25;
    }
    else if ( imm == 3 ) {
      r <- x - 0xa7aac6c567f35507;
    }
    else if ( imm == 4 ) {
      r <- x - 0x5afbfcc69322c9cd;
    }
    else if ( imm == 5 ) {
      r <- x - 0xb42d083aedc88c42;
    }
    else if ( imm == 6 ) {
      r <- x - 0xfc8ab0d15e3e4c4a;
    }
    else if ( imm == 7 ) {
      r <- x - 0x65b48e8f740f89bf;
    }

    GPR[rd] <- r
  }

  csidh.and.p512.add   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) {
      r <- ( x & 0x1b81b90533c6c87b ) + y;
    }
    else if ( imm == 1 ) {
      r <- ( x & 0xc2721bf457aca835 ) + y;
    }
    else if ( imm == 2 ) {
      r <- ( x & 0x516730cc1f0b4f25 ) + y;
    }
    else if ( imm == 3 ) {
      r <- ( x & 0xa7aac6c567f35507 ) + y;
    }
    else if ( imm == 4 ) {
      r <- ( x & 0x5afbfcc69322c9cd ) + y;
    }
    else if ( imm == 5 ) {
      r <- ( x & 0xb42d083aedc88c42 ) + y;
    }
    else if ( imm == 6 ) {
      r <- ( x & 0xfc8ab0d15e3e4c4a ) + y;
    }
    else if ( imm == 7 ) {
      r <- ( x & 0x65b48e8f740f89bf ) + y;
    }

    GPR[rd] <- r
  }
```

## Discussion

- Design integer `multiply-add` instructions for `reduced-radix`:
  - integer `multiply-add` should take the offset into account. 
  - therefore, the functionality is similar to AVX-512IFMA but should keep the multiplier to be full 64-bit to solve **the saturating issue** (see details in Sect 3.1 in [1]).
  - therefore, the instruction generating higher half should return more bits.

- RISC-V floating-point `multiply-add` instructions are the exception (using R4-type format) in terms of Requirement 2 (i.e., at most 2 source register addresses and 1 destination register address). See details about the floating-point multiply-add instructions `F[N]MADD/F[N]MSUB` on page 69 of [2]. We therefore also design our integer `multiply-add` in a similar manner (i.e., R4-type).

## Ideas for more custom instructions 

- squaring 

## References 

[1] H. Cheng, G. Fotiadis, J. Großschädl, and P. Y. A. Ryan. *Highly Vectorized SIKE for AVX-512*, in TCHES'2022. 

[2] https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf.

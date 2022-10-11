## Notation 

- `EXTS`: sign-extended

- The 511-bit modulus of CSIDH-512 in the reduced-radix (radix-$2^{57}$) representation:
```
P511R = {
  0x181B90533C6C87B, 0x10DFA2BD6541A8D, 0x03307C2D3C9709C, 
  0x0ACFE6AA0EA2CE6, 0x1322C9CDA7AAC6C, 0x0446212D7DFE634, 
  0x1312AD0B420EBB7, 0x17FF91561A2BC7C, 0x065B48E8F740F89 }
```

## Options

| Mnemonic            | Type                         | Meaning                                                          |
| :------------------ | :--------------------------- | :----------------------------------------------------------------|
| `RV64_RDCD_TYPE1`   | pure-software, reduced-radix | RISC-V base ISA                                                  |
| `RV64_RDCD_TYPE2`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-purpose ISE                            |
| `RV64_RDCD_TYPE3`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-purpose ISE + special-purpose ISE     |

## Details 

- `RV64_RDCD_TYPE1`: base ISA. 

- `RV64_RDCD_TYPE2`: RISC-V base ISA + general-purpose ISE shown below. 

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

- `RV64_RDCD_TYPE3`: base ISA + general-purpose ISE shown above + special-purpose ISE shown below. 

```
  csidh.sub.p512.57    rd, rs1,      imm {
    x       <- GPR[rs1]
    r       <- x - P511R[imm]
    GPR[rd] <- r
  }

  csidh.and.p512.add57 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- (x & P511R[imm]) + y
    GPR[rd] <- r
  }

  csidh.sub.p512.add57 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- x - P511R[imm] + y
    GPR[rd] <- r
  }
```

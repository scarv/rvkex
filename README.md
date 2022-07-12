# RVKEX: ECC/isogeny-based key exchange on 64-bit RISC-V 

## Overview

- We consider the RISC-V baseline ISA as being `rv64gc` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)

  are available by default.

## Implementations 

- We plan to develop 4 types of implementation for each of pre-quantum X25519 [1] and post-quantum SIKE [2]:
  - full-radix    pure-software  
  - full-radix    ISE-assisted
  - reduced-radix pure-software
  - reduced-radix ISE-assisted 

  Furthermore, we plan to design several different ISEs and then discuss different trade-offs. 

- Since SIKE is relatively costly (compared to other PQC KEMs), it makes more sense to target more computing-powerful `rv64` instead of `rv32` in this project. Some details and arguments about the performance of SIKE can be found on page 36 of [3]. 

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── sike                  - sike implementations
│   │   └── sikep434              - sikep434 implementation
│   │       ├── reduced-radix         - radix-2^56 implementation           
│   │       └── full-radix            - radix-2^64 implementation 
│   └────── x25519                - x25519 implementations
│           ├── reduced-radix         - radix-2^51 implementation           
│           └── full-radix            - radix-2^64 implementation
├── toolchain                 - scripts to install RISC-V toolchains 
└── work                      - working directory for build    
```

## Usage 

- Fix paths for the RISCV toolchains, e.g., 

  ```sh
  export RISCV="/opt/riscv"
  ```
- Clone the repository and setup environment

  ```sh
  git clone https://github.com/scarv/rvkex.git
  cd ./rvkex
  git submodule update --init --recursive
  source bin/conf.sh
  ```

- Build the toolchain
  ```sh
  make -f toolchain/Makefile clone
  make -f toolchain/Makefile apply 
  make -f toolchain/Makefile build
  ```

- Build and evaluate the (different) implementation (`f` means full-radix; `r` means reduced-radix)

  ```sh
  make x25519_f
  make x25519_r
  make sikep434_f
  make sikep434_r
  ```

## References and links

[1] D. J. Bernstein. *Curve25519: new Diffie-Hellman speed records*, in PKC'2006.

[2] https://sike.org/files/SIDH-spec.pdf

[3] https://nvlpubs.nist.gov/nistpubs/ir/2022/NIST.IR.8413.pdf
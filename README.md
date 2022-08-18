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

- We plan to develop 4 types of implementation for each of pre-quantum X25519 [1] and post-quantum CSIDH-512 [2]:
  - [x] full-radix    pure-software  x25519
  - [x] full-radix    ISE-assisted   x25519
  - [x] reduced-radix pure-software  x25519
  - [x] reduced-radix ISE-assisted   x25519
  - [ ] full-radix    pure-software  csidh-512
  - [ ] full-radix    ISE-assisted   csidh-512
  - [ ] reduced-radix pure-software  csidh-512
  - [ ] reduced-radix ISE-assisted   csidh-512

  Furthermore, we plan to design general-use ISE (for big number arithmetic) and specific-use ISE (for CSIDH-512) then discuss different trade-offs. 

- Since CSIDH is relatively costly (compared to other PQC KEMs), it makes more sense to target more computing-powerful `rv64` instead of `rv32` in this project. 

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── hw                    - hardware part
│   ├── csidh-512             - csidh-512 implementations
│   │   ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│   │   └── reduced-radix         - radix-2^56 (pure-sw + ise-assisted)
│   └── x25519                - x25519 implementations
│       ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│       └── reduced-radix         - radix-2^51 (pure-sw + ise-assisted)
├── hw-toolchain              - scripts to install RISC-V hardware toolchains 
├── sw-toolchain              - scripts to install RISC-V software toolchains 
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

- Build the software toolchain
  ```sh
  make sw-toolchain-build  
  ```

- Build and evaluate the (different) software 
  ```sh
  make sw-run ALG=[x25519/csidh-512] RADIX=[full/reduced] TYPE=RV64_TYPE[1/2/3]
  ```
  - `RV64_TYPE1`: pure-software implementation; 
  - `RV64_TYPE2`: ISE-assisted implementation using general-use ISE; 
  - `RV64_TYPE3`: ISE-assisted implementation using general-use ISE *plus* specific-use ISE.

- Enable the debug mode (add `MODE=debug`), e.g.,
  ```sh
  make sw-run ALG=x25519 RADIX=reduced TYPE=RV64_TYPE2 MODE=debug 
  ```

## TODO 

- remove the final subtraction in fp mul 

## References and links

[1] https://cr.yp.to/ecdh.html

[2] https://csidh.isogeny.org


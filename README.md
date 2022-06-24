# RVKEX: scalar and vectorized pre-, post-quantum, and hybrid key exchange on 64-bit RISC-V 

## Overview 

- We consider the RISC-V baseline ISA as being `rv64gcv` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)
  - **V    (vector)**

  are available by default.

- The project `rvkex` primarily targets `V` vector extension which is the standard vector extension for **application processor profiles** (see [1] for details), i.e., `Zvl128b` with a max `EEW = 64`, based on the following consideration (also partly explains why we target `rv64` not `rv32`): 
  - most of the on-market risc-v vector cores are designed for the application processors instead of embedded devices, and they are exactly `rv64gcv` cores; for example, SiFive P270 [2] and X280 [3], Alibaba XT910 [4].

- Another reason why we target `rv64` not `rv32`: 
  - `V` extension has a max `EEW = 64`, i.e., the element width in a vector is up to 64 bits. Using `rv64` is able to have a **relatively fair** comparison between risc-v scalar (RVS) implementation and risc-v vector(ized) (RVV) implementation.

- However, the project `rvkex` also discusses, to a certain extent, the efficient software for `zve64*` (i.e., a standard vector extension for **embedded use**, see [5] for details), where the `vmulh` integer multiply variants **are not included** for `EEW=64`.

- `rvkex` considers `128b` (and maybe also `256b`) vector length, since most of the on-market vector cores use `128b` ALU (e.g., SiFive P270 and Alibaba XT910) or `256b` ALU (SiFive X280).

## Implementations 

- We plan to develop 4 types of implementation for pre-quantum X25519 [6] and post-quantum SIKE [7]:
  - scalar pure-software 
  - scalar ISE-supported 
  - vector pure-software
  - vector ISE-supported 


## Organization

```
├── bin                 - scripts (e.g., environment configuration)
├── doc                 - documentation (e.g., encoding and design)
├── src                 - source code
│   ├── sike            - sike implementations 
│   │   ├── scalar          - scalar sike   implementation
│   │   └── vector          - vector sike   implementation       
│   └── x25519          - x25519 implementations 
│       ├── scalar          - scalar x25519 implementation
│       └── vector          - vector x25519 implementation  
├── toolchain           - scripts to install RISC-V toolchains 
└── work                - working directory for build
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

- Build and evaluate the (different) implementation

  ```sh
  make scalar_x25519
  make vector_x25519
  make scalar_sike
  make vector_sike
  ```

- Switch different modes in the source code in `src/[x25519/sike]/[scalar/vector]/config.h`
  - enable debug mode `#define DEBUG 1` 
  - use ISE `#define ISE 1` 


## TODO
  - Move the constants and masks for the vector asm functions into the asm files. 


## References and links
[1] https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#v-vector-extension-for-application-processors
[2] https://www.sifive.com/cores/performance-p270
[3] https://www.sifive.com/cores/intelligence-x280 
[4] https://www.cnx-software.com/2020/08/25/more-details-about-alibaba-xt910-64-bit-risc-v-core/
[5] https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#182-zve-vector-extensions-for-embedded-processors
[6] D. J. Bernstein. *Curve25519: new Diffie-Hellman speed records.*, in PKC'2006.
[7] https://sike.org/files/SIDH-spec.pdf
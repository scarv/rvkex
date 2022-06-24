# Notes for crypto primitives RVV implementation

## Parameters in RVV
  - `VLEN`: the length of a single vector register
  - `SEW`: Single Element Width, **max 64-bit** 
  - `EEW`: Effective Element Width, **max 64-bit**; this changes when using widening or narrowing instructions 
  - `LMUL`: vector register group multiplier; **the number of registers** in a register group, **max 8**  
  - `VL`: Vector Length; **the number of elements** in a register group
  - `VLMAX`: `LMUL * VLEN/SEW`; normally `VL = VLMAX`
  - `AVL`: Application Vector Length; **the number of elements** in a register group **in practice**; can set `VL = AVL` with `vsetvli`

## Configuration-setting in RVV
  ```
  vsetvli rd, rs1, SEW, LMUL            ; rd = new VL, rs1 = AVL
  ```
Example for a conventional SIMD:
  ```
  li      rs1, -1                       ; AVL = MAX
  vsetvli rd, rs1, e64, m1              ; VL = VLMAX, SEW = 64, LMUL = 1
  ```

---

## Parallelisms in RVV
There are **two-level parallelisms** provided by RVV, namely 
  - `element-wise`: e.g., a 128-bit vector using 32-bit elements (i.e., SEW = 32-bit), namely 4 parallel elements in a single vector register $\bm{a}$ = {$a_0, a_1, a_2, a_3$}; this is similar to NEON, AVX, and etc. A vector multiplication is shown below:
    $$
    \bm{r}  = \bm{a} \times \bm{b}               
            = < a_0 \times b_0, 
                a_1 \times b_1, 
                a_2 \times b_2, 
                a_3 \times b_3  >
    $$
  - `vector-wise`, aka. `register group`: e.g., a vector register group composed of 4 vector registers $\bm{A}$ = {$\bm{a_0}, \bm{a_1}, \bm{a_2}, \bm{a_3}$}. A vector-register-group multiplication is shown below: 
    $$
    \begin{align*}
    \bm{R}  = & \bm{A} \times \bm{B}              \\ 
            = & \bm{a^{(0)}} \times \bm{b^{(0)}}, 
                \bm{a^{(1)}} \times \bm{b^{(1)}}, 
                \bm{a^{(2)}} \times \bm{b^{(2)}}, 
                \bm{a^{(3)}} \times \bm{b^{(3)}}, \\
            = & < a^{(0)}_0 \times b^{(0)}_0, 
                  a^{(0)}_1 \times b^{(0)}_1, 
                  a^{(0)}_2 \times b^{(0)}_2, 
                  a^{(0)}_3 \times b^{(0)}_3  >,  \\
              & < a^{(1)}_0 \times b^{(1)}_0, 
                  a^{(1)}_1 \times b^{(1)}_1, 
                  a^{(1)}_2 \times b^{(1)}_2, 
                  a^{(1)}_3 \times b^{(1)}_3  >,  \\
              & < a^{(2)}_0 \times b^{(2)}_0, 
                  a^{(2)}_1 \times b^{(2)}_1, 
                  a^{(2)}_2 \times b^{(2)}_2, 
                  a^{(2)}_3 \times b^{(2)}_3  >,  \\ 
              & < a^{(3)}_0 \times b^{(3)}_0, 
                  a^{(3)}_1 \times b^{(3)}_1, 
                  a^{(3)}_2 \times b^{(3)}_2, 
                  a^{(3)}_3 \times b^{(3)}_3  >
    \end{align*}
    $$
    **4 vector-wise multiplications (16 element-wise multiplications)** can be therefore performed by **only 1 instruction !** (this is of course faster than using 4 vector mul instructions, because it just needs to fetch and decode the instruction once). **BUT there are some restrictions** to use register group such as **alignment**; concretely speaking, the index of `rd`, `rs1` and `rs2` must be the multiple of `LMUL`; the index of `rd` must be the multiple of `2*LMUL` when using widening instructions. The developer therefore needs to carefully arrange the register space; e.g., 
    ```
      vsetvli   t0,  t1, e32, m2        ; SEW = 32, EEW = 64, LMUL = 2 
      vwmulu.vv v0, v10, v20            ; works 
      vwmulu.vv v0, v11, v20            ; doesn't work!
      vwmulu.vv v2, v10, v20            ; doesn't work!

      vsetvli   t0,  t1, e32, m8        ; SEW = 32, EEW = 64, LMUL = 8 
      vwmulu.vv v0, v16, v24            ; works 
      vwmulu.vv v8, v16, v24            ; doesn't work!
    ```
    The default number of registers in a register group is `1, 2, 4, 8` only, but this can be manually configured using `vsetvli` instruction via setting `AVL` to be a specific value instead of `-1`. E.g., setting a register group (SEW = 32-bit) to have only 5 registers can be done with
    ```
      li        t1, 20                  ; AVL = 4 elements * 5 registers = 20
      vsetvli   t0, t1, e32, m8         ; SEW = 32, LMUL = 8 (but in practical VL = AVL = 20 but != VLMAX)
    ```

## Using register group 
  - pros:  
    - **fewer instructions** to perform arithmetic operations 
    - **fewer instructions** to store/load vector (especially combined with `register pools` [1], i.e. something similar to `scratchedpad` that is located between registers and RAM; in essence it is the trade-off between space and time)
  - cons: 
    - **extra instructions** to align/permute the vectors
    - **extra instructions** to configure the parameters of the overall vector file (i.e., `vsetvli` instruction)
  - need to carefully find out **the optimal trade-off** between the above pros and cons

---

## Useful RVV instructions in this work

|  Type  |  Operation  |  AVX-512  |  RVV  |  Comments |
| :----: | :---------: | :-------: | :---: | :-------- |
| arithmetic | multiplication | `mul` | `vmul`,  `vmulhu` | can work with max `64-bit SEW`, but the result is strictly lower/higher 64-bit; **when accumlating, it generates carry bits (costly and always needs `v0`)** |
| arithmetic | addition | `add` | `vadd`, `vadc`, `vmadc` | can work with `full-radix`; but only `v0.m` can serve as `carry flag`, so **overheads** caused by moving `carry flag` and generates carry bits |
| arithmetic | subtraction | `sub` | `vsub`, `vrsub`, `vsbc`, `vmsbc` | `vrsub.vx` is quite useful for `2p-a` |
| arithmetic | multiply-add | `madd52lo`, `madd52hi` | `vwmul`, `vwmaccu` | can work with only max `32-bit SEW` due to `64-bit EEW`; save additions |
| logic | narrowing right-rotation | n/a | `vnsra` | convert a `wide register` to a `single-length register` |
| logic | and/or/xor | `and`, `or`, `xor` | `vand`, `vor`, `vxor` | nothing special |
| logic | left/right shift | `slli`, `srli`, `srai` | `vsll`, `vsrl`, `vsra` | nothing special |
| broadcast | set zero | `setzero` | `vxor` | xor the register with itself |
| broadcast | broadcast an immediate to all elements | `set1` | `vmv.v.i` |  nothing special | 
| broadcast | set vector | `set` | `vslide1up`, `vmv.s.x` | we need a few instructions to form a needed vector, which is costly |  
| movement | move | n/a | `vmv1r.v`, `vmv2r.v`, `vmv4r.v`, `vmv8r.v` | a clear move with indicating the number of registers; the **appropriate alignment required** whereas a future extension may relax the alignment restrictions
| permutation | permute elements within a vector (group) | `shuffle` , `permutex`, `permutexvar` | `vrgather.vv` | again, currently have no good idea to **construct the mask vector quickly**; permuting elements in **register group** is much more costly due to the mask register group |
| permutation | blend | `mask_blend` | `vcompress`, `vmerge` | `vcompress` changes the sequence of elements; `vmerge` should be the best option |

## Discussion regarding RVV 1.0 from a viewpoint of crypto implementer

- pros: 
  - `register group` and `vsetvli` are great things that make RVV a more **vector-like** rather than **SIMD-like**, so only a small number of instructions are needed in RVV 1.0.
  - there are instructions to generate the carry bits, which means you don't need to worry too much about the overflow  

- cons:
  - permuting the elements in a register (group) is very costly, which relies on `vrgather.vv`. Here we consider a very easy example: we have a vector having two elements, i.e., `v2 = a || b`, and we would like to permute them and get `v4 = b || a`. We must have a vector `v3 = 0 || 1`, and then `vrgather.vv v4, v2, v3`. It just seems to be easy, but now the question is how to form a `v3 = 0 || 1`? A quick solution is `vxor.vv v3, v3, v3`, then `li t0, 1`, then `vmv.s.x v3, t0`, which means you need 3 instructions to form a single mask. Or you just precomputed them and just load them when you need them. Futhermore, if you intend to use register-group, this is more catastrophic.
  - some instructions now have a unreasonable alignment requirement, especially `vmv4r.v` and `vmv8r.v` 

- multiplication-related instructions
  - `vmul` and `vmulhu` (single-width integer multiply instructions )
    - pros: `SEW = 64` and `EEW = 64`; you can take full advantage of the 64-bit multiplier 
    - cons: need to work together with addition-related instructions, i.e. `vaddc.vvm` and `vmaddc.vvm`
    - radix-51 for X25519 
    - `vmulhu` is not availabe on `zve64*` when `EEW=64`
  - `vwmulu` and `vwmaccu` 
    - pros: single instruction to perform `multiply-add`
    - cons: make `EEW` increase to `2*SEW`, therefore `max SEW = 32` and `EEW = 64` 
    - radix-25.5 for X25519 
  - why not single-length multiply-add instructions?
    - No instruction to **generate the higher half of product !**
    - No corresponding instructions to **generate carry bits !**; when you add the lower half of the product to the accumulator and then if there is a carry bit, you will have no way to handle it 

--- 

## Potential ISE 
  - more efficient multiply-add 
  - memory access 
    - see [1] and probably use `scratchedpad memory` instead of `register pool`, because `register` means basically you don't need store/load instructions anymore; `cache` always means something where you can't control the read/write.
  - permutation instructions 
  - quickly building wanted vector

--- 

## Implementation tricks
- for mask-register
  One can **always use only 2 instructions** to construct any needed mask for a register group 
  ```
    li          t0, imm                 ; imm is the needed mask value for register group
    vmv.s.x     v0, t0                  ; change the value in v0[0], i.e., the mask-register
  ```

--- 

## How to develop efficient RVV implementation for crypto primitives 
- use **register group** as much as possible to reduce the instruction number; therefore, implementer should take care of the register arrangement and alignment 
- store/load as little as possible
- design the multiplication carefully

---

## References 
[1] H. Li, N. Mentens, and S. Picek, *A Scalable SIMD RISC-V based Processor with Customized Vector Extensions for CRYSTALS-Kyber*, in DAC'2022.
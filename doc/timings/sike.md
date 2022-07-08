# Timing results of SIKE implementation 

## Notation

| Abbreviation | Meaning                          |
| :----------- | :------------------------------- |
|      SW      | pure SoftWare                    |
|      ISE     | custom Instruction Set Extension | 
|      PS      | Product-Scanning                 |
|      KA1     | 1-level KAratsuba                |
|      KA2     | 2-level KAratsuba                |
|      CP      | Carry Propagation                |
|      NP      | No carry Propagation             |

## Scalar implementation

### $\mathbb{F}_p$ arithmetic

| Operation                  | Type      | #Instruction | #Cycle |
| :------------------------- | :-------- | ------------:| ------:|
| integer multiplication     | SW  + PS  |        514   |        |
| integer multiplication     | SW  + KA1 |        496   |        |
| integer multiplication     | SW  + KA2 |      **488** |        |
| integer multiplication     | ISE + PS  |      **177** |        |
| integer multiplication     | ISE + KA1 |        211   |        |
| Montgomery reduction       | SW  + PS  |        424   |        |
| Montgomery reduction       | ISE + PS  |        158   |        |
| $\mathbb{F}_p$ addition    | SW        |        122   |        |
| $\mathbb{F}_p$ addition    | ISE       |        108   |        |
| integer subtraction        | SW  + CP  |         81   |        |
| integer subtraction        | ISE + CP  |         74   |        |
| $\mathbb{F}_p$ subtraction | SW        |        114   |        |
| $\mathbb{F}_p$ subtraction | ISE       |        100   |        |
| $\mathbb{F}_p$ correction  | SW        |        104   |        |
| $\mathbb{F}_p$ correction  | ISE       |         90   |        |
| $\mathbb{F}_p$ negation    | SW        |         63   |        |
| $\mathbb{F}_p$ negation    | ISE       |         56   |        |
| $\mathbb{F}_p$ division 2  | SW        |        103   |        |
| $\mathbb{F}_p$ division 2  | ISE       |         96   |        |

### $\mathbb{F}_{p^2}$ arithmetic

| Operation                             | Type                           | #Instruction | #Cycle |
| :------------------------------------ | :----------------------------- | ------------:| ------:|
| $\mathbb{F}_{p^2}$ multiplication     | SW  + KA2 (mul) + CP (add)     |       2688   |        |
| $\mathbb{F}_{p^2}$ multiplication     | SW  + KA2 (mul) + NP (add)     |     **2640** |        |
| $\mathbb{F}_{p^2}$ multiplication     | ISE + PS  (mul) + CP (add)     |       1194   |        |
| $\mathbb{F}_{p^2}$ multiplication     | ISE + PS  (mul) + NP (add)     |     **1160** |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + CP (add/sub) |       2129   |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + NP (add/sub) |     **2057** |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + CP (add/sub) |        954   |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + NP (add/sub) |     **903**  |        |
| $\mathbb{F}_{p^2}$ addition           | SW                             |        256   |        |
| $\mathbb{F}_{p^2}$ addition           | ISE                            |        228   |        |
| $\mathbb{F}_{p^2}$ subtraction        | SW                             |        240   |        |
| $\mathbb{F}_{p^2}$ subtraction        | ISE                            |        212   |        |
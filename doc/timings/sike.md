# Timing results of SIKEp434 implementation 

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
| integer subtraction        | SW  + NP  |         65   |        |
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
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + CP (add)     |       2129   |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + NP (add)     |     **2057** |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + CP (add)     |        954   |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + NP (add)     |     **903**  |        |
| $\mathbb{F}_{p^2}$ addition           | SW                             |        256   |        |
| $\mathbb{F}_{p^2}$ addition           | ISE                            |        228   |        |
| $\mathbb{F}_{p^2}$ subtraction        | SW                             |        240   |        |
| $\mathbb{F}_{p^2}$ subtraction        | ISE                            |        212   |        |

### Montgomery curve arithmetic

| Operation                             | Type                           | #Instruction | #Cycle |
| :------------------------------------ | :----------------------------- | ------------:| ------:|
| point doubling (xDBL)                 | SW  + CP (add/sub)             |      15642   |        |
| point doubling (xDBL)                 | SW  + NP (add) + CP (sub)      |      15258   |        |
| point doubling (xDBL)                 | SW  + NP (add/sub)             |      15194   |        |
| point doubling (xDBL)                 | ISE + CP (add/sub)             |       7260   |        |
| point doubling (xDBL)                 | ISE + NP (add) + CP (sub)      |       6988   |        |
| point doubling (xDBL)                 | ISE + NP (add/sub)             |       6952   |        |
| point tripling (xTPL)                 | SW  + CP (add/sub)             |      31224   |        |
| point tripling (xTPL)                 | SW  + NP (add) + CP (sub)      |      30504   |        |
| point tripling (xTPL)                 | SW  + NP (add/sub)             |      30408   |        |
| point tripling (xTPL)                 | ISE + CP (add/sub)             |      14723   |        |
| point tripling (xTPL)                 | ISE + NP (add) + CP (sub)      |      14213   |        |
| point tripling (xTPL)                 | ISE + NP (add/sub)             |      14159   |        |
| 4-isogeny generation (get_4_isog)     | SW  + CP (add/sub)             |       9250   |        |
| 4-isogeny generation (get_4_isog)     | SW  + NP (add) + CP (sub)      |       8914   |        |
| 4-isogeny generation (get_4_isog)     | ISE + CP (add/sub)             |       4480   |        |
| 4-isogeny generation (get_4_isog)     | ISE + NP (add) + CP (sub)      |       4242   |        |
| 4-isogeny evaluation (eval_4_isog)    | SW  + CP (add/sub)             |      21313   |        |
| 4-isogeny evaluation (eval_4_isog)    | SW  + NP (add) + CP (sub)      |      20785   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + CP (add/sub)             |       9915   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + NP (add) + CP (sub)      |       9541   |        |
| 3-isogeny generation (get_3_isog)     | SW  + CP (add/sub)             |      13517   |        |
| 3-isogeny generation (get_3_isog)     | SW  + NP (add) + CP (sub)      |      12989   |        |
| 3-isogeny generation (get_3_isog)     | ISE + CP (add/sub)             |       6822   |        |
| 3-isogeny generation (get_3_isog)     | ISE + NP (add) + CP (sub)      |       6448   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW  + CP (add/sub)             |      15633   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW  + NP (add) + CP (sub)      |      15249   |        |
| 3-isogeny evaluation (eval_3_isog)    | ISE + CP (add/sub)             |       7251   |        |
| 3-isogeny evaluation (eval_3_isog)    | ISE + NP (add) + CP (sub)      |       6979   |        |
| Montgomery ladder step (xDBLADD)      | SW  + CP (add/sub)             |      28576   |        |
| Montgomery ladder step (xDBLADD)      | SW  + NP (add) + CP (sub)      |      27856   |        |
| Montgomery ladder step (xDBLADD)      | ISE + CP (add/sub)             |      13306   |        |
| Montgomery ladder step (xDBLADD)      | ISE + NP (add) + CP (sub)      |      12796   |        |

### SIDH key exchange

| Operation                                     | Type                           | #Instruction | #Cycle |
| :-------------------------------------------- | :----------------------------- | ------------:| ------:|
| Alice keygen    (EphemeralKeyGeneration_A)    | SW                             |   32,961,200 |        |
| Alice keygen    (EphemeralKeyGeneration_A)    | ISE                            |   15,158,127 |        |
| Bob   keygen    (EphemeralKeyGeneration_B)    | SW                             |   36,749,214 |        |
| Bob   keygen    (EphemeralKeyGeneration_B)    | ISE                            |   17,042,274 |        |
| Alice sharedsec (EphemeralSecretAgreement_A)  | SW                             |   26,749,381 |        |
| Alice sharedsec (EphemeralSecretAgreement_A)  | ISE                            |   12,275,659 |        |
| Bob   sharedsec (EphemeralSecretAgreement_B)  | SW                             |   31,004,132 |        |
| Bob   sharedsec (EphemeralSecretAgreement_B)  | ISE                            |   14,382,436 |        |

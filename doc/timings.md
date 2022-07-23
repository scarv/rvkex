# Timing results


## Notation

| Abbreviation | Meaning                                  |
| :----------- | :--------------------------------------- |
|      SW      | pure SoftWare                            |
|      ISE     | custom Instruction Set Extension         | 
|      OS      | Operand-Scanning (aka. schoolbook)       |
|      PS      | Product-Scanning (aka. Comba's method)   |
|      KA1     | 1-level KAratsuba multiplication         |
|      KA2     | 2-level KAratsuba multiplication         |
|      CP      | Carry Propagation                        |
|      NP      | No carry Propagation                     |

---

## X25519 radix-$2^{51}$ implementation

### $\mathbb{F}_p$ arithmetic

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| $\mathbb{F}_p$ multiplication  | SW  + OS                |        215   |        |
| $\mathbb{F}_p$ multiplication  | ISE + OS                |         97   |        |
| $\mathbb{F}_p$ squaring        | SW  + OS                |        151   |        |
| $\mathbb{F}_p$ squaring        | ISE + OS                |         69   |        |
| $\mathbb{F}_p$ mul51           | SW  + OS                |         68   |        |
| $\mathbb{F}_p$ mul51           | ISE + OS                |         34   |        |
| $\mathbb{F}_p$ addition        | SW                      |         27   |        |
| $\mathbb{F}_p$ subtraction     | SW                      |         36   |        |

### Montgomery curve arithmetic

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| Montgomery ladder step         | SW                      |       1995   |        |
| Montgomery ladder step         | ISE                     |       1043   |        |

### Variable-base scalar multiplication

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| scalar multiplication          | SW                      |     573,129  |        |
| scalar multiplication          | ISE                     |     308,125  |        |

---

## X25519 radix-$2^{64}$ implementation

### $\mathbb{F}_p$ arithmetic

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| $\mathbb{F}_p$ multiplication  | SW  + PS                |        191   |        |
| $\mathbb{F}_p$ squaring        | SW  + PS                |        179   |        |
| $\mathbb{F}_p$ mul64           | SW  + PS                |         46   |        |
| $\mathbb{F}_p$ addition        | SW                      |         50   |        |
| $\mathbb{F}_p$ subtraction     | SW                      |         55   |        |

### Montgomery curve arithmetic

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| Montgomery ladder step         | SW                      |       2133   |        |

### Variable-base scalar multiplication

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| scalar multiplication          | SW                      |     611,248  |        |

---

## SIKEp434 radix-$2^{56}$ implementation

### $\mathbb{F}_p$ arithmetic

| Operation                  | Type      | #Instruction | #Cycle |
| :------------------------- | :-------- | ------------:| ------:|
| integer multiplication     | SW  + PS  |        514   |        |
| integer multiplication     | SW  + KA1 |        496   |        |
| integer multiplication     | SW  + KA2 |        488   |        |
| integer multiplication     | ISE + PS  |        177   |        |
| integer multiplication     | ISE + KA1 |        211   |        |
| Montgomery reduction       | SW  + PS  |        419   |        |
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
| $\mathbb{F}_{p^2}$ multiplication     | SW  + KA2 (mul) + CP (add)     |       2678   |        |
| $\mathbb{F}_{p^2}$ multiplication     | SW  + KA2 (mul) + NP (add)     |       2630   |        |
| $\mathbb{F}_{p^2}$ multiplication     | ISE + PS  (mul) + CP (add)     |       1194   |        |
| $\mathbb{F}_{p^2}$ multiplication     | ISE + PS  (mul) + NP (add)     |       1160   |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + CP (add)     |       2119   |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + KA2 (mul) + NP (add)     |       2071   |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + CP (add)     |        954   |        |
| $\mathbb{F}_{p^2}$ squaring           | ISE + PS  (mul) + NP (add)     |        903   |        |
| $\mathbb{F}_{p^2}$ addition           | SW                             |        256   |        |
| $\mathbb{F}_{p^2}$ addition           | ISE                            |        228   |        |
| $\mathbb{F}_{p^2}$ subtraction        | SW                             |        240   |        |
| $\mathbb{F}_{p^2}$ subtraction        | ISE                            |        212   |        |

### Montgomery curve arithmetic

| Operation                             | Type                           | #Instruction | #Cycle |
| :------------------------------------ | :----------------------------- | ------------:| ------:|
| point doubling (xDBL)                 | SW  + CP (add/sub)             |      15582   |        |
| point doubling (xDBL)                 | SW  + NP (add) + CP (sub)      |      15198   |        |
| point doubling (xDBL)                 | SW  + NP (add/sub)             |      15134   |        |
| point doubling (xDBL)                 | ISE + CP (add/sub)             |       7260   |        |
| point doubling (xDBL)                 | ISE + NP (add) + CP (sub)      |       6988   |        |
| point doubling (xDBL)                 | ISE + NP (add/sub)             |       6952   |        |
| point tripling (xTPL)                 | SW  + CP (add/sub)             |      31104   |        |
| point tripling (xTPL)                 | SW  + NP (add) + CP (sub)      |      30384   |        |
| point tripling (xTPL)                 | SW  + NP (add/sub)             |      30288   |        |
| point tripling (xTPL)                 | ISE + CP (add/sub)             |      14723   |        |
| point tripling (xTPL)                 | ISE + NP (add) + CP (sub)      |      14213   |        |
| point tripling (xTPL)                 | ISE + NP (add/sub)             |      14159   |        |
| 4-isogeny generation (get_4_isog)     | SW  + CP (add/sub)             |       9210   |        |
| 4-isogeny generation (get_4_isog)     | SW  + NP (add) + CP (sub)      |       8874   |        |
| 4-isogeny generation (get_4_isog)     | SW  + NP (add/sub)             |       8794   |        |
| 4-isogeny generation (get_4_isog)     | ISE + CP (add/sub)             |       4480   |        |
| 4-isogeny generation (get_4_isog)     | ISE + NP (add) + CP (sub)      |       4242   |        |
| 4-isogeny generation (get_4_isog)     | ISE + NP (add/sub)             |       4190   |        |
| 4-isogeny evaluation (eval_4_isog)    | SW  + CP (add/sub)             |      21233   |        |
| 4-isogeny evaluation (eval_4_isog)    | SW  + NP (add) + CP (sub)      |      20705   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + NP (add/sub)             |      20609   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + CP (add/sub)             |       9915   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + NP (add) + CP (sub)      |       9541   |        |
| 4-isogeny evaluation (eval_4_isog)    | ISE + NP (add/sub)             |       9487   |        |
| 3-isogeny generation (get_3_isog)     | SW  + CP (add/sub)             |      13467   |        |
| 3-isogeny generation (get_3_isog)     | SW  + NP (add) + CP (sub)      |      12939   |        |
| 3-isogeny generation (get_3_isog)     | SW  + NP (add/sub)             |      12811   |        |
| 3-isogeny generation (get_3_isog)     | ISE + CP (add/sub)             |       6822   |        |
| 3-isogeny generation (get_3_isog)     | ISE + NP (add) + CP (sub)      |       6448   |        |
| 3-isogeny generation (get_3_isog)     | ISE + NP (add/sub)             |       6362   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW  + CP (add/sub)             |      15573   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW  + NP (add) + CP (sub)      |      15189   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW  + NP (add/sub)             |      15125   |        |
| 3-isogeny evaluation (eval_3_isog)    | ISE + CP (add/sub)             |       7251   |        |
| 3-isogeny evaluation (eval_3_isog)    | ISE + NP (add) + CP (sub)      |       6979   |        |
| 3-isogeny evaluation (eval_3_isog)    | ISE + NP (add/sub)             |       6943   |        |
| Montgomery ladder step (xDBLADD)      | SW  + CP (add/sub)             |      28466   |        |
| Montgomery ladder step (xDBLADD)      | SW  + NP (add) + CP (sub)      |      27746   |        |
| Montgomery ladder step (xDBLADD)      | SW  + NP (add/sub)             |      27618   |        |
| Montgomery ladder step (xDBLADD)      | ISE + CP (add/sub)             |      13306   |        |
| Montgomery ladder step (xDBLADD)      | ISE + NP (add) + CP (sub)      |      12796   |        |
| Montgomery ladder step (xDBLADD)      | ISE + NP (add/sub)             |      12724   |        |

### SIDH key exchange

| Operation                                     | Type      | #Instruction | #Cycle |
| :-------------------------------------------- | :---------| ------------:| ------:|
| Alice keygen    (EphemeralKeyGeneration_A)    | SW        |   32,682,992 |        |
| Alice keygen    (EphemeralKeyGeneration_A)    | ISE       |   15,073,599 |        |
| Bob   keygen    (EphemeralKeyGeneration_B)    | SW        |   36,566,398 |        |
| Bob   keygen    (EphemeralKeyGeneration_B)    | ISE       |   16,956,512 |        |
| Alice sharedsec (EphemeralSecretAgreement_A)  | SW        |   26,525,477 |        |
| Alice sharedsec (EphemeralSecretAgreement_A)  | ISE       |   12,208,627 |        |
| Bob   sharedsec (EphemeralSecretAgreement_B)  | SW        |   30,758,560 |        |
| Bob   sharedsec (EphemeralSecretAgreement_B)  | ISE       |   14,311,470 |        |

### SIKE key encapsulation

| Operation              | Type       | #Instruction | #Cycle |
| :----------------------| :--------- | ------------:| ------:|
| Key Generation         | SW         |   36,457,604 |        |
| Key Generation         | ISE        |   16,968,718 |        |
| Encaplustaion          | SW         |   59,275,827 |        |
| Encaplustaion          | ISE        |   27,349,584 |        |
| Decaplustaion          | SW         |   63,505,594 |        |
| Decaplustaion          | ISE        |   29,449,111 |        |

---

## SIKEp434 radix-$2^{64}$ implementation

| Operation                  | Type      | #Instruction | #Cycle |
| :------------------------- | :-------- | ------------:| ------:|
| integer multiplication     | SW  + PS  |        417   |        |
| integer multiplication     | SW  + KA1 |        527   |        |
| Montgomery reduction       | SW  + PS  |        295   |        |
| $\mathbb{F}_p$ addition    | SW        |        143   |        |
| integer subtraction        | SW        |         95   |        |
| $\mathbb{F}_p$ subtraction | SW        |        114   |        |
| $\mathbb{F}_p$ correction  | SW        |        103   |        |
| $\mathbb{F}_p$ negation    | SW        |         57   |        |
| $\mathbb{F}_p$ division 2  | SW        |         92   |        |

### $\mathbb{F}_{p^2}$ arithmetic

| Operation                             | Type                           | #Instruction | #Cycle |
| :------------------------------------ | :----------------------------- | ------------:| ------:|
| $\mathbb{F}_{p^2}$ multiplication     | SW  + PS (mul)                 |       2305   |        |
| $\mathbb{F}_{p^2}$ squaring           | SW  + PS (mul)                 |       1665   |        |
| $\mathbb{F}_{p^2}$ addition           | SW                             |        298   |        |
| $\mathbb{F}_{p^2}$ subtraction        | SW                             |        240   |        |

### Montgomery curve arithmetic

| Operation                             | Type                           | #Instruction | #Cycle |
| :------------------------------------ | :----------------------------- | ------------:| ------:|
| point doubling (xDBL)                 | SW                             |      13214   |        |
| point tripling (xTPL)                 | SW                             |      26369   |        |
| 4-isogeny generation (get_4_isog)     | SW                             |       7374   |        |
| 4-isogeny evaluation (eval_4_isog)    | SW                             |      18135   |        |
| 3-isogeny generation (get_3_isog)     | SW                             |      11291   |        |
| 3-isogeny evaluation (eval_3_isog)    | SW                             |      13205   |        |
| Montgomery ladder step (xDBLADD)      | SW                             |      24103   |        |

### SIDH key exchange

| Operation                                     | Type      | #Instruction | #Cycle |
| :-------------------------------------------- | :---------| ------------:| ------:|
| Alice keygen    (EphemeralKeyGeneration_A)    | SW        |   28,546,015 |        |
| Bob   keygen    (EphemeralKeyGeneration_B)    | SW        |   31,750,429 |        |
| Alice sharedsec (EphemeralSecretAgreement_A)  | SW        |   23,067,052 |        |
| Bob   sharedsec (EphemeralSecretAgreement_B)  | SW        |   26,719,178 |        |

### SIKE key encapsulation

| Operation              | Type       | #Instruction | #Cycle |
| :----------------------| :--------- | ------------:| ------:|
| Key Generation         | SW         |   31,762,635 |        |
| Encaplustaion          | SW         |   51,680,425 |        |
| Decaplustaion          | SW         |   55,329,235 |        |

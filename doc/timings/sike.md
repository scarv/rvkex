# Timing results of SIKE implementation 

## Scalar implementation

### $\mathbb{F}_p$ arithmetic


| Operation                  | Type                    | #Instruction | #Cycle |
| :------------------------- | :---------------------- | ------------:| ------:|
| integer multiplication     | SW  + product-scanning  |        514   |        |
| integer multiplication     | SW  + 1-level Karatsuba |        496   |        |
| integer multiplication     | SW  + 2-level Karatsuba |      **488** |        |
| integer multiplication     | ISE + product-scanning  |      **177** |        |
| integer multiplication     | ISE + 1-level Karatsuba |        211   |        |
| Montgomery reduction       | SW  + product-scanning  |        424   |        |
| Montgomery reduction       | ISE + product-scanning  |        158   |        |
| $\mathbb{F}_p$ addition    | SW                      |        122   |        |
| $\mathbb{F}_p$ addition    | ISE                     |        108   |        |
| integer subtraction        | SW                      |         81   |        |
| integer subtraction        | ISE                     |         74   |        |
| $\mathbb{F}_p$ subtraction | SW                      |        114   |        |
| $\mathbb{F}_p$ subtraction | ISE                     |        100   |        |
| $\mathbb{F}_p$ correction  | SW                      |        104   |        |
| $\mathbb{F}_p$ correction  | ISE                     |         90   |        |
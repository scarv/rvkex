# Timing results


## X25519 radix-$2^{51}$ implementation

### Variable-base scalar multiplication

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| scalar multiplication          | `RV64_TYPE1`            |     573,129  |        |
| scalar multiplication          | `RV64_TYPE2`            |     308,125  |        |

---

## X25519 radix-$2^{64}$ implementation

### Variable-base scalar multiplication

| Operation                      | Type                    | #Instruction | #Cycle |
| :----------------------------- | :---------------------- | ------------:| ------:|
| scalar multiplication          | `RV64_TYPE1`            |     593,334  |        |
| scalar multiplication          | `RV64_TYPE2`            |     520,206  |        |

---

## SIKEp434 radix-$2^{56}$ implementation

### SIKE key encapsulation

| Operation              | Type                    | #Instruction | #Cycle |
| :----------------------| :---------------------- | ------------:| ------:|
| Key Generation         | `RV64_TYPE1`            |   36,415,562 |        |
| Key Generation         | `RV64_TYPE2`            |   16,923,994 |        |
| Key Generation         | `RV64_TYPE3`            |   16,561,480 |        |
| Encaplustaion          | `RV64_TYPE1`            |   59,207,327 |        |
| Encaplustaion          | `RV64_TYPE2`            |   27,288,636 |        |
| Encaplustaion          | `RV64_TYPE3`            |   26,794,956 |        |
| Decaplustaion          | `RV64_TYPE1`            |   63,422,425 |        |
| Decaplustaion          | `RV64_TYPE2`            |   29,376,543 |        |
| Decaplustaion          | `RV64_TYPE3`            |   28,790,997 |        |

---

## SIKEp434 radix-$2^{64}$ implementation

### SIKE key encapsulation

| Operation              | Type                    | #Instruction | #Cycle |
| :----------------------| :---------------------- | ------------:| ------:|
| Key Generation         | `RV64_TYPE1`            |   35,910,075 |        |
| Key Generation         | `RV64_TYPE2`            |   26,388,427 |        |
| Encaplustaion          | `RV64_TYPE1`            |   58,527,705 |        |
| Encaplustaion          | `RV64_TYPE2`            |   42,849,945 |        |
| Decaplustaion          | `RV64_TYPE1`            |   62,598,805 |        |
| Decaplustaion          | `RV64_TYPE2`            |   45,928,349 |        |

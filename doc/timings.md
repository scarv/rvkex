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



#include "params.h"
#include "constants.h"

const uint64_t pbits = 511;

const struct fp p = {{
  0x181B90533C6C87B, 0x10DFA2BD6541A8D, 0x03307C2D3C9709C, 
  0x0ACFE6AA0EA2CE6, 0x1322C9CDA7AAC6C, 0x0446212D7DFE634, 
  0x1312AD0B420EBB7, 0x17FF91561A2BC7C, 0x065B48E8F740F89,
}};

const struct fp p_cofactor = {{4}};

/* (p+1)/prod(primes) */
const struct fp fp_0 = {{0}};

/* 2^513 mod p */
const struct fp fp_1 = {{
  0x7762E5FD1E1599, 0xBA1D24D05B7B3B, 0x100D931DD10CCF1,
  0x9F07EADB6D1F81, 0x0520EFBB9AA1E2, 0x0AA15A1C8A080F9,
  0x0A29EC7B5B656C, 0x80229517D25191, 0x003793732BBB24F,
}};

/* (2^513)^2 mod p */
const struct fp r_squared_mod_p = {{
  0x1BC424D249C031F, 0x1B49BC860E8AAC3, 0x126BADAF56E1532,
  0x057678275E950ED, 0x040F31D76DBA340, 0x00947F32E20CB28,
  0x1BF517708246E52, 0x1757FB88E88D1B1, 0x00A3FBB0C3F9FA8,
}};

/* -p^-1 mod 2^57 */
const uint64_t inv_min_p_mod_r = 0xc1301f632e294d;

/* p - 2 */
const struct u64 p_minus_2 = {{
  0x1b81b90533c6c879, 0xc2721bf457aca835, 0x516730cc1f0b4f25, 0xa7aac6c567f35507,
  0x5afbfcc69322c9cd, 0xb42d083aedc88c42, 0xfc8ab0d15e3e4c4a, 0x65b48e8f740f89bf,
}};

/* (p - 1) / 2 */
const struct u64 p_minus_1_halves = {{
  0x8dc0dc8299e3643d, 0xe1390dfa2bd6541a, 0xa8b398660f85a792, 0xd3d56362b3f9aa83,
  0x2d7dfe63499164e6, 0x5a16841d76e44621, 0xfe455868af1f2625, 0x32da4747ba07c4df,
}};

/* floor(4 sqrt(p)) */
const struct fp four_sqrt_p = {{
  0x1895E71E1A20B3F, 0x66CAFC31B52B0B, 0x1507965A0B34E34, 
  0x13B23ACB2428572, 0x0000002856F139,
}};

/* x = 7 has full order on E0; this is 1/(7^2-1). */
const fp first_elligator_rand = {{
  0x0567B58CD2F3052, 0xB3FC1D398D6709, 0x0CCAFD737DBA068, 
  0x1C8A99C6B46C899, 0xCC1DBDE6FC72F2, 0x182EC0C8FEA9978, 
  0x1761C8B22C09D24, 0x5550B8EBC1D2FD, 0x04E785F0A4D5FB1,
}};

const unsigned cost_ratio_inv_mul = 128; /* TODO figure out exactly */


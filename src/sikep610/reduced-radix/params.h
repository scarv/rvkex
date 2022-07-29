#ifndef _PARAMS_H
#define _PARAMS_H

#define ALICE                   0
#define BOB                     1 
#define OALICE_BITS             305  
#define OBOB_BITS               305
#define NWORDS_ORDER            5
#define NBITS_FIELD             610 
#define FP2_ENCODED_BYTES       2*((NBITS_FIELD + 7) / 8)

#define MSG_BYTES               24
#define SECRETKEY_A_BYTES       39
#define SECRETKEY_B_BYTES       38
#define MASK_ALICE              0x01 
#define MASK_BOB                0xFF 

#define MAX_INT_POINTS_ALICE    8        
#define MAX_INT_POINTS_BOB      10  
#define MAX_Alice               152
#define MAX_Bob                 192  

#define CRYPTO_SECRETKEYBYTES   524    // MSG_BYTES + SECRETKEY_B_BYTES + CRYPTO_PUBLICKEYBYTES bytes
#define CRYPTO_PUBLICKEYBYTES   462
#define CRYPTO_BYTES             24
#define CRYPTO_CIPHERTEXTBYTES  486    // CRYPTO_PUBLICKEYBYTES + MSG_BYTES bytes  

#define NWORDS_FIELD            10

#endif 

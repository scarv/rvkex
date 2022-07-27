#ifndef _PARAMS_H
#define _PARAMS_H

#define ALICE                   0
#define BOB                     1 
#define OALICE_BITS             250  
#define OBOB_BITS               253
#define NWORDS_ORDER            4
#define NBITS_FIELD             503 
#define FP2_ENCODED_BYTES       2*((NBITS_FIELD + 7) / 8)

#define MSG_BYTES               24
#define SECRETKEY_A_BYTES       32
#define SECRETKEY_B_BYTES       32
#define MASK_ALICE              0x03 
#define MASK_BOB                0x0F 

#define MAX_INT_POINTS_ALICE    7        
#define MAX_INT_POINTS_BOB      8  
#define MAX_Alice               125
#define MAX_Bob                 159  

#define CRYPTO_SECRETKEYBYTES   434    // MSG_BYTES + SECRETKEY_B_BYTES + CRYPTO_PUBLICKEYBYTES bytes
#define CRYPTO_PUBLICKEYBYTES   378
#define CRYPTO_BYTES             24
#define CRYPTO_CIPHERTEXTBYTES  402    // CRYPTO_PUBLICKEYBYTES + MSG_BYTES bytes  

#define NWORDS_FIELD            8

#endif 

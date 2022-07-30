#ifndef _PARAMS_H
#define _PARAMS_H

#define ALICE                   0
#define BOB                     1 
#define OALICE_BITS             372  
#define OBOB_BITS               379
#define NWORDS_ORDER            6
#define NBITS_FIELD             751 
#define FP2_ENCODED_BYTES       2*((NBITS_FIELD + 7) / 8)

#define MSG_BYTES               32
#define SECRETKEY_A_BYTES       47
#define SECRETKEY_B_BYTES       48
#define MASK_ALICE              0x0F 
#define MASK_BOB                0x03 

#define MAX_INT_POINTS_ALICE    8        
#define MAX_INT_POINTS_BOB      10  
#define MAX_Alice               186
#define MAX_Bob                 239  

#define CRYPTO_SECRETKEYBYTES   644    // MSG_BYTES + SECRETKEY_B_BYTES + CRYPTO_PUBLICKEYBYTES bytes
#define CRYPTO_PUBLICKEYBYTES   564
#define CRYPTO_BYTES             32
#define CRYPTO_CIPHERTEXTBYTES  596    // CRYPTO_PUBLICKEYBYTES + MSG_BYTES bytes  

#define NWORDS_FIELD            12

#endif 

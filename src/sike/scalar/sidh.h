#ifndef _SIDH_H
#define _SIDH_H

#include "curve.h"
#include "share.h"

static const uint64_t A_gen[6*NLMB56] = {
  0xADF455C5C345BF, 0x5C5CC767AC2B05, 0x79951F02579193, 0x89FA27B1AFE4E8,
  0x48C8CD70E792DC, 0x621FF797F526BB, 0xC42181DB6131AF, 0x00000A1C08B1EC, // XPA0
  0x840EB87CDA7788, 0xAA0ECF9F9D0B74, 0xBDF41715D52971, 0x7AACFFAACB5732,
  0x7E419F8CD8E51F, 0x9E8CA7F424730D, 0x4AD671EB919A17, 0x0000FFA26C5A92, // XPA1
  0xC6E64588B7273B, 0x26D74CBBF1C6FE, 0x07A78098C7D2A6, 0x70841B03F8F58F,
  0x5538DDE23941F4, 0x92151B63EDA204, 0x76735CFEB0FFD4, 0x0001C4CB775428, // XQA0
  0xB0F733C17FFDD6, 0xBD037DA0A050AD, 0x3DB144E02F6AFF, 0xF524E374680EC4,
  0x0E29951E2E5D5F, 0xE508E2DDA11526, 0x3EA6E4B552E2ED, 0x00018ECCDDF4B5, // XQA1
  0xBA4DB518CD6C7D, 0x251FE3CC061101, 0x6949A9121B2CB0, 0x6D2F82AD259B0C,
  0x75D92D60E17AC1, 0xC4F33AA41F1CE1, 0x43413FBE6A9B9B, 0x00022A81D8D556, // XRA0
  0xADBC70FC82E54A, 0xDDB0D5FADDEDB8, 0x34C80096A0EF9C, 0xAA96E0E45820C7,
  0x379AF87799994B, 0x27E2044961599E, 0xC6DB2B94FBF09F, 0x0000B87FC716C0, // XRA1
};

static const uint64_t B_gen[6*NLMB56] = {
  0x5497556EDD48A3, 0xB501546F1C056E, 0x46D049887D2A61, 0x9D450C4FEB9194,
  0x490D2B5864A4A6, 0xF5B9B883F276A6, 0x1F22CC287022D5, 0x0001BED4772E55, // XPB0
  0x00000000000000, 0x00000000000000, 0x00000000000000, 0x00000000000000,
  0x00000000000000, 0x00000000000000, 0x00000000000000, 0x00000000000000, // XPB1
  0xE2A3F93D8B6B8E, 0x71F51700FE1CFA, 0x228413C27C4948, 0xAF60BD62EF1A94,
  0x267E8A498FF4A4, 0x837FB00AD2A708, 0xAEF4328294E017, 0x000034080181D8, // XQB0
  0x00000000000000, 0x00000000000000, 0x00000000000000, 0x00000000000000,
  0x00000000000000, 0x00000000000000, 0x00000000000000, 0x00000000000000, // XQB1
  0x3B34FAFEFDC8E4, 0xF44977C3E64728, 0x62816F4E9A9208, 0xA262EC9D7DEAE9,
  0x43F45B68A2BA8A, 0xF5048176F112EA, 0x3702106D022634, 0x00007E8A50F02E, // XRB0
  0x78B7C1DA22CCB1, 0x9C99AD1D9230B3, 0x11813E23696D08, 0x39D48A53EBE157,
  0x407C932B35A682, 0xB54B445F6FD138, 0xD3BEF93B29A3F6, 0x000173FA910377, // XRB1   
};

static const unsigned int strat_Alice[MAX_Alice-1] = { 
  48, 28, 16, 8, 4, 2, 1, 1, 2, 1, 1, 4, 2, 1, 1, 
  2, 1, 1, 8, 4, 2, 1, 1, 2, 1, 1, 4, 2, 1, 1, 2, 
  1, 1, 13, 7, 4, 2, 1, 1, 2, 1, 1, 3, 2, 1, 1, 
  1, 1, 5, 4, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 21, 
  12, 7, 4, 2, 1, 1, 2, 1, 1, 3, 2, 1, 1, 1, 1, 
  5, 3, 2, 1, 1, 1, 1, 2, 1, 1, 1, 9, 5, 3, 2, 1, 
  1, 1, 1, 2, 1, 1, 1, 4, 2, 1, 1, 1, 2, 1, 1 };

static const unsigned int strat_Bob[MAX_Bob-1] = { 
  66, 33, 17, 9, 5, 3, 2, 1, 1, 1, 1, 2, 1, 1, 1, 4, 
  2, 1, 1, 1, 2, 1, 1, 8, 4, 2, 1, 1, 1, 2, 1, 1, 4, 
  2, 1, 1, 2, 1, 1, 16, 8, 4, 2, 1, 1, 1, 2, 1, 1, 
  4, 2, 1, 1, 2, 1, 1, 8, 4, 2, 1, 1, 2, 1, 1, 4, 2, 
  1, 1, 2, 1, 1, 32, 16, 8, 4, 3, 1, 1, 1, 1, 2, 1, 
  1, 4, 2, 1, 1, 2, 1, 1, 8, 4, 2, 1, 1, 2, 1, 1, 4, 
  2, 1, 1, 2, 1, 1, 16, 8, 4, 2, 1, 1, 2, 1, 1, 4, 
  2, 1, 1, 2, 1, 1, 8, 4, 2, 1, 1, 2, 1, 1, 4, 2, 1, 
  1, 2, 1, 1 };

void EphemeralKeyGeneration_A(const unsigned char* PrivateKeyA, unsigned char* PublicKeyA);

#endif

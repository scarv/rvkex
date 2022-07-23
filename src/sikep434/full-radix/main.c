#include "share.h"
#include "rdtsc.h"
#include "fp.h"
#include "fpx.h"
#include "curve.h"
#include "sidh.h" 
#include "sike.h"

// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void test_fp()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0003456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a[NLMB64] = {  0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                          0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                          0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                          0x0003456789ABCDEFULL };
  // b := 0x0003CDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b[NLMB64] = {  0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                          0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                          0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                          0x0003CDEF01234567ULL };
  uint64_t z[NLMB64*2], r[NLMB64];

  printf("\n**************************************************************************\n");
  printf("FP ARITH:\n");

  printf("- mp mul v0 sw:");

  LOAD_CACHE(mp_mul_v0_sw(z, a, b), 100);
  MEASURE_CYCLES(mp_mul_v0_sw(z, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi64_print("  r  = 0x", z, NLMB64*2);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  printf("- mp mul v1 sw:");

  LOAD_CACHE(mp_mul_v1_sw(z, a, b), 100);
  MEASURE_CYCLES(mp_mul_v1_sw(z, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi64_print("  r  = 0x", z, NLMB64*2);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  printf("");

  // ---------------------------------------------------------------------------

  printf("- rdc mont v0 sw:");

  mp_mul_v0_sw(z, a, b);

  LOAD_CACHE(rdc_mont_v0_sw(r, z), 100);
  MEASURE_CYCLES(rdc_mont_v0_sw(r, z), 1000);
  printf("     #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x147173547FF63D0B52AB864DF1D570AF09061B91AC6FE5B8A6CCE68DD6D2D6BFF0C770842C494\
          08C8AF46BF03037800688DADCB8D60EF;
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif 

  printf("");

  // ---------------------------------------------------------------------------

  printf("- mp add v0 sw:");

  LOAD_CACHE(mp_add_v0_sw(r, a, b), 100);
  MEASURE_CYCLES(mp_add_v0_sw(r, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x713568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356\
          8ACF13568ACF13568ACF13568ACF1356;
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif 

  printf("- fp add v0 sw:");

  LOAD_CACHE(fpadd_v0_sw(r, a, b), 100);
  MEASURE_CYCLES(fpadd_v0_sw(r, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2AB183CA02CCDB0D653A98744D2A993425A66281DB60E8F4C2660C4CF13568ACF13568ACF1356\
          8ACF13568ACF13568ACF13568ACF1358
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif 

  printf("");

  // ---------------------------------------------------------------------------

  printf("- mp sub p2 v0 sw:");

  LOAD_CACHE(mp_sub_p2_v0_sw(r, a, b), 100);
  MEASURE_CYCLES(mp_sub_p2_v0_sw(r, a, b), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("- mp sub p4 v0 sw:");

  LOAD_CACHE(mp_sub_p4_v0_sw(r, a, b), 100);
  MEASURE_CYCLES(mp_sub_p4_v0_sw(r, a, b), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x847F524E655992B68F6D28F9D09E16690E9594DEB43176E7D5164148888877777777888888887\
          77777778888888877777777888888884
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("- fp sub v0 sw:");

  LOAD_CACHE(fpsub_v0_sw(r, a, b), 100);
  MEASURE_CYCLES(fpsub_v0_sw(r, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("");

  // ---------------------------------------------------------------------------

  printf("- fp neg v0 sw:");

  LOAD_CACHE(fpneg_v0_sw(r), 100);
  MEASURE_CYCLES(fpneg_v0_sw(r), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x122D6C4831899D8D57A4579DE72BDF6697388D9058F58FA5FA78E3C543210FEDCBA9876543210\
          FEDCBA9876543210FEDCBA987654320F
  memcpy(r, a, sizeof(uint64_t)*NLMB64);
  fpneg_v0_sw(r);
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("");

  // ---------------------------------------------------------------------------

  printf("- fp div2 v0 sw:");

  LOAD_CACHE(fpdiv2_v0_sw(r, a), 100);
  MEASURE_CYCLES(fpdiv2_v0_sw(r, a), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2BCC35861A099B70FD29F05B87722BE74D0EFDD823E497F725DF13655E6F78091A2B3C4D5E6F7\
          8091A2B3C4D5E6F78091A2B3C4D5E6F7
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("");

  // ---------------------------------------------------------------------------

  printf("- fp crt v0 sw:");

  memcpy(r, a, sizeof(uint64_t)*NLMB64);

  LOAD_CACHE(fpcorrection_v0_sw(r), 100);
  MEASURE_CYCLES(fpcorrection_v0_sw(r), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x1114862945AAA9426E59107E6AD98855CE8EF58531F4B0361CEECA6ABCDEF0123456789ABCDEF\
          0123456789ABCDEF0123456789ABCDF0
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("**************************************************************************\n");
}

void test_fpx()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0003456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[NLMB64] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                           0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                           0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                           0x0003456789ABCDEFULL };
  // b := 0x0003CDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[NLMB64] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                           0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                           0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                           0x0003CDEF01234567ULL };
  f2elm_t  r, a;

  memcpy(a[0], a64, sizeof(uint64_t)*NLMB64); 
  memcpy(a[1], b64, sizeof(uint64_t)*NLMB64); 

  printf("\n**************************************************************************\n");
  printf("FP2 ARITH:\n");

  printf("- fp2 mul:");

  LOAD_CACHE(fp2mul_mont(r, a, a), 10);
  MEASURE_CYCLES(fp2mul_mont(r, a, a), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x3306B70C7878F4FC445701989C949D34730CD77D27EB6133F6DB088FED9FA1E7A18F5515\
          74C4BD908049D3BCE94A63695F8ADFBECDA8E
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi64_print("  r0 = 0x", r[0], NLMB64);
  mpi64_print("  r1 = 0x", r[1], NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64*2);
#endif 

  // ---------------------------------------------------------------------------

  printf("- fp2 sqr:");

  LOAD_CACHE(fp2sqr_mont(r, a), 10);
  MEASURE_CYCLES(fp2sqr_mont(r, a), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x3306B70C7878F4FC445701989C949D34730CD77D27EB6133F6DB088FED9FA1E7A18F5515\
          74C4BD908049D3BCE94A63695F8ADFBECDA8E
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi64_print("  r0 = 0x", r[0], NLMB64);
  mpi64_print("  r1 = 0x", r[1], NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64*2);
#endif 

  // ---------------------------------------------------------------------------

  printf("- fp2 add:");

  LOAD_CACHE(fp2add(r, a, a), 10);
  MEASURE_CYCLES(fp2add(r, a, a), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x22290C528B555284DCB220FCD5B310AB9D1DEB0A63E9606C39DD94D579BDE02468ACF13579BDE\
          02468ACF13579BDE02468ACF13579BE0;
  // r1 = 0x3339FB417A446395EDC30FEBC4A221BCAE2ED9F952D8717D4AEE83C468ACF13579BDE02468ACF\
          13579BDE02468ACF13579BDE02468AD0;
  mpi64_print("  r0 = 0x", r[0], NLMB64);
  mpi64_print("  r1 = 0x", r[1], NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  // ---------------------------------------------------------------------------

  printf("- fp2 sub:");

  LOAD_CACHE(fp2sub(r, a, a), 10);
  MEASURE_CYCLES(fp2sub(r, a, a), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0;
  // r1 = 0;
  mpi64_print("  r0 = 0x", r[0], NLMB64);
  mpi64_print("  r1 = 0x", r[1], NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  printf("**************************************************************************\n");
}

void test_curve()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  point_proj P, Q, PQ;
  f2elm_t A24plus, C24, A24minus, coeff[3], A24, XPQ, ZPQ;
  const felm_t mont_Rx4 = {
    0x000000000001D0B1, 0x0000000000000000, 0x0000000000000000, 0xE67E59990D000000, 
    0xE4403775252604AE, 0x37CCF17AFC17E3DC, 0x00017F9B77DD4827, };

  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB64);                //    0
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB64);                //    0
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB64);                //    0
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB64);                //    0
  memcpy(&A24plus[0], mont_R, sizeof(uint64_t)*NLMB64);       //    1
  memset(&A24plus[1],      0, sizeof(uint64_t)*NLMB64);       //    0
  memcpy(&A24minus[0], mont_Rx4, sizeof(uint64_t)*NLMB64);    //    4
  memset(&A24minus[1],        0, sizeof(uint64_t)*NLMB64);    //    0
  memcpy(&C24[0], mont_Rx4, sizeof(uint64_t)*NLMB64);         //    4
  memset(&C24[1],        0, sizeof(uint64_t)*NLMB64);         //    0

  printf("\n**************************************************************************\n");
  printf("MONTGOMERY CURVE ARITH:\n");

  printf("- xDBL:");

  LOAD_CACHE(xDBL(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL(&P, &Q, A24plus, C24), 100);
  printf("               #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x1DF58B543C8AD438BF85AFB581109D9A9A5F01854AC9BC0324C1D8623B473C0CF70800C3714AF\
           A9DF28B8AE9546CB4FD62C8E1B5FF22E;
  // XQ1 = 0xE56C71A84A54EAF641A72686AB83725977AACC4D24EFACC0598AFEAE9F3EBB17730A35B41A7F0\
           50761A79882454EA580CE67658F4B61;
  // ZQ0 = 0x60C56C36E22FCE059EC41DEC606922EFAFA1C13BA531244E4404398994B97EB0EE4A05AA7B387\
           6811DB6F03946DC86BCD8A3E972DAAC;
  // ZQ1 = 0x33ABAE3BFC4173F7FAC7FAE7D499E8EC26BEE972CD79FB924748EC81AAA227BD067C16ED727DC\
           B9AF66D3AB670F1F012487D48C602BA;
  mpi64_print("  XQ0 = 0x", Q.X[0], NLMB64);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XQ1 = 0x", Q.X[1], NLMB64);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ0 = 0x", Q.Z[0], NLMB64);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ1 = 0x", Q.Z[1], NLMB64);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB64);
#endif 

  // ---------------------------------------------------------------------------   

  printf("- xTPL:");

  LOAD_CACHE(xTPL(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL(&P, &Q, A24minus, A24plus), 100);
  printf("               #inst = %lld\n", diff_cycles);   

#if DEBUG
  // XQ0 = 0x416C62092E5919D21AE4E1D0B30C117ACD21EF38B18F934708A2215C8EE7A30D59BBC6E\
           5BDE7E27BB848662298AEF4BB91CBDD9D14F22
  // XQ1 = 0x1E13BD3B4E9ED537CA5A87BC1E9D0AA4EF91A7526650FCF42896CECDE9F33EED82D5377\
           0052E3FD871F4C2642E57C6B3C3288DD8B2700
  // ZQ0 = 0x4558B5DFCACE8F27EA2A6044B8D1F8B0E8F92EF670A19B75C67DCA0C0C7C73E2E10CEDF\
           30EC979117FEF1CDFEB18EF337E8AC0F305F7E
  // ZQ1 = 0x6DFEE68F111FA3F5348A2B28A4E7EBF2EB6E1D1484ABD53BC3EF459FB2384247482BBB1\
           78D414B892CCECCA18A4E0EDB837647FB82CA
  mpi64_print("  XQ0 = 0x", Q.X[0], NLMB64);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XQ1 = 0x", Q.X[1], NLMB64);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ0 = 0x", Q.Z[0], NLMB64);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ1 = 0x", Q.Z[1], NLMB64);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB64);
#endif  

  // ---------------------------------------------------------------------------   

  printf("- get_4_isog:");

  LOAD_CACHE(get_4_isog(&P, A24plus, C24, coeff), 10);
  MEASURE_CYCLES(get_4_isog(&P, A24plus, C24, coeff), 100);
  printf("         #inst = %lld\n", diff_cycles);

#if DEBUG
  // A240 = 0x157E17F7452FEEE28513F3FC0D094E5804553AEE4985E4E14B4210744D6E56A0ED9F19\
            FC6DB24CE717994EEBC63381777CAF5EEFC9FC3
  // A241 = 0x67892D9C91F4AA901E0AFB3BF40707220C6E93401EEAFE2B331BBAEBA16FBE82A65732\
            AE5EB3B2D9087720D3719B21BB80B3B8B9FCD4
  // C240 = 0x14BD537DBF59F40092AFB850108ADA33A424CCF58D374867BC41F7B5DE3FECD7DF89D7\
            C398B09F727F073A78BC995D6E7C042E73385BE
  // C241 = 0x5E8B88344AC5425CBC6C0B959B6F5999175DB777E370B5AD02E712F9B3A1F2B8FD1BB4\
            C018A1F242B2FB85E3E76F2DC476AED1CE179A
  //  K00 = 0x22A8354DC084A682D125481FF6C85686F0C006E095959A079481734C159158B8499536\
            43208AFA9AC77EC8D6D55FE61EEC89DB461CEFC
  //  K01 = 0x80F5EA0863B2A3070A910F1CA39ADCA7C22483C42CB9E08A157966B25F8AC2E3ED8F95\
            FFF1EFF6668293A381241A8273C6A82513C710C
  //  K10 = 0x2AD8EDF8CAAD6881D9C5D356510B7D3C0C07519A4ED378A313DDDDF760CADB6EF5971E\
            D9E698FBEED35857AABBA6406E70E103D0C1E82
  //  K11 = 0x3D913DC94C3950985F5EBBAB3FA30BCA33C4E4A2175526A2D74B54B881C3663486E804\
            2D235A5BE71ED0B51FEFCBAC6D31784BB5A79B0
  //  K20 = 0x1CEE78006153A94DEDA123183F43512FBE2C8BF9E01AB5320D4D0FA7E42B5A8DA77813\
            C9F9B1F6439833414239DF20474DA9B4E7A6CFA
  //  K21 = 0x28E6F4A4F47897D56A0E47D0583958AD1C588338C6B34AB07427F6FD1E31F3365F6FBA\
            55BF604947167124D403D5C223505EC3E5A755E
  mpi64_print(" A240 = 0x", A24plus[0], NLMB64);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print(" A241 = 0x", A24plus[1], NLMB64);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print(" C240 = 0x", C24[0], NLMB64);
  memset(&C24[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print(" C241 = 0x", C24[1], NLMB64);
  memset(&C24[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K00 = 0x", coeff[0][0], NLMB64);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K01 = 0x", coeff[0][1], NLMB64);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K10 = 0x", coeff[1][0], NLMB64);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K11 = 0x", coeff[1][1], NLMB64);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K20 = 0x", coeff[2][0], NLMB64);
  memset(&coeff[2][0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K21 = 0x", coeff[2][1], NLMB64);
  memset(&coeff[2][1], 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------   

  printf("- eval_4_isog:");

  LOAD_CACHE(eval_4_isog(&P, coeff), 10);
  MEASURE_CYCLES(eval_4_isog(&P, coeff), 100);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // XP0 = 0x20304752113CC184F1CE286BDBB0BBBB3F435AA82D79B69F4EC6B8FCBDAC0769D733DAB\
           73590FE44FC9C8AB96D973B459D023CA13EFE9
  // XP1 = 0xB6F04F935671900A5A0F2E632AB8E2C0512370876CA555AF2C8A7AA0D9C3CECF320124F\
           C084D83A8A083F3CC0657A5B231EEA1DECFCA
  // ZP0 = 0x0
  // ZP1 = 0x0
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1
  // computation
  get_4_isog(&P, A24plus, C24, coeff);
  eval_4_isog(&P, coeff);
  // output 
  mpi64_print("  XP0 = 0x", P.X[0], NLMB64);
  memset(&P.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XP1 = 0x", P.X[1], NLMB64);
  memset(&P.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP0 = 0x", P.Z[0], NLMB64);
  memset(&P.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP1 = 0x", P.Z[1], NLMB64);
  memset(&P.Z[1], 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------   

  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1

  printf("- get_3_isog:");

  LOAD_CACHE(get_3_isog(&P, A24minus, A24plus, coeff), 10);
  MEASURE_CYCLES(get_3_isog(&P, A24minus, A24plus, coeff), 100);
  printf("         #inst = %lld\n", diff_cycles);

#if DEBUG
  // A-0 = 0x2C9C49309B1B27908BFF5C8F119286846FA4AA36315417B0AD4F79EEEC228AC2EE2566D\
           756E8CF072A33C9706B15EFDE21D77827B5CE7
  // A-1 = 0xC4B484894813216A5E2E195209EAEFD4BF775494D7D23FC62A151CDE3FE478AA7BBECE9\
           D212D58923B3FAE5BB5882F665D45BD7A5412
  // A+0 = 0x3A723CFD33DD353C42C2BE03BBAB61B3C685ECABC4518F5FB1B2A64803F6EE866654FA6\
           06BA2FA2F27FC997D9A3F8A110C5EDB946612
  // A+1 = 0x1C09DB1C485440FB099C6EC93D47559494B6390AAED7DB01CF49A3C1BB779C639F17563\
           6E2F35CC62C97909E9FBA2041E7872F10DEC96
  // K00 = 0x2AD8EDF8CAAD6881D9C5D356510B7D3C0C07519A4ED378A313DDDDF760CADB6EF5971ED\
           9E698FBEED35857AABBA6406E70E103D0C1E82
  // K01 = 0x3D913DC94C3950985F5EBBAB3FA30BCA33C4E4A2175526A2D74B54B881C3663486E8042\
           D235A5BE71ED0B51FEFCBAC6D31784BB5A79B0
  // K10 = 0x1CEE78006153A94DEDA123183F43512FBE2C8BF9E01AB5320D4D0FA7E42B5A8DA77813C\
           9F9B1F6439833414239DF20474DA9B4E7A6CFA
  // K11 = 0x28E6F4A4F47897D56A0E47D0583958AD1C588338C6B34AB07427F6FD1E31F3365F6FBA5\
           5BF604947167124D403D5C223505EC3E5A755E
  mpi64_print("  A-0 = 0x", A24minus[0], NLMB64);
  memset(&A24minus[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  A-1 = 0x", A24minus[1], NLMB64);
  memset(&A24minus[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  A+0 = 0x", A24plus[0], NLMB64);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  A+1 = 0x", A24plus[1], NLMB64);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K00 = 0x", coeff[0][0], NLMB64);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K01 = 0x", coeff[0][1], NLMB64);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K10 = 0x", coeff[1][0], NLMB64);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  K11 = 0x", coeff[1][1], NLMB64);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------   

  printf("- eval_3_isog:");

  LOAD_CACHE(eval_3_isog(&P, coeff), 10);
  MEASURE_CYCLES(eval_3_isog(&P, coeff), 100);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // XP0 = 0x3CEEE165BC12A5171255A6E87BA6D231F4DC09DC71FEA67416B4B7822E097272A217E4E\
           62E1F7EBD28794785A5426669E528FBB48D1F8
  // XP1 = 0x105654B8FD2A3A14E19B49623343104B3A8AB9272102D8B2F7101E27E666C27E35DB8F6\
           E8925887AF2087AF1CC3A45998168A61FF02A5
  // ZP0 = 0x0
  // ZP1 = 0x0
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1
  // computation
  get_3_isog(&P, A24minus, A24plus, coeff);
  eval_3_isog(&P, coeff);
  // output 
  mpi64_print("  XP0 = 0x", P.X[0], NLMB64);
  memset(&P.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XP1 = 0x", P.X[1], NLMB64);
  memset(&P.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP0 = 0x", P.Z[0], NLMB64);
  memset(&P.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP1 = 0x", P.Z[1], NLMB64);
  memset(&P.Z[1], 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------   

  printf("- xDBLADD:");

  LOAD_CACHE(xDBLADD(&P, &Q, XPQ, ZPQ, A24), 10);
  MEASURE_CYCLES(xDBLADD(&P, &Q, XPQ, ZPQ, A24), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XP0 = 0x191E5C0DCABCD87612E01FFB8946DB44D97B81EC18278EEED4E44D308ED1CF033DC2003\
           0DC52BEA77CA2E2BA551B2D3F58B2386D7FC8B
  // XP1 = 0xC662E62FEF6655FCA85F6A12F2F67B87F508BF6974E4EAA07401786BA7CFAEC5DCC28D6\
           D069FC141D869E6209153A9603399D963D2D8
  // ZP0 = 0x24AECA94BED31CFB7D9574B7344411721034F07FB0CCE8C017F817A0EED711C84EA9191\
           8990CC737A965979AAABB0F7D4429129503A8
  // ZP1 = 0x2120678E34DEC4CEC43C050EF6B695B93E85A2955AE248749D300D4F27B64FB258A3C10\
           52E7E16305444BE3FD39D5FB034F9809A6AE41
  // XQ0 = 0xDC035E152D6CA934ED158D953C5F34800E51E0C329F86F7A139E26C2421E968F158D258\
           B847D0CBCECC4F482E3B24FE355A96F1A0B75
  // XQ1 = 0x6489A9AE2EE4D753ACEB9675456416658F7A515485BE4E063CCD26E1CD90BA8D66AE5D8\
           8C50147432FC8C2E9039714820F77252DEAF9
  // ZQ0 = 0x2AC020A1FA0016DB6D000ED2D8E9736BA7697F4E638FA36DE1B4886D985C5A499B511AF\
           69612CC8861730A70EE090E4D685591618DA7B
  // ZQ1 = 0x166226A569EE6414116E69FC7908CA282C77FC302BE3CB08EFCD189C5242B7EC5407655\
           7172F6EB79BB6B460D07759B0749B6A3A97872
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1
  memcpy(&Q.X[0], &A_gen[4*NLMB64], sizeof(uint64_t)*NLMB64); // XRA0
  memcpy(&Q.X[1], &A_gen[5*NLMB64], sizeof(uint64_t)*NLMB64); // XRA1
  memcpy(&Q.Z[0], &B_gen[4*NLMB64], sizeof(uint64_t)*NLMB64); // XRB0
  memcpy(&Q.Z[1], &B_gen[5*NLMB64], sizeof(uint64_t)*NLMB64); // XRB1
  memcpy(&XPQ[0], &A_gen[       0], sizeof(uint64_t)*NLMB64); // XPA0
  memcpy(&XPQ[1], &A_gen[  NLMB64], sizeof(uint64_t)*NLMB64); // XPA1
  memcpy(&ZPQ[0], &A_gen[2*NLMB64], sizeof(uint64_t)*NLMB64); // XQA0
  memcpy(&ZPQ[1], &A_gen[3*NLMB64], sizeof(uint64_t)*NLMB64); // XQA1
  memcpy(&A24[0], mont_R, sizeof(uint64_t)*NLMB64);           //    1
  memset(&A24[1],      0, sizeof(uint64_t)*NLMB64);           //    0
  // computation
  xDBLADD(&P, &Q, XPQ, ZPQ, A24);
  // output
  mpi64_print("  XP0 = 0x", P.X[0], NLMB64);
  memset(&P.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XP1 = 0x", P.X[1], NLMB64);
  memset(&P.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP0 = 0x", P.Z[0], NLMB64);
  memset(&P.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZP1 = 0x", P.Z[1], NLMB64);
  memset(&P.Z[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XQ0 = 0x", Q.X[0], NLMB64);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  XQ1 = 0x", Q.X[1], NLMB64);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ0 = 0x", Q.Z[0], NLMB64);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB64);
  mpi64_print("  ZQ1 = 0x", Q.Z[1], NLMB64);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB64);
#endif

  printf("**************************************************************************\n");
}

void test_sidh()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  unsigned char skA[SECRETKEY_A_BYTES], pkA[CRYPTO_PUBLICKEYBYTES];
  unsigned char skB[SECRETKEY_B_BYTES], pkB[CRYPTO_PUBLICKEYBYTES];
  unsigned char ssA[FP2_ENCODED_BYTES], ssB[FP2_ENCODED_BYTES];

  printf("\n**************************************************************************\n");
  printf("SIDH KEY EXCHANGE:\n");

  randombytes(skA, SECRETKEY_A_BYTES);
  randombytes(skB, SECRETKEY_B_BYTES);

  printf("- Alice key gen:");

  LOAD_CACHE(EphemeralKeyGeneration_A(skA, pkA), 1);
  MEASURE_CYCLES(EphemeralKeyGeneration_A(skA, pkA), 1);
  printf("      #inst = %lld\n", diff_cycles);

  printf("- Bob   key gen:");

  LOAD_CACHE(EphemeralKeyGeneration_B(skB, pkB), 1);
  MEASURE_CYCLES(EphemeralKeyGeneration_B(skB, pkB), 1);
  printf("      #inst = %lld\n", diff_cycles);

  printf("- Alice shared sec:");

  LOAD_CACHE(EphemeralSecretAgreement_A(skA, pkB, ssA), 1);
  MEASURE_CYCLES(EphemeralSecretAgreement_A(skA, pkB, ssA), 1);
  printf("   #inst = %lld\n", diff_cycles);

  printf("- Bob   shared sec:");

  LOAD_CACHE(EphemeralSecretAgreement_B(skB, pkA, ssB), 1);
  MEASURE_CYCLES(EphemeralSecretAgreement_B(skB, pkA, ssB), 1);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG 
  printf("\nSKA: ");
  for (i = 0; i < SECRETKEY_A_BYTES; i++) printf("%02X", skA[i]);
  printf("\nSKB: ");
  for (i = 0; i < SECRETKEY_B_BYTES; i++) printf("%02X", skB[i]);
  printf("\nPKA: ");
  for (i = 0; i < CRYPTO_PUBLICKEYBYTES; i++) printf("%02X", pkA[i]);
  printf("\nPKB: ");
  for (i = 0; i < CRYPTO_PUBLICKEYBYTES; i++) printf("%02X", pkB[i]);
  printf("\nSSA: ");
  for (i = 0; i < FP2_ENCODED_BYTES; i++) printf("%02X", ssA[i]);
  printf("\nSSB: ");
  for (i = 0; i < FP2_ENCODED_BYTES; i++) printf("%02X", ssB[i]);
  printf("\n");
#endif

  printf("**************************************************************************\n");
}

void test_sike()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i, wrong = 0;

  unsigned char sk[CRYPTO_SECRETKEYBYTES] = { 0 };
  unsigned char pk[CRYPTO_PUBLICKEYBYTES] = { 0 };
  unsigned char ct[CRYPTO_CIPHERTEXTBYTES] = { 0 };
  unsigned char ss[CRYPTO_BYTES] = { 0 };
  unsigned char ss_[CRYPTO_BYTES] = { 0 };

  printf("\n**************************************************************************\n");
  printf("SIKE KEY ENCAPSULATION:\n");

  crypto_kem_keypair(pk, sk);
  crypto_kem_enc(ct, ss, pk);
  crypto_kem_dec(ss_, ct, sk);

  wrong = memcmp(ss, ss_, CRYPTO_BYTES);

  printf("- Shared secrets:");

  if (wrong == 0) printf("    \x1b[32m EQUAL!\x1b[0m\n");
  else            printf("    \x1b[31m NOT EQUAL!\x1b[0m\n");

  printf("- Keygen:");

  LOAD_CACHE(crypto_kem_keypair(pk, sk), 1);
  MEASURE_CYCLES(crypto_kem_keypair(pk, sk), 1);
  printf("             #inst = %lld\n", diff_cycles);

  printf("- Encaps:");

  LOAD_CACHE(crypto_kem_enc(ct, ss, pk), 1);
  MEASURE_CYCLES(crypto_kem_enc(ct, ss, pk), 1);
  printf("             #inst = %lld\n", diff_cycles);

  printf("- Decaps:");

  LOAD_CACHE(crypto_kem_dec(ss_, ct, sk), 1);
  MEASURE_CYCLES(crypto_kem_dec(ss_, ct, sk), 1);
  printf("             #inst = %lld\n", diff_cycles);

#if DEBUG 
  printf("\nSSA: ");
  for (i = 0; i < CRYPTO_BYTES; i++) printf("%02X", ss[i]);
  printf("\nSSB: ");
  for (i = 0; i < CRYPTO_BYTES; i++) printf("%02X", ss_[i]);
  printf("");
#endif 

  printf("**************************************************************************\n");
}

int main()
{
  test_fp();
  test_fpx();
  test_curve();
  test_sidh();
  test_sike();

  return 0;
}

#ifndef _GFPARITH_H
#define _GFPARITH_H

#include "share.h"
#include "config.h"

// -----------------------------------------------------------------------------

// (4x1)-way function prototypes
extern void gfp_mul_4x1w_v0(vec4 *r, const vec4 *a, const vec4 *b);
extern void gfp_mul_4x1w_v1(vec4 *r, const vec4 *a, const vec4 *b);
extern void gfp_mul_4x1w_v2(vec4 *r, const vec4 *a, const vec4 *b);
extern void gfp_sqr_4x1w_v0(vec4 *r, const vec4 *a);
extern void gfp_sqr_4x1w_v1(vec4 *r, const vec4 *a);
extern void gfp_sqr_4x1w_v2(vec4 *r, const vec4 *a);
extern void gfp_hadamard_4x1w_v0(vec4 *r, const vec4 *a, const vec4 *m);
extern void gfp_hadamard_4x1w_v1(vec4 *r, const vec4 *a, const vec4 *m);
extern void gfp_hadamard_4x1w_v2(vec4 *r, const vec4 *a, const vec4 *m);
extern void gfp_align_4x1w_v2(vec4 *r, const vec4 *a, const vec4 *m);
extern void gfp_premix_4x1w_v2(vec4 *r, vec4 *s, const vec4 *a, const vec4 *b, const vec4 *c, const vec4 *m);
extern void gfp_postmix_4x1w_v0(vec4 *r, const vec4 *a, const vec4 *b, const vec4 *m);
extern void gfp_postmix_4x1w_v2(vec4 *r, const vec4 *a, const vec4 *b, const vec4 *m);

// select what (4x1)-way prototypes to use
#define gfp_mul_4x1w(r, a, b)           gfp_mul_4x1w_v2(r, a, b)
#define gfp_sqr_4x1w(r, a)              gfp_sqr_4x1w_v2(r, a)
#define gfp_hadamard_4x1w(r, a)         gfp_hadamard_4x1w_v2(r, a, &m_ladder_1x4x1w[0])
#define gfp_align_4x1w(r, a)            gfp_align_4x1w_v2(r, a, &m_ladder_1x4x1w[1])
#define gfp_premix_4x1w(r, s, a, b, c)  gfp_premix_4x1w_v2(r, s, a, b, c, &m_ladder_1x4x1w[0])
#define gfp_postmix_4x1w(r, a, b)       gfp_postmix_4x1w_v2(r, a, b, &m_ladder_1x4x1w[0])

// -----------------------------------------------------------------------------

// (1x4)-way function prototypes
extern void gfp_mul_1x4w_v0(vec4 *r, const vec4 *a, const vec4 *b, const vec4 *m);
void gfp_inv_1x4w(vec4 *r, vec4 *a);

// select what (1x4)-way prototypes to use
#define gfp_mul_1x4w(r, a, b)           gfp_mul_1x4w_v0(r, a, b, m_mul_1x4w)
#define gfp_sqr_1x4w(r, a)              gfp_mul_1x4w_v0(r, a, a, m_mul_1x4w)

// -----------------------------------------------------------------------------

// masks and constants used in (1x4x1)-way implementation
static vec4 m_ladder_1x4x1w[2] = { { 1, 0, 3, 2 }, { 0, 1, 1, 0 } };
static vec4 m_mul_1x4w[10] = { 
  // masks for alignment in multiplication
  {  2,  0,  1,  0 }, {  1,  0,  2,  0 }, { -1, -1,  0,  0 }, 
  // masks for alignment in carry propagation 
  { 26, 25, 26, 25 }, { 25, 26, 25, 26 }, 
  { MASK26, MASK25, MASK26, MASK25 }, 
  { MASK25, MASK26, MASK25, MASK26 }, 
  // masks for final reduction 
  {  3,  0,  1,  2 }, { -1, -1, -1,  0 }, {  3, -1, -1, -1 } };

// -----------------------------------------------------------------------------

// (2x1)-way function prototypes 
extern void gfp_mul_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_mul_2x1w_v1(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_sqr_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_sqr_2x1w_v1(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_mul51_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_mul51_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_add_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b);
extern void gfp_add_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *b);
extern void gfp_sub_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_sub_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_sub_2x1w_v3(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_addsub_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_addsub_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_addsub_2x1w_v3(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_align_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_align_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_align_2x1w_v3(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_mix0_2x1w_v0(vec2 *r, vec2 *s, const vec2 *a, const vec2 *b);
extern void gfp_mix0_2x1w_v2(vec2 *r, vec2 *s, const vec2 *a, const vec2 *b);
extern void gfp_mix1_2x1w_v0(vec2 *r, const vec2 *a, const vec2 *b);
extern void gfp_mix1_2x1w_v2(vec2 *r, const vec2 *a, const vec2 *b);

// (2x1)-way function prototypes (ISE)
extern void gfp_mul_2x1w_v0_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_mul_2x1w_v1_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_sqr_2x1w_v0_ise(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_sqr_2x1w_v1_ise(vec2 *r, const vec2 *a, const vec2 *m);
extern void gfp_mul51_2x1w_v0_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_mul51_2x1w_v1_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
extern void gfp_align_2x1w_v0_ise(vec2 *r, const vec2 *a);
extern void gfp_align_2x1w_v2_ise(vec2 *r, const vec2 *a);
extern void gfp_mix0_2x1w_v2_ise(vec2 *r, vec2 *s, const vec2 *a, const vec2 *b);

// select what (2x1)-way prototypes to use
#if ISE 
#define gfp_mul_2x1w(r, a, b)           gfp_mul_2x1w_v1_ise(r, a, b, m_mul_2x1w)
#define gfp_sqr_2x1w(r, a)              gfp_sqr_2x1w_v1_ise(r, a, m_mul_2x1w)
#define gfp_mul51_2x1w(r, a, b)         gfp_mul51_2x1w_v1_ise(r, a, b, m_mul_2x1w) 
#define gfp_align_2x1w(r, a)            gfp_align_2x1w_v2_ise(r, a)
#define gfp_mix0_2x1w(r, s, a, b)       gfp_mix0_2x1w_v2_ise(r, s, a, b) 
#else
#define gfp_mul_2x1w(r, a, b)           gfp_mul_2x1w_v1(r, a, b, m_mul_2x1w)
#define gfp_sqr_2x1w(r, a)              gfp_sqr_2x1w_v1(r, a, m_mul_2x1w)
#define gfp_mul51_2x1w(r, a, b)         gfp_mul51_2x1w_v2(r, a, b, m_mul_2x1w)
#define gfp_align_2x1w(r, a)            gfp_align_2x1w_v3(r, a, m_prm_2x1w) 
#define gfp_mix0_2x1w(r, s, a, b)       gfp_mix0_2x1w_v2(r, s, a, b) 
#endif 
#define gfp_add_2x1w(r, a, b)           gfp_add_2x1w_v2(r, a, b)
#define gfp_sub_2x1w(r, a, b)           gfp_sub_2x1w_v3(r, a, b, c_2p_2x1w)
#define gfp_addsub_2x1w(r, a, b)        gfp_addsub_2x1w_v3(r, a, b, c_2p_2x1w)
#define gfp_mix1_2x1w(r, a, b)          gfp_mix1_2x1w_v2(r, a, b)

// -----------------------------------------------------------------------------

// (1x2)-way function prototypes
extern void gfp_mul_1x2w_v0(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
void gfp_inv_1x2w(vec2 *r, vec2 *a);

// (1x2)-way function prototypes (ISE)
extern void gfp_mul_1x2w_v0_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);

// select what (1x2)-way prototypes to use
#if ISE 
#define gfp_mul_1x2w(r, a, b)           gfp_mul_1x2w_v0_ise(r, a, b, m_mul_1x2w)
#else 
#define gfp_mul_1x2w(r, a, b)           gfp_mul_1x2w_v0(r, a, b, m_mul_1x2w)
#endif 
#define gfp_sqr_1x2w(r, a)              gfp_mul_1x2w_v0(r, a, a, m_mul_1x2w)

// -----------------------------------------------------------------------------

// masks and constants used in (1x2x1)-way implementation
static vec2 m_mul_2x1w[1] = { { MASK51, MASK51 } };
static vec2 m_prm_2x1w[5] = { { 1, 0 }, { 3, 2 }, { 5, 4 }, { 7, 6 }, { 9, 8 } };
static vec2 c_A24_2x1w[1] = { { (CONSTA-2)/4, (CONSTA+2)/4 } };
static vec2 c_2p_2x1w[5]  = { { LSLP51*2, LSLP51*2 }, { MASK51*2, MASK51*2 },
                              { MASK51*2, MASK51*2 }, { MASK51*2, MASK51*2 },
                              { MASK51*2, MASK51*2 } };
static vec2 m_mul_1x2w[2] = { { -1, 0 }, { MASK51, MASK51 } };


// -----------------------------------------------------------------------------

#endif

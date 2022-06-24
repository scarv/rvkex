#ifndef _MONCURVE_H
#define _MONCURVE_H

#include "share.h"
#include "gfparith.h"


void mon_ladder_step_1x4x1w(vec4 *x3z3x2z2, vec4 *z1x1_A);
void mon_mul_varbase_1x4x1w(uint32_t *r, const uint32_t *k, const uint32_t *x);
extern void mon_cswap_point_1x4x1w_v2(vec4 *x3z3x2z2, int swap, vec4 m); 

#define mon_cswap_point_1x4x1w(x3z3x2z2, swap) mon_cswap_point_1x4x1w_v2(x3z3x2z2, swap, m_cswap_1x4x1w)

static vec4 m_cswap_1x4x1w = { 2, 3, 0, 1 };

// -----------------------------------------------------------------------------

void mon_ladder_step_1x2x1w(vec2 *x3z3, vec2 *x2z2, const vec2 *z1x1);
void mon_mul_varbase_1x2x1w(uint64_t *r, const uint64_t *k, const uint64_t *x);
extern void mon_cswap_point_1x2x1w_v0(vec2 *x3z3, vec2 *x2z2, int swap); 
extern void mon_cswap_point_1x2x1w_v2(vec2 *x3z3, vec2 *x2z2, int swap); 

#define mon_cswap_point_1x2x1w mon_cswap_point_1x2x1w_v2

// -----------------------------------------------------------------------------

#endif

#ifndef _CURVE_H
#define _CURVE_H

#include "fpx.h"

typedef struct { f2elm_t X; f2elm_t Z; } point_proj;
typedef point_proj point_proj_t[1]; 

void copy_point(point_proj_t Q, const point_proj_t P);

void xDBL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);
void xDBL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);
void xDBL_v2(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);
void xTPL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus);
void xTPL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus);
void xTPL_v2(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus);
void xDBLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e);
void xTPLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e);
void get_4_isog_v0(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff);
void get_4_isog_v1(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff);
void eval_4_isog_v0(point_proj_t P, f2elm_t *coeff);
void eval_4_isog_v1(point_proj_t P, f2elm_t *coeff);
void get_3_isog_v0(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);
void get_3_isog_v1(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);
void eval_3_isog_v0(point_proj_t Q, const f2elm_t *coeff);
void eval_3_isog_v1(point_proj_t Q, const f2elm_t *coeff);
void xDBLADD_v0(point_proj_t P, point_proj_t Q, const f2elm_t XPQ, const f2elm_t ZPQ, const f2elm_t A24);
void xDBLADD_v1(point_proj_t P, point_proj_t Q, const f2elm_t XPQ, const f2elm_t ZPQ, const f2elm_t A24);

void inv_3_way_v1(f2elm_t r1, f2elm_t r2, f2elm_t r3);
void get_A_v1(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xR, f2elm_t A);
void j_inv_v1(const f2elm_t A, const f2elm_t C, f2elm_t jinv);

void LADDER3PT(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xPQ, const uint64_t* m, const unsigned int AliceOrBob, point_proj_t R, const f2elm_t A);

#define xDBL        xDBL_v1
#define xTPL        xTPL_v1
#define get_4_isog  get_4_isog_v1
#define eval_4_isog eval_4_isog_v1
#define get_3_isog  get_3_isog_v1
#define eval_3_isog eval_3_isog_v1
#define xDBLADD     xDBLADD_v1
#define inv_3_way   inv_3_way_v1
#define get_A       get_A_v1
#define j_inv       j_inv_v1

#endif

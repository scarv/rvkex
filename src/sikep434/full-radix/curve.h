#ifndef _CURVE_H
#define _CURVE_H

#include "fpx.h"

typedef struct { f2elm_t X; f2elm_t Z; } point_proj;
typedef point_proj point_proj_t[1]; 

void copy_point(point_proj_t Q, const point_proj_t P);

void xDBL(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);
void xTPL(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus);
void xDBLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e);
void xTPLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e);
void get_4_isog(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff);
void eval_4_isog(point_proj_t P, f2elm_t *coeff);
void get_3_isog(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);
void eval_3_isog(point_proj_t Q, const f2elm_t *coeff);
void xDBLADD(point_proj_t P, point_proj_t Q, const f2elm_t XPQ, const f2elm_t ZPQ, const f2elm_t A24);

void inv_3_way(f2elm_t r1, f2elm_t r2, f2elm_t r3);
void get_A(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xR, f2elm_t A);
void j_inv(const f2elm_t A, const f2elm_t C, f2elm_t jinv);

void LADDER3PT(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xPQ, const uint64_t* m, const unsigned int AliceOrBob, point_proj_t R, const f2elm_t A);

#endif

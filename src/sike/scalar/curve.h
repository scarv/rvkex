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
void get_4_isog_v0(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff);
void get_4_isog_v1(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff);
void eval_4_isog_v0(point_proj_t P, f2elm_t *coeff);
void eval_4_isog_v1(point_proj_t P, f2elm_t *coeff);
void get_3_isog_v0(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);
void get_3_isog_v1(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);
void eval_3_isog_v0(point_proj_t Q, const f2elm_t *coeff);
void eval_3_isog_v1(point_proj_t Q, const f2elm_t *coeff);

#define xDBL        xDBL_v1
#define xTPL        xTPL_v1
#define get_4_isog  get_4_isog_v1
#define eval_4_isog eval_4_isog_v1
#define get_3_isog  get_3_isog_v1
#define eval_3_isog eval_3_isog_v1

#endif

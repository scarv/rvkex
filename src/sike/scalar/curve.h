#ifndef _CURVE_H
#define _CURVE_H

#include "fpx.h"

typedef struct { f2elm_t X; f2elm_t Z; } point_proj;
typedef point_proj point_proj_t[1]; 

void pointcopy(point_proj_t Q, const point_proj_t P);

void xDBL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);
void xDBL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);

#endif

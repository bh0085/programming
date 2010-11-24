/*
 *  CMath.h
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef CMATH_H
#define CMATH_H
#include <gsl/gsl_rng.h>

#ifdef __cplusplus
extern "C" {
#endif

void fvAddNoise(float * vector, unsigned size, float noise_abs,gsl_rng * r);
void fvnMakeSpiral(float * vector, unsigned size, unsigned n_dims,  float radius, float turns);
void fvClear(float * vector, unsigned size);

#ifdef __cplusplus
}
#endif
	
#endif
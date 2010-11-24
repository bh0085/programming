/*
 *  CMath.c
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "CMath.h"
#include <gsl/gsl_randist.h>
#include <gsl/gsl_math.h>

void fvAddNoise(float * vector, unsigned size, float noise_abs,gsl_rng * r){
	for ( int i = 0 ; i < size ; i++){
		vector[i] += gsl_ran_gaussian(r,noise_abs);
	}
}
void fvClear(float * vector, unsigned size){
	for ( int i = 0 ; i < size ; i++){
		vector[i] = 0.0;
	}
}
void fvnMakeSpiral(float * vector, unsigned size, unsigned n_dims,  float radius, float turns){
	//embeds two dimensional spiral in n dimensions
	for (int i = 0 ; i < size ; i++){
		unsigned pos = n_dims * i;
		float theta = (float)i / size * 2 * M_PI * turns;
		float r = (float)i / size * radius;
		float xval = cos(theta)*r;
		float yval = sin(theta)*r;
		for  (int j = 0 ; j < n_dims ; j++){
			if (j==0) vector[pos + j] = xval; else
				if (j==1) vector[pos +j] = yval; else
					vector[pos +j] = 0.0;
		}
	}
}

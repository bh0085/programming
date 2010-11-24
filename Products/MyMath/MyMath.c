/*
 *  MyMath.c
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "MyMath.h"
#include "stdlib.h"
#include <gsl/gsl_randist.h>
#include <gsl/gsl_math.h>

extern void makeDistribution(float probabilities[], float distribution[], unsigned size){
	float sum = 0;
	for(int i = 0 ; i < size ; i++){
		sum+=probabilities[i];
		distribution[i] = sum;
	}
	for(int i = 0 ; i < size ; i++){
		distribution[i]/=sum;
	}
};
extern unsigned stochasticIDX(float distribution[], unsigned size){
	float r = ((float) rand()) / RAND_MAX;
	for(int i = 0 ; i < size ; i ++){
		if(distribution[i] > r ) return i;
	}
	return size -1;
};


void fvAddNoise(float * vector, unsigned size, float noise_abs,gsl_rng * r){
	for ( int i = 0 ; i < size ; i++){
		vector[i] += gsl_ran_gaussian(r,noise_abs);
	}
}
void fvnCenter(float * vector, unsigned size, unsigned n_dims){
	for(int j = 0 ; j < n_dims ; j++){
		float sum = 0;
		for(int i = 0 ; i < size ; i++){
			unsigned pos = n_dims * i + j;
			sum += vector[pos];
		}
		sum/=size;
		for(int i = 0 ; i < size ; i++){
			unsigned pos = n_dims * i + j;
			vector[pos] -= sum;			
		}
	}
}
void fvClear(float * vector, unsigned size){
	for ( int i = 0 ; i < size ; i++){
		vector[i] = 0.0;
	}
}
void fvnMakeSpiral(float * vector, unsigned size, unsigned n_dims, float innerradius, float outerradius, float turns){
	//embeds two dimensional spiral in n dimensions
	for (int i = 0 ; i < size ; i++){
		unsigned pos = n_dims * i;
		float theta = (float)i / size * 2 * M_PI * turns;
		float r = (float)i / size * (outerradius -innerradius) + innerradius;
		float xval = cos(theta)*r;
		float yval = sin(theta)*r;
		for  (int j = 0 ; j < n_dims ; j++){
			if (j==0) vector[pos + j] = xval; else
				if (j==1) vector[pos +j] = yval; else
					vector[pos +j] = 0.0;
		}
	}
}

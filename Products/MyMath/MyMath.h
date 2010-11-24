/*
 *  MyMath.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef MYMATH_H
#define MYMATH_H

#ifdef __cplusplus
extern "C" {
#endif
	#include <gsl/gsl_rng.h>
	//Distribution Functions
		
	//Generate a distribution so that the width of each bin reflects 
	//the relative probability of each bin in the provided distribution.
	void makeDistribution(float probabilities[], float distribution[], unsigned size);

	//generate a bin index at random from a distribution
	unsigned stochasticIDX(float distribution[], unsigned size);

	//Vector Manipulation Classes
	
	//Add gaussian noise to a vector using a random number generator.
	void fvAddNoise(float * vector, unsigned size, float noise_abs,gsl_rng * r);
	
	//Make a spiral in a multidimensional array. 
	void fvnMakeSpiral(float * vector, unsigned size, unsigned n_dims, float innerradius, float outerradius, float turns);
	
	//Clear an array.
	void fvClear(float * vector, unsigned size);	
	//Center an array.
	void fvnCenter(float * vector, unsigned size, unsigned n_dims);

#ifdef __cplusplus
}
#endif

#endif

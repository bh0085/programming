//
//  main.m
//  SDE
//
//  Created by Benjamin Holmes on 9/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_rng.h>
#include <math.h>
#include "MyMath.h"
#include "MyKNN.h"
#include "svdlib.h"
#include "MySparse.h"

int main(int argc, char *argv[])
{	
	const gsl_rng_type * T;
	gsl_rng_env_setup();
	
	
	T = gsl_rng_default;
	gsl_rng * r = gsl_rng_alloc (T);
	gsl_rng_set (r, time( NULL));

	
	unsigned data_dims = 4;
	unsigned data_size = 1000;
	unsigned data_elements = data_dims * data_size;
	float spiral_rad = 20;
	float spiral_turns = 1.22;
	unsigned ndd = data_size * data_size;
	
	float data[data_dims * data_size];
	fvClear(data, data_elements);
	fvnMakeSpiral(data, data_size, data_dims, spiral_rad, spiral_rad*2 , spiral_turns);
	fvAddNoise(data, data_elements, .25, r);
	
	unsigned nk = 5;
	unsigned KNN[ndd];
	fvnGetKNN(data_dims, data_size, data, nk, KNN);
	
	double smallArr[4] = {2,.25,.25,1.0};
	SMat S = sparseFromArray(2, 2, smallArr);
	ESys E = sparseSDEig(S, 2);
	printf("values: %f, %f",E->vals[0],E->vals[1]);
	freeESys(E);
	
	return NSApplicationMain(argc,  (const char **) argv);
	
}

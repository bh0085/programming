/*
 *  Kohonen1D.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "Kohonen1D.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "GLIDL.h"
#include "MyCIDL.h"
#include <OpenGL/OpenGL.h>

static float cof_ii = .4;
static float cof_posfracsq = .5;
static float cof_ij = -.4;
static bool hat = false;

static float alphaInit = .2;
static float neighborhood_init_square_radius = 10000.0;

Kohonen1D::Kohonen1D(){
	metric_xmax = 100.0f;
	metric_xmin = 0.0f;
	metric_xwidth = metric_xmax - metric_xmin;
	nRadSq = neighborhood_init_square_radius;
	alphaCurrent = alphaInit;
	nSqMin = 75;
	
	hat_width_cof = .25;
	brim_sq_width = 5.0;
	brim_sq_mag = -.2;
	
	expectedRuns = 10000;
	nDecay = expf( logf(.5) /( expectedRuns) );
	aDecay = expf( logf(.5) / expectedRuns );
	
	doTanh =false;
	tanhSlope = 1000.0; 
	
	
	for ( int i = 0 ; i < K1_N_NEURONS ; i++){
		units[i].x =metric_xmin + i*(metric_xwidth)/K1_N_NEURONS;
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			units[i].m[j] = ((float) (rand() % K1_START_RES)) / K1_START_RES *K1_START_MAXABS;
		}

	}
};
void Kohonen1D::initToSquare(){
	for (int i = 0 ; i < K1_N_INPUTS ; i++){
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			inputs[i][j] = ((float)(rand() % K1_INPUT_RES))/ K1_INPUT_RES * K1_INPUT_RADIUS -(K1_INPUT_RADIUS) /2;
		}
	}
};
void Kohonen1D::initToCircle(){
	for(int i = 0 ; i < K1_N_INPUTS ; i++){
		float vec[K1_N_INPUTS];
		float mag = 0.0;
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			vec[j] = ( ((float)(rand() % K1_INPUT_RES)) / K1_INPUT_RES)  - .5;
			mag += (pow(vec[j],2));
		}
		float radius = (((float)(rand() % K1_INPUT_RES)) /K1_INPUT_RES) * (K1_INPUT_RADIUS);
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			inputs[i][j] = vec[j]/sqrt(mag) * radius;
		}
	}
};
void Kohonen1D::initToTube(){
	for (int i = 0 ; i < K1_N_INPUTS ; i++){
		float vec[K1_INPUT_DIMENSION];
		while(true){
			float mag = 0;
			for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
				vec[j] = (((float)(rand() % K1_INPUT_RES))/ K1_INPUT_RES * K1_INPUT_RADIUS -(K1_INPUT_RADIUS) /2)*2;
				mag += pow(vec[j],2);
			}
			if( (sqrt(mag) < K1_INPUT_RADIUS) && (sqrt(mag) > (K1_INPUT_RADIUS / 5))){
				break;
			}
			
		}
			
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			inputs[i][j] = vec[j];
		}
	}		
};

void Kohonen1D::initWithInputs(){

};

void Kohonen1D::iterate(){
	alphaCurrent*=aDecay;
	nRadSq*=nDecay;
	if(nRadSq < nSqMin){nRadSq = nSqMin;}
	float hat_width = nRadSq * hat_width_cof;
	
	float * input = inputs[rand() % K1_N_INPUTS];
	float maxVal = 0;
	int maxIDX = -1;
	for(int i = 0 ; i < K1_N_NEURONS ; i ++){
		float thisVal = 0.0;
		float norm = 0.0;
		for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
			thisVal+=input[j]*units[i].m[j];
			norm += pow(units[i].m[j],2);
		}
		thisVal /= sqrtf(norm);
		
		if(maxIDX == -1 || thisVal > maxVal){
			maxVal = thisVal;
			maxIDX = i;
		}
	}
	
	
	for(int i = 0 ; i < K1_N_NEURONS; i++){
		float distSq = pow(units[maxIDX].x - units[i].x,2);
		if(distSq <= nRadSq){
			float cof;
			if(hat){
				cof = expf(-((distSq / hat_width))) + brim_sq_mag * expf(-((distSq / (hat_width*brim_sq_width))));
			} else {
				if(distSq/nRadSq < cof_posfracsq) cof = cof_ii;
				else cof = cof_ij;
			}
			for(int j = 0 ; j < K1_INPUT_DIMENSION ; j++){
				if(doTanh){
					units[i].m[j] +=alphaCurrent * cof*tanh( tanhSlope * (input[j] - units[i].m[j]) );
				} else {
					units[i].m[j] += alphaCurrent * cof*(input[j] - units[i].m[j]) ;
			
				}
			}
		}
	}
	
};
void Kohonen1D::draw(){
	if(K1_INPUT_DIMENSION == 2){
		float xs[K1_N_NEURONS];
		float ys[K1_N_NEURONS];
		for(int i = 0 ; i < K1_N_NEURONS ; i++){
			xs[i] = units[i].m[0];
			ys[i] = units[i].m[1];

			//printf("x: %f\n",xs[i]);
		}
		float ixs[K1_N_INPUTS];
		float iys[K1_N_INPUTS];
		for(int i = 0 ; i < K1_N_INPUTS ; i++){
			ixs[i] = inputs[i][0];
			iys[i] = inputs[i][1];
		}
		float bounds[6] = {-K1_INPUT_RADIUS,K1_INPUT_RADIUS,-K1_INPUT_RADIUS,K1_INPUT_RADIUS,-10,10};
		GLIDLClear();
		GLIDLSetViewBoundsWithMargin(bounds, .5) ;
		GLIDLSetPSym(-1);
		oplot2f(xs, ys, K1_N_NEURONS);
		GLIDLSetPSym(0);
		glColor4f(1,1,1,.1);
		oplot2f(ixs,iys,K1_N_INPUTS);
		glColor4f(1,1,1,1);
		GLIDLFlushBuffer();
		

	}
}
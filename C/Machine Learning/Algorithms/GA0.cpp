/*
 *  Genetic Algorithm.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GA0.h"
#include <math.h>
#include <OpenGL/OpenGL.h>
#include "GLIDL.h"
#include "MyCIDL.h"
#include "MyMath.h"
#include <stdlib.h>
#include <iostream>
#include "GAGD3L.h"
#include <algorithm>


#define MUTATION_RATE .99
#define CROSS_FREQ .9
#define TEMPERATURE .1

#define NSAMPLES 5

static const unsigned DEFAULT_POPULATION = 50;
GA0::GA0(){
	popSize = DEFAULT_POPULATION;
	init();
}
GA0::GA0(unsigned popsize){
	popSize = popsize;
	init();
};
void GA0::init(){
	fitnessFunction = &GA0::GAGD3LFit;
	if(popSize > GA0_MAXGENES){
		printf("population size too large");
		exit(EXIT_FAILURE);
		}
	unsigned nHidden = GAGD3L::nHidden;
	geneLength =NSAMPLES * nHidden;
	
	for(int i = 0 ; i < popSize ; i++){
		genePool[i].initWithLength(geneLength);
		genePool[i].randomize();
	}

	
}

void GA0::select(){
	float fitmin;
	float fitmax;
	float fitnessesScaled[popSize];
	for(int i = 0 ; i < popSize ; i++){
		fitnesses[i]  = (this->*fitnessFunction)(geneMemory[i]);
		fitnessesScaled[i] = fitnesses[i];
		if(i ==0 || fitnesses[i] < fitmin)fitmin = fitnesses[i];
		if(i ==0 || fitnesses[i] > fitmax)fitmax = fitnesses[i];
	}	
	
	addConstantToArrayf(fitnessesScaled, -1*fitmin +TEMPERATURE*(fitmax - fitmin), popSize);
	float dist[popSize];
	makeDistribution(fitnessesScaled, dist, popSize);
	
	for(int i = 0 ; i < popSize ; i++){
		unsigned idx = stochasticIDX(dist, popSize);
		genePool[i] = geneMemory[idx];
	}
}
void GA0::GAGDSelect(float * columnErrors){
	float fitmin;
	float fitmax;
	float fitnessesScaled[popSize];
	for(int i = 0 ; i < popSize ; i++){
		fitnesses[i]  = (this->*fitnessFunction)(geneMemory[i]);
		for(int j = 0 ; j<NSAMPLES; j++){
			columnErrors[i + j * popSize] = GAGD3LColumnErrors[j];
		}
		fitnessesScaled[i] = fitnesses[i];
		if(i ==0 || fitnesses[i] < fitmin)fitmin = fitnesses[i];
		if(i ==0 || fitnesses[i] > fitmax)fitmax = fitnesses[i];
	}	
	
	addConstantToArrayf(fitnessesScaled, -1*fitmin +TEMPERATURE*(fitmax - fitmin), popSize);
	float dist[popSize];
	makeDistribution(fitnessesScaled, dist, popSize);
	
	for(int i = 0 ; i < popSize ; i++){
		unsigned idx = stochasticIDX(dist, popSize);
		genePool[i] = geneMemory[idx];
	}	
}

void GA0::iterate(){
	for(int i = 0 ; i < popSize ; i++){
		geneMemory[i] = genePool[i];
	}
	float columnErrors[popSize * NSAMPLES ];
	GAGDSelect(columnErrors);
	//select();
	for(int i = 0 ; i < popSize ; i++){
		float r2 = ((float)(rand() %10000))/10000;
		if(r2 < MUTATION_RATE){
			genePool[i].mutate();
		}	
		if(i % 2 == 1){
			float r = ((float)(rand() % 10000))/10000;
			if(r < CROSS_FREQ){
				unsigned crossPoint = rand() % geneLength;
				Gene::singleCross(genePool[i-1],genePool[i],crossPoint);
			}
		}
	}
}
void GA0::draw(){
	GLIDLClear();
	float bounds[6] = {0,1,0,1,-10,10};
	GLIDLSetViewBounds(bounds);
	
	
	float fitnessesScaled[popSize];
	float fitmin;
	float fitmax;
	for(int i = 0 ; i < popSize ; i++){
		fitnessesScaled[i]  = fitnesses[i];
		if(i ==0 || fitnesses[i] < fitmin)fitmin = fitnesses[i];
		if(i ==0 || fitnesses[i] > fitmax)fitmax = fitnesses[i];
	}	
	std::sort(fitnessesScaled,fitnessesScaled+popSize);
	
	glColor4f(1,1,1,.3);
	addConstantToArrayf(fitnessesScaled, -1*fitmin +.1*(fitmax - fitmin), popSize);
	scaleArrayf(fitnessesScaled, 1/(.1+(fitmax - fitmin)), popSize);
	int dimSize = (int)sqrt(popSize);
	for(int i = 0 ; i < popSize ; i++){
		float x = ((float)(i % dimSize) + .5)/dimSize;
		float y = ((float)(i / dimSize) + .5)/dimSize;
		plots_screen_circle(x,y, fitnessesScaled[i]*100);
	}	
	GLIDLFlushBuffer();
	

	/*
	for(int i = 0 ; i < popSize ; i++){
		float x = (((float)(i)) / popSize);

		plots_screen_circle(geneMemory[i].nByteFraction(0, 2),fitnesses[i], fitnesses[i]*100);
	}
	 */
	
	
	drawingTestRun();
	

	 


	
}

//in this section, multiple fitness functions will be defined according to the function:
// float func(Gene g);

void GA0::setFitnessFunction(float (GA0::*newFunc)(const Gene& g)){
	fitnessFunction = newFunc;
}
float GA0::identityFitness(const Gene& g){
	return 1.0;
}
float GA0:: xSin1OverX(const Gene& g){
	float xfloat = g.nByteFraction(0, 2)*.4 + .05;
	float yval = xfloat*sin(1/xfloat);
	return exp(-pow(2*(1+yval),2));
}

void GA0::drawingTestRun(){

	int nHidden = GAGD3L::nHidden ;
	int nSamples = NSAMPLES;
	int nRuns =100;
	int nTests = nSamples;
	float xin[nSamples];
	float yout[nSamples];
	for(int i = 0 ; i < nSamples ; i ++){
		xin[i] = ((float)i)/nSamples *.4 + .05;
		yout[i] = xin[i]*sin(1/xin[i]);
	}
	
	NN = GAGD3L();
	int winxy1[2] = {500,400};
	Gene g = genePool[0];
	windowAtXY(3,winxy1);
	GLIDLClear();
	float bounds1[6] = {0,nHidden,-1,10,-10,10};
	GLIDLSetViewBounds(bounds1);
	glColor4f(1,1,1,.6);
	int jmax = 5;//nSamples;
	for(int i = 0 ; i < nRuns ; i++){
		for(int j = 0 ; j<jmax; j++){
			unsigned hTargets[nHidden];
			g.matrixExtractColumnToInt(hTargets, j, nHidden);
			
			NN.train(&xin[j],hTargets, &yout[j]);
			/*
			if(NN.l2vals[0] )printf("1  ");
			if(NN.l2vals[0] )printf("2  \n");
			 */
			//NN.train(&xin[j],hTargets, &yout[j]);
			
			if(i  == nRuns - 1) {
				//NN.getOutput(&xin[j], &yout[j]);
				//NN.train(&xin[j],hTargets, &yout[j]);
			
				for(int k = 0 ; k < nHidden ; k++){
					glColor4f(1, 0, 1, .6);
					if( NN.l2vals[k] ) plots_screen_circle(k, j, 8);
					glColor4f(1, 1, 1, .6);
					if (hTargets[k] ) plots_screen_circle(k, j, 4);
				}
				NN.getOutput(&xin[j], &yout[j]);

				for(int k = 0 ; k < nHidden ; k++){
					glColor4f(0, 1, 1, .6);
					if( NN.l2vals[k] ) plots_screen_circle(k, j, 8);

				}
			}
			
			/*glColor4f(0, 0, 1, 1);
			plots_screen_circle(xin[j], yout[j], 3);
			plots_screen_circle(xin[j], NN.getVal(), 10);
			 */
			

		}
	}
		for(int j = 0 ; j < 0; j++){
			unsigned hTargets[nHidden];
			g.matrixExtractColumnToInt(hTargets, j, nHidden);
			NN.getOutput(&xin[j], &yout[j]);
			
				
				if(1){
					for(int k = 0 ; k < nHidden ; k++){
						glColor4f(1, 0, 1, .6);
						if( NN.l2vals[k] ) plots_screen_circle(k, j, 8);
						glColor4f(1, 1, 1, .6);
						if (hTargets[k] ) plots_screen_circle(k, j, 4);
					}
				
			}
			
			/*glColor4f(0, 0, 1, 1);
			 plots_screen_circle(xin[j], yout[j], 3);
			 plots_screen_circle(xin[j], NN.getVal(), 10);
			 */
			
			
		}
	GLIDLFlushBuffer();
	/*
	float bounds5[6] = {0,20,-1.5,1.5,-10,10};
	GLIDLSetViewBounds(bounds5);
	NN.drawHiddenWeights();
	glColor4f(1, 0, 0, 1);
	NN.drawOutputWeights();
	 */
	
	
	for(int i = 0 ; i < nSamples ; i++){
		GAGD3LColumnErrors[i] = NN.getError(&xin[i],&yout[i]);
	}
	
	float error = 0;
	for(int i = 0 ; i < nTests ; i ++){
		float x = ((float)i)/nTests *.4 + .05;
		float y = x * sin(1/x);
		error += NN.getError(&x,&y);
	}
	error /= nTests;
	int winxy[2] = {100,400};
	windowAtXY(9,winxy);
	GLIDLClear();
	GLIDLSetPSym(-1);
	GLIDLSetScanWidth(60);
	float bounds2[6] = {.0,.8,-.8,.8,-10,10};
	GLIDLSetViewBounds(bounds2);
	glColor4f(1,1,1,.6);
	
	for(int j = 0 ; j<jmax; j++){
		unsigned hTargets[nHidden];
		g.matrixExtractColumnToInt(hTargets, j, nHidden);
		NN.train(&xin[j],hTargets, &yout[j]);
		if(1){
			for(int k = 0 ; k < nHidden ; k++){
				plots_screen_circle(xin[j],NN.getVal(), 4);		
			}
		}
	}	
	
	for(int i = 0 ; i < nTests ; i ++){
		float x = ((float)i)/nTests *.4 + .05;
		float ytest = x*sin(1/x);
		float y;
		NN.getOutput(&x,&y);
		plots_screen_circle(x,y, 10);		
		plots_screen_circle(x,ytest, 10);		
	}
	GLIDLFlushBuffer();

	
}

float GA0:: GAGD3LFit(const Gene& g){
	int nHidden = GAGD3L::nHidden;
	int nSamples = NSAMPLES;
	int nRuns = 100;
	int nTests = 25;
	float xin[nSamples];
	float yout[nSamples];
	for(int i = 0 ; i < nSamples ; i ++){
		xin[i] = ((float)i)/nSamples *.4 + .05;
		yout[i] = xin[i]*sin(1/xin[i]);
	}
	
	NN = GAGD3L();
	for(int i = 0 ; i < nRuns ; i++){
		for(int j = 0 ; j<nSamples; j++){
			unsigned hTargets[nHidden];
			g.matrixExtractColumnToInt(hTargets, j, nHidden);
			NN.train(&xin[j],hTargets, &yout[j]);
		}
	}

	for(int i = 0 ; i < nSamples ; i++){
		GAGD3LColumnErrors[i] = NN.getError(&xin[i],&yout[i]);
	}
		
	float error = 0;
	for(int i = 0 ; i < nTests ; i ++){
		float x = ((float)i)/nTests *.4 + .05;
		float y = x * sin(1/x);
		error += NN.getError(&x,&y);
	}
	error /= nTests;
	return -error;
}
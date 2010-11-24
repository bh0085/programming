/*
 *  Genetic Algorithm.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef GA0_H
#define GA0_H
#include "Gene.h"
#include "GAGD3L.h"
#define GA0_MAXGENES 1000
#define GAGD3L_MAX_COLUMNS 100
class GA0{
public:
	GA0::GA0();
	GA0(unsigned popsize);
	void iterate();
	void select();
	void GAGDSelect(float *  columnErrors);
	void draw();
	void drawingTestRun();
	void GA0::setFitnessFunction(float (GA0::*newFunc)(const Gene& g));
	float identityFitness(const Gene& g);
	float xSin1OverX(const Gene& g);
	float GAGD3LFit(const Gene& g);

	
protected:
	GAGD3L NN;
	float GAGD3LColumnErrors[GAGD3L_MAX_COLUMNS];
	float fitnesses[GA0_MAXGENES];
	float (GA0::*fitnessFunction) (const Gene& g);
	unsigned geneLength;
	unsigned popSize;
	Gene genePool[GA0_MAXGENES];
	Gene geneMemory[GA0_MAXGENES];
	float fVal(Gene& g);
	void * metricMethod;
	void init();
};
#endif
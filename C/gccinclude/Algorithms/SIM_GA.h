/*
 *  SIM_GA.h
 *  Algorithms
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef SIM_GA_H
#define SIM_GA_H
#include "Gene.h"

class SIM_GA{
public:
	Gene ** genes;
	float * fitnesses;
	int popSize;
	int geneSize;
	
	//this class is not yet copy safe... but it doesn't really need to be.
	//do not copy SIM_GA!
	
	SIM_GA();
	~SIM_GA();
	
	//initializes a random population
	void init(unsigned pSize, unsigned geneSize);

	//called by the external routine that will compute gene fitnesses one by one
	Gene * getGene(unsigned index);
	
	//set a gene fitness so that selection may be performed
	void setFitness(unsigned index,float fitness);		
	
	//selects genes based on their fitnesses
	void select(unsigned selectionType);
	
	//a few extra maintenance methods
	void set_selection_temperature(float temp);
	
private:
	void copySelect();
	void proportionalSelect();
	void proportionalSelect_thermal();

	
	float selection_temperature;

};
#endif
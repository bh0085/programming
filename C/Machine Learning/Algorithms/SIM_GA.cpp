/*
 *  SIM_GA.cpp
 *  Algorithms
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "SIM_GA.h"
#include "stdlib.h"
#include "gsl/gsl_vector_float.h"
#include "MyMath.h"
#include "MyCIDL.h"

#define TEMPERATURE_DEFAULT 1

SIM_GA::SIM_GA(){};
SIM_GA::~SIM_GA(){
	//free all dynamically allocated memory.
	if (genes != NULL) {delete [] genes; };
	if (fitnesses != NULL) { free(fitnesses); };
};

//initializes a random population
void SIM_GA::init(unsigned pSize, unsigned gSize){
	selection_temperature = TEMPERATURE_DEFAULT;
	popSize = pSize;
	geneSize = gSize;

	genes = (Gene **)malloc(sizeof(Gene *)*popSize);
	for(int i = 0; i < popSize; i++){
		genes[i] = new Gene(geneSize);
		genes[i]->randomize();
	};
	fitnesses = (float *)malloc(sizeof(float) * geneSize);
};

//called by the external routine that will compute gene fitnesses one by one
Gene * SIM_GA::getGene(unsigned index){
	return genes[index];
};

//set a gene fitness so that selection may be performed
void SIM_GA::setFitness(unsigned index, float fitness){
	fitnesses[index] = fitness;
};		

//selects genes based on their fitnesses
void SIM_GA::select(unsigned selectionType){
	
	//selection type 0 simply copies over the old genes into the new pool
	switch (selectionType) {
		case 0:
			proportionalSelect();
			break;
		case 1:
			proportionalSelect_thermal();
			break;
		default:
			copySelect();
			break;
	}
	
	for (unsigned i = 0 ; i < popSize ; i++){
		fitnesses[i] = 0;
	}
	
};

//maintenance methods
void SIM_GA::set_selection_temperature(float temp){
	selection_temperature = temp;
};

void SIM_GA::copySelect(){
	Gene ** newGenes = (Gene **)malloc(sizeof(Gene *)*popSize);
	for( unsigned i = 0 ; i < popSize ; i++){
		newGenes[i] = new Gene(*(genes[i]));
	}
	delete [] genes;
	genes = newGenes;	
}
void SIM_GA::proportionalSelect(){

	float dist[popSize];
	makeDistribution(fitnesses, dist, popSize);
	
	Gene ** newGenes = (Gene **)malloc(sizeof(Gene *)*popSize);	
	for(int i = 0 ; i < popSize ; i++){
		unsigned idx = stochasticIDX(dist, popSize);
		newGenes[i] = new Gene(*(genes[idx]));
	}	
	delete [] genes;
	genes = newGenes;	

}
void SIM_GA::proportionalSelect_thermal(){
	float fitmin;
	float fitmax;
	float fitnessesScaled[popSize];
	gsl_vector_float * vec = gsl_vector_float_calloc(popSize);
	for (int i = 0 ; i < popSize ; i++){
		gsl_vector_float_set(vec, i, fitnesses[i]);
	}
	fitmin = gsl_vector_float_min(vec);
	fitmax = gsl_vector_float_max(vec);
	
	gsl_vector_float_free(vec);
	vec = NULL;
	
	addConstantToArrayf(fitnessesScaled, -1*fitmin +selection_temperature*(fitmax - fitmin), popSize);
	float dist[popSize];
	makeDistribution(fitnessesScaled, dist, popSize);
	
	Gene ** newGenes = (Gene **)malloc(sizeof(Gene *)*popSize);	
	for(int i = 0 ; i < popSize ; i++){
		unsigned idx = stochasticIDX(dist, popSize);
		newGenes[i] = new Gene(*(genes[idx]));
	}	
	delete [] genes;
	genes = newGenes;	
	
}

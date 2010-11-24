/*
 *  ComputableUnit.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "ComputableUnit.h"
#include <math.h>
#include <iostream>

void ComputableUnit::computeDelta(){};
void ComputableUnit::computeValue(){};
void ComputableUnit::computeWeights(float learningRate,float alpha){};
void ComputableUnit::addInput(NeuralUnit * unit){
	inputs.push_back(unit);
};
void ComputableUnit::setRandomWeights(float maxAbs){
	weights.clear();
	lastChange.clear();
	for (int i = 0 ; i < inputs.size() ; i ++){
		weights.push_back(   ((float)(rand() % 1000) -500) *maxAbs/1000);
		lastChange.push_back(weights[i]);
	}
};

void ComputableUnit::setDelta(float newDelta){
	delta = newDelta;
};

float ComputableUnit::getWeight(NeuralUnit * unit){
	for(int i = 0 ; i < inputs.size() ; i++){
		if((&(*inputs[i])) == (&(*unit))) return weights[i];
	}
	return 0.0;
}

float ComputableUnit::weightAtIndex(int idx){
	return weights[idx];
}

float ComputableUnit::getDelta(){
	return delta;
};
float ComputableUnit::getLastChange(int idx){
	return lastChange[idx];
}
NeuralUnit * ComputableUnit::outputAtIndex(int idx){
};
NeuralUnit * ComputableUnit::inputAtIndex(int idx){
};


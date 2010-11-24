/*
 *  SigmoidUnit.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "SigmoidUnit.h"
#include <math.h>
#include <iostream>

void SigmoidUnit::computeDelta(){
	float dwSum = 0;

	for(int i = 0 ; i < outputs.size() ; i++){
		float d = outputs[i]->getDelta();
		float w = outputs[i]->getWeight(this);
		dwSum += d*w;
	}
	delta = value * (1-value) * dwSum;

};
void SigmoidUnit::computeValue(){
	float net = 0;
	for (int i = 0 ; i < inputs.size() ; i++){
		net += inputs[i]->getValue()*weights[i];
	}
	//if(outputs.size() != 0) cout<<inputs[0]->getValue();
	//cout<<net;
	value = 1 / (1 + exp(-1 * net));
};
void SigmoidUnit::computeWeights(float learningRate,float alpha){

	for(int i = 0 ; i < inputs.size() ; i++){
		float change = delta * inputs[i]->getValue()*learningRate + lastChange[i] *alpha;
		lastChange[i] = change;

		weights[i] = weights[i] + change ;
	}
};
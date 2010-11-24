/*
 *  LinearUnit.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/2/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "LinearUnit.h"
#include <math.h>
#include <iostream>

void LinearUnit::computeDelta(){
	float dwSum = 0;
	
	for(int i = 0 ; i < outputs.size() ; i++){
		float d = outputs[i]->getDelta();
		float w = outputs[i]->getWeight(this);
		dwSum += d*w;
	}
	delta = value * dwSum;
	
};
void LinearUnit::computeValue(){
	float net = 0;
	for (int i = 0 ; i < inputs.size() ; i++){
		net += inputs[i]->
		getValue()*weights[i];
	}
	//cout<<inputs[0]->getValue()<<"\n";

	value =net;
};
void LinearUnit::computeWeights(float learningRate,float alpha){
	//cout<<"COMPUTINGWEIGHTS???";
	for(int i = 0 ; i < inputs.size() ; i++){
		alpha = 0;
		bool wsign = weights[i] >= 0;
		int k;
		float wmaxabs = 50;
		float wabs;
		if(wsign) wabs = weights[i]; else wabs = -weights[i];
		float decay;
		float cof = wabs/wmaxabs;
		if(cof < 1) decay = pow(cof,2); else decay = 2-(1/cof);
		decay = decay/2;
		
		if(wsign) k = 1; else k = -1;
		
		float change = delta * inputs[i]->getValue()*learningRate + lastChange[i] *alpha;
		//if (wabs > 5)cout<<"  Change  "<<weights[i]<<"  "<<decay<<"  "<<change<<"\n"<<"delta:  "<<delta <<"  input:"<<inputs[i]->getValue();
		
		if (change> learningRate* 20) change = learningRate*20 ;
		if (change< -learningRate *20) change = -learningRate*20;
		lastChange[i] = change;
		weights[i] = (weights[i] + change)*(1 - decay);
	}
};
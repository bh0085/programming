/*
 *  NeuralUnit.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#include "NeuralUnit.h"
#include "iostream"
#include "SigmoidUnit.h"
void NeuralUnit::connectForward(ComputableUnit * unit){
	outputs.push_back(unit);
	unit->addInput(this);
	
}

float NeuralUnit::getValue(){
	return value;
};

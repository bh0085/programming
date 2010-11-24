/*
 *  ReinforcementLearnerState.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "ReinforcementLearnerState.h"


void ReinforcementLearnerState::getXYInArray(float XYArray[] ){
	XYArray[0] = stateVars[0];
	XYArray[1] = stateVars[1];
};
void ReinforcementLearnerState::setXY(float Array[] ){
	stateVars[0] = Array[0];
	stateVars[1] = Array[1];
};
void ReinforcementLearnerState::getNNInputInVector(vector <float> * v){
	v->push_back(stateVars[0]);
	v->push_back(stateVars[1]);
};

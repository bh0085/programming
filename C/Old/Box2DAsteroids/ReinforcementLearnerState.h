/*
 *  ReinforcementLearnerState.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef REINFORCEMENTLEARNERSTATE_H
#define REINFORCEMENTLEARNERSTATE_H 1

#include <vector>
class ReinforcementLearnerAction;
#define stateVarsMaxSize 10

using namespace std;
class ReinforcementLearnerState{
protected:
	float stateVars [stateVarsMaxSize];
public:
	void getXYInArray(float  XYArray []);
	void setXY(float Array [] );
	void getNNInputInVector(vector <float> * v);
};

#endif
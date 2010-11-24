/*
 *  ReinforcementLearnerEnvironment.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "ReinforcementLearnerEnvironment.h"
#include <iostream>

void ReinforcementLearnerEnvironment::getConsequenceInState(ReinforcementLearnerState * initialState, 
												ReinforcementLearnerAction * action, 
												ReinforcementLearnerState * finalState){
	cout<<"calling a virtual parent class routine for getconsequence...";
};

float ReinforcementLearnerEnvironment::rewardForAction(ReinforcementLearnerState * state, ReinforcementLearnerAction * action){
};
bool ReinforcementLearnerEnvironment::success(ReinforcementLearnerState * state){
	return false;
}

int ReinforcementLearnerEnvironment::type(){ return 0;};
void ReinforcementLearnerEnvironment::setTargetAtIndex(int idx, float val){
	targetState[idx] = val;
}

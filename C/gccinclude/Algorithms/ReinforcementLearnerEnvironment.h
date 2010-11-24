/*
 *  ReinforcementLearnerEnvironment.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef REINFORCEMENTLEARNERENVIRONMENT_H
#define REINFORCEMENTLEARNERENVIRONMENT_H 1

#include "vector"
using namespace std;

#define TARGET_STATE_LENGTH

class ReinforcementLearnerState;
class ReinforcementLearnerAction;

class ReinforcementLearnerEnvironment{
protected:
	float targetState [TARGET_STATE_LENGTH];
	
public:
	virtual void getConsequenceInState(ReinforcementLearnerState * initialState, 
								ReinforcementLearnerAction * action,
								ReinforcementLearnerState * finalState);
	virtual float rewardForAction(ReinforcementLearnerState * state, ReinforcementLearnerAction * action);

	virtual bool success(ReinforcementLearnerState * state);
	virtual int type();
	void setTargetAtIndex(int idx, float val);
};

#endif

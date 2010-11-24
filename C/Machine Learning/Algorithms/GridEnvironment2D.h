/*
 *  2DRealGridEnvironment.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "ReinforcementLearnerEnvironment.h"

class GridEnvironment2D : public ReinforcementLearnerEnvironment{
	
public:
	void getConsequenceInState(ReinforcementLearnerState * initialState, 
							   ReinforcementLearnerAction * action, 
							   ReinforcementLearnerState * finalState);

	float rewardForAction(ReinforcementLearnerState * state, ReinforcementLearnerAction * action);
	 bool success(ReinforcementLearnerState * state);
	 int type();

};
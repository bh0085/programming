/*
 *  GridLearner2D.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "NNReinforcementLearner.h"
#include "GridEnvironment2D.h"
class GridLearner2D : public NNReinforcementLearner {
protected:
	GridEnvironment2D environment;
public:
	GridLearner2D();
	void trainingRun();
	void run();
	void printState();
	GridEnvironment2D * getEnvironment();
	ReinforcementLearnerAction * getAction(int actionIdx);
};

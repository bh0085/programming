/*
 *  NNReinforcementLearner.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/22/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "NeuralNet.h"
#include "ReinforcementLearnerState.h"
#include "ReinforcementLearnerAction.h"
#include "ReinforcementLearnerEnvironment.h"
#include <vector>
using namespace std;

#define MAX_ACTIONS 10

//This learner assumes a fixed environment... in other words, that we do not
//need to pass the environment to methods such as getConsequence. 

class NNReinforcementLearner {
protected:
	ReinforcementLearnerAction allActions[MAX_ACTIONS];
	
	int trainingType;
	int nActions;
	int jitter;
	int chainLength;
	int numChains;
	float lambda;
 	ReinforcementLearnerState currentState;
	ReinforcementLearnerEnvironment environment;
	

public:
	NNReinforcementLearner();
	
	float getReward(ReinforcementLearnerState * initialState,
					ReinforcementLearnerAction * actionTaken);
	
	float getNNQHat(ReinforcementLearnerState * initialState,
					ReinforcementLearnerAction * actionTaken);
	
	void trainNNQHat(ReinforcementLearnerState * initialState,
					 ReinforcementLearnerState * finalState, 
					 ReinforcementLearnerAction * actionTaken);

	void takeAction(ReinforcementLearnerAction * action);
	

	void availableActionsInVector(ReinforcementLearnerState * initialState,
								  vector <ReinforcementLearnerAction * > * v);
	ReinforcementLearnerAction * randomAction(ReinforcementLearnerState *);
	
	virtual void trainingRun();
	virtual void run();
	void incrementRun();
	void incrementTrainingRun();
	virtual ReinforcementLearnerEnvironment * getEnvironment();
};
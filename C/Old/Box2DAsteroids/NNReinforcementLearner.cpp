/*
 *  NNReinforcementLearner.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/22/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "NNReinforcementLearner.h"
#include "vector"
#include "NeuralNet.h"
#include <iostream>
#include "GridState2D.h"
using namespace std;
NNReinforcementLearner::NNReinforcementLearner(){
	
}

void NNReinforcementLearner::trainingRun(){}

void NNReinforcementLearner::run(){}

void NNReinforcementLearner::incrementTrainingRun(){
	
	ReinforcementLearnerState states[numChains][chainLength];
	ReinforcementLearnerAction * actions[numChains][chainLength];
	
	//in order to enable runtime polymorphism in this method, i use the virtual
	//method, getEnvironment to summon a pointer to the current environment.
	ReinforcementLearnerEnvironment * environmentPointer = getEnvironment();

	
		
	
	for(int i = 0 ; i < numChains ; i++){
		for(int j = 0 ; j < chainLength ; j++){
			if(j == 0){
				states[i][j] = currentState;
			} else {
				environmentPointer->getConsequenceInState( &(states[i][j-1]), actions[i][j-1], &(states[i][j]) );
									
			}
			actions[i][j] = randomAction(&(states[i][j]));			
		}
	}
	for(int i = 0 ; i < jitter ; i++){
		for(int j = 0 ; j <numChains;j++){
			for(int k = 1 ; k < chainLength ; k++){ 
				trainNNQHat(&(states[j][k-1]), &(states[j][k]), actions[j][k-1]);
			};
		};
	};
	 
	
	takeAction(randomAction(&(currentState)));
}

void NNReinforcementLearner::trainNNQHat(
							  ReinforcementLearnerState * oldState, 
							  ReinforcementLearnerState * newState,
							  ReinforcementLearnerAction * action){
	vector < ReinforcementLearnerAction * > actions;
	availableActionsInVector(newState, &actions);
	float qMax = 0;
	float idxBest = -1;
	for(int i = 0 ; i < actions.size(); i++){
		float val = getNNQHat(newState, actions[i]);
		if(val > qMax || idxBest ==-1){
			idxBest = i;
			qMax = val;
		}
	}
	float newTrainingValue =lambda * qMax + getReward(oldState, action);
	vector <float> trainingIn;
	vector <float> trainingOut;
	
	//push neural network inputs based on state.... 
	oldState->getNNInputInVector(&trainingIn);
	
	//cout<<trainingIn.size();
	trainingOut.push_back(newTrainingValue);
	action->trainNN( &trainingIn, &trainingOut);
	
}
float NNReinforcementLearner::getNNQHat(ReinforcementLearnerState * oldState, 
							 ReinforcementLearnerAction * action){
	
	vector <float> output;
	vector <float> input;
	oldState->getNNInputInVector(&input);
	action->evaluateNN( &input , &output);
	return output[0];
};
void NNReinforcementLearner::incrementRun(){
	vector < ReinforcementLearnerAction * > actions;
	availableActionsInVector(&currentState, &actions);
	float qMax = -1;
	int idxBest = -1;
	
	for(int i = 0 ; i < actions.size() ; i++){
		ReinforcementLearnerAction * action = actions[i];
		float val = getNNQHat(&currentState,action);
		if(val > qMax || idxBest == -1){
			idxBest = i;
			qMax = val;
		}
	}
	
	takeAction(actions[idxBest]);
}
float NNReinforcementLearner::getReward(ReinforcementLearnerState * initialState, 
											ReinforcementLearnerAction *action){
	return getEnvironment()->rewardForAction(initialState,action);
}

void NNReinforcementLearner::availableActionsInVector( ReinforcementLearnerState * state,
													  vector <ReinforcementLearnerAction *> * availableActions){
	float xy[2];
	state->getXYInArray(xy);
	if(xy[0] < 10.0) availableActions->push_back(&(allActions[0]));
	if(xy[0] > 0.0) availableActions->push_back(&(allActions[1]));
	if(xy[1] < 10.0) availableActions->push_back(&(allActions[2]));
	if(xy[1] > 0.0) availableActions->push_back(&(allActions[3]));

}


void NNReinforcementLearner::takeAction(ReinforcementLearnerAction * action){

	getEnvironment()->getConsequenceInState(&currentState, action, &currentState);
	
}
ReinforcementLearnerAction * NNReinforcementLearner::randomAction(ReinforcementLearnerState * initialState){
	vector < ReinforcementLearnerAction *> actions;
	availableActionsInVector(initialState, &actions);
	ReinforcementLearnerAction * chosen = actions[rand() % actions.size()];
	
	return chosen;
};
ReinforcementLearnerEnvironment * NNReinforcementLearner::getEnvironment(){
	return (&environment);
}

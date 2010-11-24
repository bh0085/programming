/*
 *  GridLearner2D.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GridLearner2D.h"
#include "GridState2D.h"
#include <iostream>
#include "GLIDL.h"
#include "MyCIDL.h"
class ReinforcementLearnerAction;

GridLearner2D::GridLearner2D(){
	trainingType = 1;
	
	jitter = 2;
	chainLength = 4;
	numChains = 2;
	lambda = .8;	
	getEnvironment()->setTargetAtIndex(0,5.0);
	getEnvironment()->setTargetAtIndex(1,5.0);
	getEnvironment()->setTargetAtIndex(2,2.0);
	
	nActions = 4;
	for(int i = 0 ; i < nActions ; i++){
		ReinforcementLearnerAction action;
		allActions[i] = action;
		int stream [2] = {i,2};
		allActions[i].setStream(stream, 2);
		allActions[i].setNetRate(.02);
		allActions[i].setNetWeightAbs(.02);	
		allActions[i].setNetAlpha(.4);
		allActions[i].initWithNet(2,8
								  ,1);
	};
};

GridEnvironment2D * GridLearner2D::getEnvironment(){
	return static_cast<GridEnvironment2D *> (&environment);
}
	
void GridLearner2D::trainingRun(){
	float xy[2] = {(float)(rand() % 10)+.5,(float)(rand() % 10) +.5};
	currentState.setXY(xy);
	int i;
	int nMoves = 20;
	int nReps = 1;
	int nReps1 = 100;
	
	float action0Weights[nReps*4];
	float timeAxis[nReps*4];
	float zs[nReps*4];
	findgen(timeAxis, nReps*4);
	int size = 0;
	
	if(trainingType == 0){
		for (  i = 0 ; i < nMoves ; i++){
			incrementTrainingRun();
			if(getEnvironment()->success(&currentState)){
				//cout<< "Breaking out of run "<<i;
				break;
			}
		}
	} else {
		ReinforcementLearnerState sequentialStates[nMoves];
		ReinforcementLearnerAction * sequentialActions[nMoves];
		for( i = 0 ; i < nMoves ; i++){
			if(i == 0){ 
				sequentialStates[i] = currentState; 
			} else { 
				getEnvironment()->
					getConsequenceInState(&(sequentialStates[i-1]), 
										  sequentialActions[i-1], 
										  &(sequentialStates[i]));
			}
			sequentialStates[i].getXYInArray(xy);
			sequentialActions[i] = randomAction(&sequentialStates[i]);
			
			//cout<<xy[0]<<"   "<<xy[1]<<"\n";
			
			if(getEnvironment()->success(&(sequentialStates[i]))){
				for(int m = 0 ; m <nReps1 ; m++){
				for( int j = i ; j> 0 ; j--){
					for(int k = 0 ; k < nReps ; k++){
						for(int l = j ; l < i ; l++){
							trainNNQHat(&sequentialStates[l-1], 
										&sequentialStates[l],
										sequentialActions[l-1]);
						}
					}
				}
				}
				break;
			}
		}
	}
	int winsize[2] = {400,400};
	int wmarg = 5;
	int winxy[2];
	for(int i = 0 ; i < 4 ; i ++){
		switch(i){
			case 0:
				winxy[0] = 10;
				winxy[1] = 10;
				break;
			case 1:
				winxy[0] = 10 + winsize[0] + wmarg;
				winxy[1] = 10;
				break;
			case 2:
				winxy[0] = 10;
				winxy[1] = 10 + winsize[1] + wmarg;
				break;
			case 3:
				winxy[0] = 10 + winsize[0] + wmarg;
				winxy[1] = 10 + winsize[1] + wmarg;
				break;
			default:
				break;
		}
		
		windowAtXYWithSize(i,winxy,winsize);
		allActions[i].getNN()->drawNet();		
		
	}


	
	currentState.getXYInArray(xy);

	 

};

void GridLearner2D::run(){
	float xy[2] = {.5,.5};
	currentState.setXY(xy);
	for ( int i = 0 ; i < 50 ; i++){
		incrementRun();
		if(getEnvironment()->success(&currentState)) break;
	}
};

void GridLearner2D::printState(){
	vector <float> actionInput;
	actionInput.push_back(0.0);
	actionInput.push_back(0.0);
	vector <float> actionOutput;

	actionOutput.clear();
	ReinforcementLearnerState * state = &currentState;
	cout<<"\n";
	
	cout<<"\n";
	cout<<"Number of actions: "<<nActions<<"\n";
	cout<<"NNEvaluations at 0,0: \n";
	for ( int i = 0 ; i < nActions ; i++){
		actionOutput.clear();
		allActions[i].evaluateNN(&actionInput,&actionOutput);
		cout<<"  "<<actionOutput[0]<<"\n";
	}
		
	float xy[2];
	state->getXYInArray(xy);
	actionInput[0] = xy[0];
	actionInput[1] = xy[1];
	//actionOutput.clear();
	cout<<"\n";
	
	cout<<"currentXY: "<<xy[0]<<", "<<xy[1]<<"\n";
	cout<<"NNEvaluations at currentSquare: \n";
	
	for ( int i = 0 ; i < nActions ; i++){
		actionOutput.clear();
		allActions[i].evaluateNN(&actionInput,&actionOutput);
		cout<<"  "<<actionOutput[0]<<"\n";
	}
	

}
ReinforcementLearnerAction * GridLearner2D::getAction(int actionIdx){
	return &(allActions[actionIdx]);
};

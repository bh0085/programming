/*
 *  2DRealGridEnvironment.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GridEnvironment2D.h"
#include "GridState2D.h"
#include "ReinforcementLearnerAction.h"
#include <math.h>
#include <iostream>


void GridEnvironment2D::getConsequenceInState(ReinforcementLearnerState * initialState, 
												ReinforcementLearnerAction * action, 
												ReinforcementLearnerState * finalState){
	int * stream= action->getStream();
	float xy[2];
	initialState -> getXYInArray(xy);

	
	switch (stream[0]) {
		case 0:
			xy[0]+=stream[1];
			break;
		case 1:
			xy[0]-=stream[1];
			break;
		case 2:
			xy[1]+=stream[1];
			break;
		case 3:
			xy[1]-=stream[1];
			break;
		default:
			break;
	}
	finalState -> setXY(xy);

	 
	
};

float GridEnvironment2D::rewardForAction(ReinforcementLearnerState * initialState, ReinforcementLearnerAction * action){
	ReinforcementLearnerState fs;
	ReinforcementLearnerState * finalState = &fs;
	getConsequenceInState(initialState, action, finalState);
	
	float xy1[2];
	float xy2[2];
	
	initialState->getXYInArray(xy1);
	finalState->getXYInArray(xy2);
	
	float d1 = pow(xy1[0] - targetState[0], 2) + pow(xy1[1] - targetState[1],2) ;
	float d2 = pow(xy2[0] - targetState[0], 2) + pow(xy2[1] - targetState[1],2) ;
	
	if( d1 > targetState[2] && d2 < targetState[2]){
		return .9;
	}	
	if( d1 < targetState[2] && d2 < targetState[2]){
		return .5;
	}	
	if( d1 < targetState[2] && d2 > targetState[2]){
		return .1;
	}
	
	return 0.1;
};
bool GridEnvironment2D::success(ReinforcementLearnerState * state){
	float xy1[2];
	state->getXYInArray(xy1);
	float d1 = pow(xy1[0] - targetState[0], 2) + pow(xy1[1] - targetState[1],2) ;
	
	if( d1 < targetState[2]){
		return true;
	}	
	return false;
	
	
};

int GridEnvironment2D::type(){ return 1; };


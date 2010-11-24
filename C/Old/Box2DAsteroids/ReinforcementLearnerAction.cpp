/*
 *  ReinforcementLearnerAction.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <iostream>
#include "ReinforcementLearnerAction.h"
ReinforcementLearnerAction::ReinforcementLearnerAction(){
	for( int i = 0 ; i < STREAMLENGTH ; i++){
		stream[i] = 0;
	}
};
void ReinforcementLearnerAction::setNetRate(float rate){
	net.setRate(rate);
}
void ReinforcementLearnerAction::setNetWeightAbs(float newAbs){
	net.setWeightAbs(newAbs);
}
void ReinforcementLearnerAction::setNetAlpha(float alpha){
	net.setAlpha(alpha);
}



void ReinforcementLearnerAction::initWithNet(int nIn,int nHidden, int nOut){
	net.initNLayersRBF(3, nIn, nHidden, nOut);
};
void ReinforcementLearnerAction::setStream(int newStream[],int length){
	
	 for(int i = 0 ; i < length ; i++){
		stream[i] = newStream[i];
		 cout<<stream[i];
		 
	}
	
}
int * ReinforcementLearnerAction::getStream(){
	return &(stream[0]);
}
void ReinforcementLearnerAction::trainNN(vector <float> * trainingIn, vector <float> * trainingOut){
	net.trainingRun(trainingIn, trainingOut);	
};
void ReinforcementLearnerAction::evaluateNN( vector <float> * input, vector <float> *output){
	net.run(input,output);

	//cout<<net.getOutput(0)->getValue();
};

NeuralNet * ReinforcementLearnerAction::getNN(){
	return &net;
}
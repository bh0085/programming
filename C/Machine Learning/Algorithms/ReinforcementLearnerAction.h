/*
 *  ReinforcementLearnerAction.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef REINFORCEMENTLEARNERACTION_H
#define REINFORCEMENTLEARNERACTION_H
#include <vector>
#include "NeuralNet.h"
using namespace std;

#define STREAMLENGTH 100

class ReinforcementLearnerAction{
protected:
	NeuralNet net;
	int stream[STREAMLENGTH];
public:
	ReinforcementLearnerAction();
	void initWithNet(int netIn, int netHidden, int netOut);
	void setStream(int newStream[],int length);
	int * getStream();
	NeuralNet * getNN();
	void trainNN(vector <float> * trainingIn, vector <float> * trainingOut);
	void evaluateNN( vector <float> * input, vector <float> *output);
	void ReinforcementLearnerAction::setNetRate(float rate);
	void ReinforcementLearnerAction::setNetWeightAbs(float newAbs);
	void ReinforcementLearnerAction::setNetAlpha(float alpha);
	

};
#endif
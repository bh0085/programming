/*
 *  ComputableUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef COMUTABLEUNIT_H
#define COMUTABLEUNIT_H 1

#include "NeuralUnit.h"
class ComputableUnit:public NeuralUnit{
protected: 
	vector <float> weights;
	float delta;
	vector <float> lastChange;
	
public:
	vector <NeuralUnit *> inputs;
	virtual void computeValue();
	virtual void computeDelta();
	virtual void computeWeights(float learningRate,float alpha);
	void addInput(NeuralUnit * unit);
	void setRandomWeights(float maxAbs);
	void setDelta(float newDelta);
	float getLastChange(int idx);
	float getDelta();
	float getWeight(NeuralUnit * unit);
	float weightAtIndex(int idx);
	NeuralUnit * outputAtIndex(int idx);
	NeuralUnit * inputAtIndex(int idx);
	
};
#endif

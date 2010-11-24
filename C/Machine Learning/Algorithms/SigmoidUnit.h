/*
 *  SigmoidUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */



#ifndef SIGMOIDUNIT_H
#define SIGMOIDUNIT_H 1

#include "ComputableUnit.h"
class SigmoidUnit:public ComputableUnit{
public:
	//Computable unit functions overwritten by sigmoid.
	void computeValue();
	void computeDelta();
	void computeWeights(float learningRate,float alpha);

};
#endif
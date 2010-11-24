/*
 *  LinearUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/2/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef LINEARUNIT_H
#define LINEARUNIT_H 1

#include "ComputableUnit.h"
class LinearUnit:public ComputableUnit{
public:
	//Computable unit functions overwritten by sigmoid.
	void computeValue();
	void computeDelta();
	void computeWeights(float learningRate,float alpha);
	
};
#endif
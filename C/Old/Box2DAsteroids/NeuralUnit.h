/*
 *  NeuralUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef NEURALUNIT_H
#define NEURALUNIT_H 1
#include <vector>
class ComputableUnit;
using namespace std;

class NeuralUnit{
protected:
	float value;
public:
	vector <ComputableUnit * > outputs;
	float getValue();
	void connectForward(ComputableUnit * unit);	
};

#endif
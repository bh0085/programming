/*
 *  InputUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef INPUTUNIT_H
#define INPUTUNIT_H 1

#include "NeuralUnit.h"
class InputUnit:public NeuralUnit{
private:
public:
	void setValue(float val);
};
#endif
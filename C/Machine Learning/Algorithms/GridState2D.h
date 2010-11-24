/*
 *  2DGridState.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "ReinforcementLearnerState.h"

class GridState2D : public ReinforcementLearnerState{
public:
	void getXYInArray(float  XYArray []);
	void setXY(float Array [] );
	void getNNInputInVector(vector <float> * v);
};
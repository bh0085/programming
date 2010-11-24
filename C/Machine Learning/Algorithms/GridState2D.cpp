/*
 *  2DGridState.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GridState2D.h"
void GridState2D::getXYInArray(float XYArray[] ){
	XYArray[0] = stateVars[0];
	XYArray[1] = stateVars[1];
};
void GridState2D::setXY(float Array[] ){
	stateVars[0] = Array[0];
	stateVars[1] = Array[1];
};
void GridState2D::getNNInputInVector(vector <float> * v){
	v->push_back(stateVars[0]);
	v->push_back(stateVars[1]);
};

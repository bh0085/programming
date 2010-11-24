/*
 *  RBFUnit.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/14/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RBFUNIT_H
#define RBFUNIT_H 1

#define RBF_MAX_INPUTS 100

#include "ComputableUnit.h"
class RBFUnit:public ComputableUnit{
private:
	int dims;
	float kernelDecays[RBF_MAX_INPUTS];
	float kernelCenters[RBF_MAX_INPUTS];
public:
	//Computable unit functions overwritten by sigmoid.
	void computeValue();
	void setKernel(float widths[], float centers[], int nDims);
	void getCenters(float centers[]);
	void getWidths(float widths[]);


};
#endif
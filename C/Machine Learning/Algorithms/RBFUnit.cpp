/*
 *  RBFUnit.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/14/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "RBFUnit.h"
#include <math.h>
void RBFUnit::computeValue(){
	float distanceSquared = 0;
	for (int i = 0 ; i < inputs.size() ; i++){
		distanceSquared += pow( (inputs[i]->getValue() - kernelCenters[i]) *kernelDecays[i] ,2);
	}
	value = exp(-distanceSquared*.5);
}
void RBFUnit::setKernel(float widths[], float centers[], int nDims){
	for( int i = 0 ; i < nDims ; i++){
		kernelDecays[i] = 1/(widths[i]);
		kernelCenters[i] = centers[i];
	}
	dims = nDims;
}
void RBFUnit::getCenters(float centers[]){
	for( int i = 0 ; i < dims ; i++){
		centers[i] = kernelCenters[i];
	}
}
void RBFUnit::getWidths(float widths[]){
	for( int i = 0 ; i < dims ; i++){
		widths[i] = 1/kernelDecays[i];
	}
}
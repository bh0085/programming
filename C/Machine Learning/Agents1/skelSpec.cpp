/*
 *  skelSpec.cpp
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "skelSpec.h"
#include "stdlib.h"
skelSpec::skelSpec(unsigned numBones){
	nBones = numBones;
	cxns = new unsigned[nBones];
	motors = new unsigned[nBones];
	lengths = new float[nBones];
};
skelSpec::~skelSpec(){
	free(cxns);
	free(motors);
};
void skelSpec::setCxn(unsigned bone, unsigned val){
	cxns[bone] = val;
};
void skelSpec::setLength(unsigned bone, float val){
	lengths[bone] = val;
};
void skelSpec::setMotor(unsigned bone, unsigned val){
	motors[bone] = val;
};

unsigned skelSpec::getCxn(unsigned bone){
	return cxns[bone];
};
unsigned skelSpec::getMotor(unsigned bone){
	return motors[bone];
};
float skelSpec::getLength(unsigned bone){
	return lengths[bone];
};
unsigned skelSpec::getNumBones(){
	return nBones;
};
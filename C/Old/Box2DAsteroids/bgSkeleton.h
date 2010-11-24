/*
 *  bgSkeleton.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/15/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

//#include "bgComplexBody.h"
#include "Box2D.h"
#include "bgHeaders.h"
#include "bgComplexBody.h"

class bgSkeleton {
protected:
	b2Vec2 origin;
	bgComplexBody * complexBody;
	vector <bgBone *> bones;
	b2World * world;
	
public:
	bgSkeleton(b2World *world);
	void bgSkeleton::makeJoint(bgBone * parent, bgBone * child, b2Vec2 pt, int type);
	void bgSkeleton::addBone(int cxn, int length, int joint);
	int bgSkeleton::getNumBones();
	bgBone * getBoneAtIndex(unsigned int i);
};
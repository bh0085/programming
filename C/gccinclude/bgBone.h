/*
 *  bgBone.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef BGBONE_H
#define BGBONE_H
#include "Box2D.h"
#include "bgActor.h"

class bgBone : public bgActor{
private: 
	b2Vec2 startPt;
	b2Vec2 endPt;
public:
	b2Joint * joint;		
	bgBone(b2World * newWorld);
	b2Vec2 * getStartPt();
	b2Vec2 * getEndPt();
	void makeBoneInWorld(float length);	
	b2Vec2 createStartInWorldCoordinates();
	b2Vec2 createEndInWorldCoordinates();
	void setStartPostion(float x, float y);
	void setJoint(b2Joint * newJoint);
	
};
#endif
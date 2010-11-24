/*
 *  bgBone.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "Box2D.h"
#include "bgActor.h"

class bgBone : public bgActor{
private: 
	bgActor*ba;
	b2Vec2 startPt;
	b2Vec2 endPt;
	b2Joint * joint;	
public:
	bgBone(b2World * newWorld);
	b2Vec2 * getStartPt();
	b2Vec2 * getEndPt();
	void clipChildWithRotateJoint(bgBone * child);
	void makeBoneInWorld(float length);	
	b2Vec2 createStartInWorldCoordinates();
	b2Vec2 createEndInWorldCoordinates();
	void setStartPostion(float x, float y);
	void setJoint(b2Joint * newJoint);
	

};
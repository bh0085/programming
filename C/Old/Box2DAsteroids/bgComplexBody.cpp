/*
 *  bgComplexBody.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/15/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "bgHeaders.h"

bgComplexBody::bgComplexBody(b2World * newWorld){
	world = newWorld;
}

void bgComplexBody::pushActor(bgActor * actor){
	bodies.push_back(actor);
}

int bgComplexBody::getNumBodies(){
	return( bodies.size());
}

bgActor* bgComplexBody::getActorAtIndex(unsigned int index){
	return bodies[index];
}
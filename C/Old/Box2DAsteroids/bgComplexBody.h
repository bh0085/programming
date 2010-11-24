/*
 *  bgComplexBody.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <vector>
#include "Box2D.h"
#include "bgHeaders.h"


using namespace std;
class bgComplexBody{
private:
	
public:
	b2World * world;
	vector <bgActor *> bodies;
public:
	//create a new generic actor...
	bgComplexBody(b2World * newWorld);
	
	//push an actor to the current array bodies
	void pushActor(bgActor * actor);
	
	//get the current body
	bgActor* getActorAtIndex(unsigned int index);
	
	//get number of bodies in complex body
	int bgComplexBody::getNumBodies();	

};
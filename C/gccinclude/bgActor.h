/*
 *  bgActor.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef BGACTOR_H
#define BGACTOR_H
#include <vector>
#include "Box2D.h"
 


using namespace std;
//a simple actor class consisting of one solid body
class bgActor{
private:

protected:
	b2World * world;
	b2Body * body;
	vector <b2Vec2 *> verts;	
public:
	//create a new generic actor...
	bgActor(b2World * newWorld);
	virtual ~bgActor();
	
	//create a new body in the world with a specific shape and vertices
	void makeBoxInWorld(  float width, float height);
	void makeBallInWorld(float radius);
	void makeStaticGroundInWorld(float width, float height);	
	
	//get the current body
	b2Body* getBody();
	
	//set the body's postion/angle
	float getX();
	float getY();
	
	
	//if I start having speed problems, I should de-virtualize these.
	void moveBy(float x, float y);
	void setPosition(float x, float y);
	void setAngle(float theta);
	void setOmega(float omega);
	void setVelocity(float vx, float vy);
	float getVelX();
	float getVelY();
	
	void accelerateBy(float vx, float vy);
	//finally, return the graphical vertices
	void createAndReturnWorldVertsInVector(vector <b2Vec2 *> * vs);
	
	virtual void draw();

};
#endif
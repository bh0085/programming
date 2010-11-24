/*
 *  bgBone.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "bgBone.h"
bgBone::bgBone(b2World*newWorld):bgActor(newWorld){}

void bgBone::makeBoneInWorld(float length){
	b2BodyDef bodyDef;
	bodyDef.position.Set(0.0f, 0.0f);
	bodyDef.userData = this;
	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonDef shapeDef;
	float height = 1.2;
	float width = length;
	shapeDef.SetAsBox(length/2,height/2);
	
	// Set the box density to be non-zero, so it will be dynamic.
	shapeDef.density = 1.0f / height / 5;
	
	// Override the default friction.
	shapeDef.friction = 0.8f;
	
	// Add the shape to the body.
	body->CreateShape(&shapeDef);
	
	// Now tell the dynamic body to compute it's mass properties base
	// on its shape.
	body->SetMassFromShapes();
	
	verts.push_back(new b2Vec2(-width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,height/2));
	verts.push_back(new b2Vec2(-width/2,height/2));
	
	startPt = b2Vec2(-(width)/2,0.0);
	endPt = b2Vec2(width/2,0.0);
}

void bgBone::setStartPostion(float x, float y){
	float centerPosX = x - startPt.x;
	float centerPosY = y - startPt.y;
	setPosition(centerPosX,centerPosY);
};

b2Vec2* bgBone::getStartPt(){
	return &startPt;
}

b2Vec2* bgBone::getEndPt(){
	return &endPt;
}
b2Vec2 bgBone::createStartInWorldCoordinates(){
	b2Vec2 temp = body->GetWorldPoint(startPt);
	return temp;
}
b2Vec2 bgBone::createEndInWorldCoordinates(){
	b2Vec2 temp = body->GetWorldPoint(endPt);
	return temp;
}
void bgBone::setJoint(b2Joint * newJoint){
	joint = newJoint;
}
	


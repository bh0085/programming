/*
 *  bgActor.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
 
#include "bgHeaders.h"

bgActor::bgActor(b2World * newWorld){
	world = newWorld;
}
void bgActor::makeBoxInWorld(float width, float height){
	b2BodyDef bodyDef;
	bodyDef.position.Set(0.0f, 0.0f);
	bodyDef.userData = this;

	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(width/2,height/2);
	
	// Set the box density to be non-zero, so it will be dynamic.
	shapeDef.density = 1.0f;
	
	// Override the default friction.
	shapeDef.friction = 0.3f;
	
	// Add the shape to the body.
	body->CreateShape(&shapeDef);
	
	// Now tell the dynamic body to compute it's mass properties base
	// on its shape.
	body->SetMassFromShapes();
	
	verts.push_back(new b2Vec2(-width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,height/2));
	verts.push_back(new b2Vec2(-width/2,height/2));

}

void bgActor::makeStaticGroundInWorld(float width, float height){
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0.0f, 0.0f);
	groundBodyDef.userData = this;
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	body = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2PolygonDef groundShapeDef;
	
	// The extents are the half-widths of the box.
	groundShapeDef.SetAsBox(width/2,height/2);
	
	// Add the ground shape to the ground body.
	body->CreateShape(&groundShapeDef);	

	verts.push_back(new b2Vec2(-width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,-height/2));
	verts.push_back(new b2Vec2(width/2,height/2));
	verts.push_back(new b2Vec2(-width/2,height/2));

};

void bgActor::makeBallInWorld(float radius){
	
};

void bgActor::createAndReturnWorldVertsInVector(vector <b2Vec2*>  * vs){
	for(int i = 0 ; i < verts.size(); i++){
		b2Vec2 * vert = (verts[i]);
		vs->push_back(new b2Vec2);
		b2Vec2 wPtInBody = body->GetWorldPoint( *vert );
		(*vs)[i]->x = wPtInBody.x;
		(*vs)[i]->y = wPtInBody.y;
					  
					  
	}
}
float bgActor::getX(){
	b2Vec2 position = body->GetPosition();
	return position.x;
}
float bgActor::getY(){
	b2Vec2 position = body->GetPosition();
	return position.y;
}
void bgActor::setPosition(float x, float y){
	b2Vec2 position(x,y);
	float32 angle = body->GetAngle();
	body->SetXForm(position, angle);	

};
void bgActor::moveBy(float x, float y){
	b2Vec2 position = body->GetPosition();
	position.x += x;
	position.y += y;
	float32 angle = body->GetAngle();
	body->SetXForm(position, angle);	
	
};
void bgActor::setAngle(float theta){
	b2Vec2 position = body->GetPosition();
	body->SetXForm(position,theta);
	
};
void bgActor::setOmega(float omega){
	body->SetAngularVelocity(omega);
};
float bgActor::getVelX(){
	b2Vec2 velocity = body->GetLinearVelocity();
	return velocity.x;	
}
float bgActor::getVelY(){
	b2Vec2 velocity = body->GetLinearVelocity();
	return velocity.y;	
}
void bgActor::setVelocity(float vx, float vy){
	const b2Vec2 velocity(vx,vy);
	body-> SetLinearVelocity(velocity);
};
void bgActor::accelerateBy(float vx, float vy){
	b2Vec2 velocity = body->GetLinearVelocity();
	velocity.x += vx;
	velocity.y += vy;
	body->SetLinearVelocity(velocity);
}
b2Body* bgActor::getBody(){
	return body;
}
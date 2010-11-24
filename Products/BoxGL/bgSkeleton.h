/*
 *  bgSkeleton.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/15/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef BGSKELETON_H
#define BGSKELETON_H
#include "Box2D.h"
#include "bgBone.h"
#include "bgComplexBody.h"

#define SKELETON_MAX_BONES 64

class bgSkeleton : public bgActor{

public:
	//constructors etc...
	bgSkeleton(b2World *world);
	virtual ~bgSkeleton();	
	
	//manipulation
	void bgSkeleton::setOrigin(float x, float y);
	
	//modification
	void bgSkeleton::makeJoint(bgBone * parent, bgBone * child, b2Vec2 pt, int type);
	void bgSkeleton::addBone(int cxn, float length);
	
	//time step
	void bgSkeleton::timeStep();
	
	//control
	void bgSkeleton::setJointSpeed(int idx, float speed);	
	void bgSkeleton::setJointProgram(int idx, int program);
	void bgSkeleton::executeAllJointPrograms();
	void bgSkeleton::executeOneJointProgram(int idx);	
	
	//accessors
	b2RevoluteJoint * bgSkeleton::getRevoluteJoint(unsigned bone);
	int bgSkeleton::getNumBones();
	bool hasJoint(unsigned bone);
	bgBone * getBoneAtIndex(unsigned int i);
	
	//other
	virtual void bgSkeleton::draw();
	
protected:
	b2Vec2 origin;
	vector <bgBone *> bones;	
	vector <bool> boneHasJoint;
	
	int jointPrograms[SKELETON_MAX_BONES];
	
	//two bookeeping variables... both are used for timing.
	int jointItrs[SKELETON_MAX_BONES];
	unsigned timesteps;
	
	float joint_max_torque;
	float joint_max_speed;
	float joint_itr_timescale;

};
#endif
/*
 *  bgSkeleton.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/15/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "bgBone.h"
#include "bgSkeleton.h"
#include "GLIDL.h"
#include "iostream"
bgSkeleton::bgSkeleton(b2World * newWorld):bgActor(newWorld){
	timesteps = 0;
	origin.x = rand() % 10;
	origin.y = 10;
	for ( int i = 0 ; i < SKELETON_MAX_BONES ; i++){
		jointPrograms[i] = 0;
		jointItrs[i] = 0;
	}
	joint_itr_timescale = 1;
	joint_max_torque = 20000;
	joint_max_speed = 15.0;
}
bgSkeleton::~bgSkeleton(){
	
}
void bgSkeleton::setOrigin(float x, float y){
	origin.x = x;
	origin.y = y;
}	
int bgSkeleton::getNumBones(){
	return bones.size();
}
bool bgSkeleton::hasJoint(unsigned bone){
	return boneHasJoint[bone];
}
bgBone * bgSkeleton::getBoneAtIndex(unsigned int i){
	return bones[i];
}
void bgSkeleton::makeJoint(bgBone * parent, bgBone * child, b2Vec2 pt, int type){

	b2RevoluteJointDef jointDef;
	jointDef.Initialize(parent->getBody(),child->getBody(),pt);
	jointDef.lowerAngle = -0.4f * b2_pi; // -90 degrees
	jointDef.upperAngle = 0.4f * b2_pi; // 45 degrees
	jointDef.enableLimit = true;
	jointDef.maxMotorTorque =joint_max_torque;
	jointDef.motorSpeed = joint_max_speed;
	jointDef.enableMotor = true;
	child->setJoint( world->CreateJoint(&jointDef) );
}
void bgSkeleton::draw(){
	int n = bones.size();
	for(int j = 0 ; j < n ; j++){
		bones[j]->draw();
	}
}
void bgSkeleton::addBone(int cxn, float length){

	if (bones.size() >= SKELETON_MAX_BONES) {
		printf("tried to add more than the allowed number of bones \n");
		return;
	}
	
	int oldIdx = bones.size()-1 -cxn;
	bgBone * newBone = new bgBone(world);
	newBone->makeBoneInWorld((float)length);
	boneHasJoint.push_back(false);
	
	bgBone * oldBone;
	b2Vec2 startPos;
	if(oldIdx <0){
		if(bones.size() == 0){oldBone = NULL;} else {oldBone = bones[0];}
		if(oldBone == NULL){
			startPos = b2Vec2(origin.x,origin.y);
		} else{
			startPos = oldBone->createStartInWorldCoordinates();
		}
	} else {
		oldBone = bones[oldIdx];
		startPos =oldBone->createEndInWorldCoordinates();
	}
	newBone->setStartPostion(startPos.x, startPos.y);

	if(oldBone != NULL){
		makeJoint(oldBone,newBone,startPos,0);
		boneHasJoint[bones.size()] = true;			
	} 
	bones.push_back(newBone);
}

//time step
void bgSkeleton::timeStep(){
	executeAllJointPrograms();
	timesteps++;
}

//Control methods...
void bgSkeleton::setJointSpeed(int idx, float speed){
	if(idx == - 1){
		for(int i = 0 ; i < getNumBones() ; i++){
			setJointSpeed(idx,speed);
		}
	} else {
		if( hasJoint(idx)){
			b2RevoluteJoint * joint = getRevoluteJoint(idx);
			joint->SetMotorSpeed(speed);
		}
	}
	
}	
b2RevoluteJoint * bgSkeleton::getRevoluteJoint(unsigned bone){
	return (b2RevoluteJoint *) bones[bone]->joint;
};

void bgSkeleton::setJointProgram(int idx, int program){
	if (idx >= SKELETON_MAX_BONES){
		printf("tried to access a greater joint index than is available \n");
		return;
	}
	jointPrograms[idx] = program;
}
void bgSkeleton::executeAllJointPrograms(){
	for (int idx = 1 ; idx < bones.size() ; idx++){
		executeOneJointProgram(idx);
	}
}
void bgSkeleton::executeOneJointProgram(int idx){
	if (!hasJoint(idx)){
		printf("No Joint!");
		return;
	}
	jointItrs[idx] += 1;
	float jointItr = jointItrs[idx];
	b2RevoluteJoint * joint =(b2RevoluteJoint *)bones[idx]->joint;
	float time = joint_itr_timescale * jointItr;
	
	switch (jointPrograms[idx]) {
		case 0:
			joint->SetMotorSpeed(0);
			break;
		case 1:
			joint->SetMotorSpeed(joint_max_speed * sin(time));
			break;
		default:
			break;
	}
}
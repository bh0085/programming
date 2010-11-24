/*
 *  bgSkeleton.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/15/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "bgHeaders.h"
class bgBone;

bgSkeleton::bgSkeleton(b2World * newWorld){
	world = newWorld;
	origin.x = -8.0;
	origin.y = 2.5;

}
int bgSkeleton::getNumBones(){
	return bones.size();
}

bgBone * bgSkeleton::getBoneAtIndex(unsigned int i){
	return bones[i];
}

void bgSkeleton::makeJoint(bgBone * parent, bgBone * child, b2Vec2 pt, int type){

	b2RevoluteJointDef jointDef;
	jointDef.Initialize(parent->getBody(),child->getBody(),pt);
	jointDef.lowerAngle = -0.5f * b2_pi; // -90 degrees
	jointDef.upperAngle = 0.25f * b2_pi; // 45 degrees
	//jointDef.enableLimit = true;
	jointDef.maxMotorTorque = 2000.0f;
	jointDef.motorSpeed = 10.0f;
	jointDef.enableMotor = true;
	child->setJoint( world->CreateJoint(&jointDef) );
	
	
	/*
	 b2PrismaticJointDef jointDef;
	 b2Vec2 worldAxis(1.0f, 0.0f);
	 jointDef.Initialize(oldBone->getBody(),newBone->getBody(),endPt, worldAxis);
	 jointDef.lowerTranslation = -.2f;
	 jointDef.upperTranslation = .2f;
	 jointDef.enableLimit = true;
	 jointDef.maxMotorForce = 1.0f;
	 jointDef.motorSpeed = 0.0f;
	 jointDef.enableMotor = true;
	 b2PrismaticJoint * joint = (b2PrismaticJoint *)world->CreateJoint(&jointDef);
	 joint->SetMotorSpeed(1.0f);
	 //joint->SetMotorForce(1.0f);
	 */	
}

void bgSkeleton::addBone(int cxn, int length, int joint){

	int oldIdx = bones.size()-1 -cxn;
	bgBone * newBone = new bgBone(world);
	newBone->makeBoneInWorld((float)length);
	if(oldIdx < 0) {
		newBone->setStartPostion(origin.x, origin.y);
		if(bones.size() != 0){
			b2RevoluteJointDef jointDef;
			bgBone * oldBone = bones[0];
			b2Vec2 endPt = oldBone->createStartInWorldCoordinates();
			makeJoint(oldBone,newBone,endPt,0);
			//delete(&endPt);
		}
	} else {
		bgBone * oldBone = bones[oldIdx];
		b2Vec2 endPt = oldBone->createEndInWorldCoordinates();
		newBone->setStartPostion(endPt.x +0.0,endPt.y);
		makeJoint(oldBone,newBone,endPt,0);
		//delete(&endPt);
	}
	bones.push_back(newBone);
}
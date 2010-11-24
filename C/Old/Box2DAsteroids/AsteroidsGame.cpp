/*
 *  Asteroids.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <iostream>
#include <stdio.h>
#include "AsteroidsGame.h"
#include "GLIDL.h"
#include "bgHeaders.h"
#include "GridMoverNN.h"
#include "SigmoidUnit.h"
#include "NeuralNet.h"
#include "GridLearner2D.h"
#include "ReinforcementLearnerAction.h"


AsteroidsGame::AsteroidsGame(){
	//set world bounds and gravity
	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(100.0f, 100.0f);	
	b2Vec2 gravity(0.0f, -100.0f);
	bool doSleep = true;
	world = new b2World(worldAABB, gravity, doSleep);

	actors.push_back(new bgActor(world));
	actors[0]->makeStaticGroundInWorld(50.0,2.0);
	actors[0]->setAngle(.1f);
	
	actors.push_back(new bgActor(world));
	actors[1]->makeBoxInWorld(1.0f,1.0f);
	actors[1]->setPosition(-1.0f,4.4f);
	actors[1]->setAngle(.5f);
	
	actors.push_back(new bgActor(world));
	actors[2]->makeBoxInWorld(1.0f,1.0f);
	actors[2]->setPosition(-3.0f,4.4f);
	actors[2]->setAngle(.5f);	


	b2Body * b1 = actors[1]->getBody();
	b2Body * b2 = actors[2]->getBody();
	
	
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(b1,b2,b1->GetWorldCenter());
	jointDef.lowerAngle = -0.5f * b2_pi; // -90 degrees
	jointDef.upperAngle = 0.25f * b2_pi; // 45 degrees
	jointDef.enableLimit = true;
	jointDef.maxMotorTorque = .02f;
	jointDef.motorSpeed = 0.0f;
	jointDef.enableMotor = true;
	b2Joint * joint = world->CreateJoint(&jointDef);
	
	geneStream gs;
	makeByteStream(&gs);
	readByteStream(&gs, this);
	/*
	actors.push_back(new bgBone(world));
	actors.push_back(new bgBone(world));
	((bgBone *)actors[3])->makeBoneInWorld(3.0);
	((bgBone*)actors[4])->makeBoneInWorld(3.0);
	actors[3]->setPosition(0.0,4.0);
	actors[4]->setPosition(3.1,4.0);
	((bgBone *)actors[3])->clipChildWithRotateJoint((bgBone *)actors[4]);
	 */
	
	
};


void makeByteStream(geneStream * gs){
	gs->byteCushion = 10;
	gs->nGenes = 15;
	gs->maxGenes = MAX_GENES;
	gs->nBytes = N_BYTES;

	
	for(int i = 0 ; i <gs->nGenes; i++){
		int byte = gs->nBytes*i;
		//first create the blank cushion
		byte+=gs->byteCushion;
		//now instruct the current gene to connect to the gene one previous
		gs->stream[byte++]=rand() % 1;
		//this byte describes the length of the bone expressed by the gene
		gs->stream[byte++]=1;
		//now designate motor type,0 revolute, 1 prismatic
		gs->stream[byte++]=0;
		
	}
}

void readByteStream(geneStream * gs, AsteroidsGame * game){
	bgSkeleton * skeleton = game->makeSkeleton();
	for(int i = 0 ; i < gs->nGenes ; i++){
		int byte = gs->nBytes*i;
		//offset by the blank cushion
		byte+=10;
		unsigned char cxn = gs->stream[byte++];
		unsigned char length = gs->stream[byte++];
		unsigned char joint = gs->stream[byte++];
		skeleton->addBone(cxn,length,joint);
	}
}

bgSkeleton * AsteroidsGame::makeSkeleton(){
	skeleton =( new bgSkeleton(world) );
	return skeleton;
}


void AsteroidsGame::timeStep(){
	// Prepare for simulation. Typically we use a time step of 1/60 of a
	// second (60Hz) and 10 iterations. This provides a high quality simulation
	// in most game scenarios.
	float32 timeStep = 1.0f / 60.0f;
	int32 iterations = 10;
	

	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(timeStep, iterations);
		
	b2Body* body = world->GetBodyList();
	//body = body->GetNext();	
	
	// Now print the position and angle of the body.
	b2Vec2 position = body->GetPosition();
	float32 angle = body->GetAngle();
	/*
	int i;
	for( i = 0 ;i < actors.size() ; i++){
		unsigned int plotArr = getEmptyArray();
		
		GLIColorOrange(plotArr);
		GLIPlotStyleLineLoop(plotArr);		
		vector <b2Vec2 *> verts;
		actors[i]->createAndReturnWorldVertsInVector(&verts);
		for(int j = 0 ; j < verts.size(); j ++){
				GLIPlot3f(plotArr, verts[j]->x*10, verts[j]->y*10, 0);
		}
	}
	
	int n = skeleton->getNumBones();

	for(int j = 0 ; j < n ; j++){
		vector <b2Vec2*> verts;
		unsigned int plotArr = getEmptyArray();
		GLIColorOrange(plotArr);
		GLIPlotStyleLineLoop(plotArr);

		skeleton->getBoneAtIndex(j)->createAndReturnWorldVertsInVector(&verts);
		for(int k = 0 ; k < verts.size(); k ++){
			GLIPlot3f(plotArr, verts[k]->x*10, verts[k]->y*10, 0);
		}		
	}
	
	
	GLIFlush();
	 */
		

	
}
b2World * AsteroidsGame::getWorld(){
	return world;
}


AsteroidsGame::~AsteroidsGame(){
	delete(world);
	delete(skeleton);
	//delete(&actors);
}


extern "C" AsteroidsGame* makeGame(GLIController * c){	
	
	GridLearner2D learner;	
	for (int i = 0 ; i < 10; i++){
		learner.trainingRun();
	}
	AsteroidsGame * game = new AsteroidsGame();
	return game;
}
extern "C" void destroyGame(AsteroidsGame * game){
	delete(game);
}
extern "C" void gameTimeStep(AsteroidsGame * game){
	game->timeStep();
}
extern "C" void asteroidsCommandLeft(AsteroidsGame * game, float constant){
	b2Body* body = game->getWorld()->GetBodyList();
	b2Vec2 force(constant*-800.0f,0.0f);
	body->ApplyForce( force, body->GetWorldCenter());
}
extern "C" void asteroidsCommandRight(AsteroidsGame * game, float constant){
	b2Body* body = game->getWorld()->GetBodyList();
	b2Vec2 force(constant*800.0f,0.0f);
	body->ApplyForce( force, body->GetWorldCenter());
}
extern "C" void asteroidsCommandDown(AsteroidsGame * game, float constant){
	b2Body* body = game->getWorld()->GetBodyList();
	body->ApplyTorque( constant*700.0f);
}
extern "C" void asteroidsCommandUp(AsteroidsGame * game, float constant){
	b2Body* body = game->getWorld()->GetBodyList();
	b2Vec2 force(0.0f,constant*50.0f);
	body->ApplyForce( force, body->GetWorldCenter());
}

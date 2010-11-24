/*
 *  CPSimulation.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef CPSIMULATION_H
#define CPSIMULATION_H

#define PI 3.14159f
#define N_ANGLE 30 + 2
#define N_OMEGA 40 + 2
#define N_BINS N_ANGLE + N_OMEGA
#define ANGLE_MAXABS PI/4
#define OMEGA_MAXABS PI



#ifdef __cplusplus
#include "Box2d.h"
#include "GLISim.h"
typedef struct CPStateStruct {
	//environmental state
	float xe [2];
	//decoded state
	int x [N_BINS];
	
	//filtered eligibility
	float e [N_BINS];
	//filtered membership
	float xBar [N_BINS];
	
	//ASE weights
	float w [N_BINS];
	//ACE weights
	float v [N_BINS];

	//ASE output
	float u;
	//ACE product
	float p;
	//ASE output
	float rHat;
	
	//environmental reward function
	float r;
} CPState;
class CPSimulation: public GLISim{
private:
	CPState state;
	CPState oldStates[2];
	b2World * world;
	b2Body * cart;
	b2Body * pole;
	vector <bgActor *> actors;

	void netStep(float envOut[3], float * netOut);
	void envStep(float envOut[3], float * netOut);
	void reset();
	void CPSimulation::draw();

public:
	CPSimulation();
	void step();
};
#else
typedef struct CPSimulation CPSimulation;
#endif

#ifdef __cplusplus
extern "C" {
#endif
	
	
	CPSimulation * CPMakeSimulation();
	void CPDestroySimulation(CPSimulation * sim);
	void CPStep(CPSimulation * sim);
	
#ifdef __cplusplus
}
#endif

#endif
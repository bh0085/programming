/*
 *  CPSimulation.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "Box2d.h"
#include "bgActor.h"
#include "CPSimulation.h"
#include "GLIDL.h"
#include "OpenGL/OpenGL.h"
#include <math.h>
#include "MyCIDL.h"
#include "Kohonen1D.h"
#include "BitArray.h"
#include "GA0.h"

#define DELTA .85f  //eligibility decay constant
#define ALPHA .4f //action learning rate
#define NOISE_ABS .1f
#define LAMBDA .85f //xbar decay
#define BETA .2f  //critic learning rate
#define GAMMA .8f  //time horizon

#define ACTION_MAXABS 1

static int anglelast;
static int omegalast;
static float xBounds[2] = {-8.0,8.0};
static float yBounds[2] = {-1,15};
static int failures = 0;
static Kohonen1D kNet;
static GA0 ga;
CPSimulation::CPSimulation(){
	
	kNet = Kohonen1D();
	kNet.initToTube();
	rand();
	srand ( (unsigned)time ( NULL ) );
	state.xe[0] = 0.0;
	state.xe[1] = 0.0;
	
	state.u = 0.0;
	state.p = 0;
	state.rHat = 0;
	state.r = 0;
		
	

	for (int i = 0 ; i < N_BINS ; i++){
		state.x[i] = 0;
		state.w[i] = 0;
		state.v[i] = 0;
		state.e[i] = 0;
		state.xBar[i] = 0;
	}
	
	int anglebin = state.xe[0] * ((N_ANGLE - 1)/2 ) / (ANGLE_MAXABS) + ((N_ANGLE - 1)/2);
	//0 maps to bin (N_ANGLE -1)/2
	//-ANGLE_MAXABS maps to bin 0
	// ANGLE_MAXABS maps to bin N_ANGLE-1
	
	int omegabin = N_ANGLE + state.xe[1] * ((N_OMEGA - 1)/2 ) / (OMEGA_MAXABS) + ((N_OMEGA - 1)/2);
	state.x[anglebin] = 1;
	state.x[omegabin] = 1;
		
	for (int i = 0 ; i < 2 ; i ++){
		oldStates[i] = state;
	}
	
	//now begins the environment initialization:
	//set world bounds and gravity
	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(100.0f, 100.0f);	
	b2Vec2 gravity(0.0f, -50.0f);
	bool doSleep = true;
	world = new b2World(worldAABB, gravity, doSleep);
	
	actors.push_back(new bgActor(world));
	actors[0]->makeStaticGroundInWorld(200.0,2.0);
	actors[0]->setPosition(0.0f,-2.0f);

	actors[0]->setAngle(0.0f);
	
	actors.push_back(new bgActor(world));
	actors[1]->makeBoxInWorld(1.0f,1.0f);
	actors[1]->setPosition(0.0f,0.0f);
	actors[1]->setAngle(0.0f);
	
	actors.push_back(new bgActor(world));
	actors[2]->makeBoxInWorld(.1f,5.0f);
	actors[2]->setPosition(0.0,3.5);
	actors[2]->setAngle(0.0);	
	
	b2Body * b1 = actors[1]->getBody();
	b2Body * b2 = actors[2]->getBody();
	cart = b1;
	pole = b2;
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(b1,b2,b1->GetWorldCenter());
	b2Joint * joint = world->CreateJoint(&jointDef);	


}
void CPSimulation::draw(){
	window(0);
	GLIDLSetPSym(-1);
	float bounds[6] = {xBounds[0],xBounds[1],yBounds[0],yBounds[1],-10,20};
	GLIDLSetViewBoundsWithMargin(bounds,0.0);	
	glClearColor(0,0,0,0);
	GLIDLClear();
	GLIDLLabelAxes();
	for( int i = 0 ;i < actors.size() ; i++){
		vector <b2Vec2 *> verts;
		actors[i]->createAndReturnWorldVertsInVector(&verts);
		int size = verts.size();
		float xs[size];
		float ys[size];
		for(int j = 0 ; j < size; j ++){
			xs[j] = verts[j]->x;
			ys[j] = verts[j]->y;
		}
		oplot2f(xs, ys, size);
	}
	GLIDLFlushBuffer();

	int xy[2] = {100,550};
	int size[2] = {400,300};	
	
	 windowAtXYWithSize(1, xy, size);
	 GLIDLSetScanWidth(30);
	 if( get_scan_x() == -1.0) GLIDLClear();
	 bounds[0] = -1;
	 bounds[1] = 31;
	 bounds[2] = -5;
	 bounds[3] = 5;
	 GLIDLSetViewBoundsWithMargin(bounds,.3);	
	 glClearColor(0,0,0,0);
	 //GLIDLClear();
	 GLIDLSetPSym(-1);
	glColor3d(1, 1, 1);	 
	splot1f(state.p*3);
	glColor3d(0, 0, 1);
	splot1f(state.rHat*3);	
	glColor3d(0, 1, 0);
	splot1f(state.v[omegalast]*3);
	 splot_increment();
	  
	 
	 GLIDLFlushBuffer();
	  
	 
	 xy[0] = 550;
	 xy[1] = 100;
	 
	 windowAtXYWithSize(2, xy, size);
	 bounds[0] = -1;
	 bounds[1] = N_BINS;
	 bounds[2] = -3;
	 bounds[3] = 3;	
	 GLIDLSetViewBoundsWithMargin(bounds,0);	
	 GLIDLClear();
	 float xaxis[N_BINS];
	 findgen(xaxis, N_BINS);
	 GLIDLSetPSym(-1);	
	glColor3d(1, 1, 1);

	oplot2f(xaxis, state.v, N_BINS);
	glColor3d(1, 0, 0);
	oplot2f(xaxis, state.w, N_BINS);
	GLIDLFlushBuffer();

	xy[0] = 550;
	xy[1] = 500;	
	/*
	windowAtXYWithSize(3, xy, size);
	bounds[0] = -1;
	bounds[1] = N_BINS;
	bounds[2] = -3;
	bounds[3] = 3;	
	GLIDLSetViewBoundsWithMargin(bounds,.3);	
	GLIDLClear();
	findgen(xaxis, N_BINS);
	GLIDLSetPSym(-1);	
	glColor3d(1, 0, 0);
	oplot2f(xaxis, state.xBar, N_BINS);
	glColor3d(1, 1, 0);
	oplot2f(xaxis, state.e, N_BINS);
	GLIDLFlushBuffer();
	 */

	xy[0] = 800;
	xy[1] = 200;	
	size[0] = 600;
	size[1] = 600;
	 
	windowAtXYWithSize(4, xy, size);	
	
	for(int i = 0 ; i < 1000 ; i++){
		kNet.iterate();
	}
	kNet.draw();	
	
	ga.iterate();
	window(8);
	ga.draw();

	
	
}
void CPSimulation::reset(){
	state.xe[0] = 0.0;
	state.xe[1] = 0.0;
	
	state.u = 0;
	state.p = 0;
	state.rHat = 0;
	state.r = 0;
	
	
	for (int i = 0 ; i < N_BINS ; i++){
		state.x[i] = 0;
		state.e[i] = 0;
		state.xBar[i] = 0;
	}
	
	int anglebin = state.xe[0] * ((N_ANGLE - 1)/2 ) / (ANGLE_MAXABS) + ((N_ANGLE - 1)/2);
	//0 maps to bin (N_ANGLE -1)/2
	//-ANGLE_MAXABS maps to bin 0
	// ANGLE_MAXABS maps to bin N_ANGLE-1
	
	int omegabin = N_ANGLE + state.xe[1] * ((N_OMEGA - 1)/2 ) / (OMEGA_MAXABS) + ((N_OMEGA - 1)/2);
	state.x[anglebin] = 1;
	state.x[omegabin] = 1;
	
	for (int i = 0 ; i < 2 ; i ++){
		oldStates[i] = state;
	}
	



	actors[1]->setPosition(0.0f,0.0f);
	actors[1]->setAngle(0.0f);
	actors[1]->setOmega(0.0);
	actors[1]->setVelocity(0.0,0.0);
	

	actors[2]->setPosition(0.0,3.5);
	actors[2]->setAngle(0.0);	
	actors[2]->setOmega(0.0);
	actors[2]->setVelocity(0.0,0.0);
 
	
}
void CPSimulation::step(){
	float envOut[3];
	float netOut = state.u;
	envStep(envOut, & netOut);	
	netStep(envOut, & netOut);
	
	if(envOut[2] == -1 ) failures++;
	if(failures > 1) {
		reset();
		failures = 0;
	}

	draw();
	
	
}
void CPSimulation::netStep(float envOut[3], float * netOut){
	oldStates[1] = oldStates[0];
	oldStates[0] = state;
	
	state.r = envOut[2];
	
	state.xe[0] = envOut[0];
	state.xe[1] = envOut[1];
	
	for (int i = 0 ; i < N_BINS ; i++){
		state.x[i] = 0;
	}

	int anglebin = state.xe[0] * ((N_ANGLE - 1)/2 ) / (ANGLE_MAXABS) + ((N_ANGLE - 1)/2);
	//0 maps to bin (N_ANGLE -1)/2
	//-ANGLE_MAXABS maps to bin 0
	// ANGLE_MAXABS maps to bin N_ANGLE-1
	int omegabin =state.xe[1] * ((N_OMEGA - 1)/2 ) / (OMEGA_MAXABS) + ((N_OMEGA - 1)/2);
	
	if(anglebin < 0 ) anglebin = 0;
	if(anglebin >= N_ANGLE) anglebin = N_ANGLE-1;
	anglelast = anglebin;
	if(omegabin <0 ) omegabin = 0;
	if(omegabin >= N_OMEGA) omegabin = N_OMEGA -1;
	omegabin += N_ANGLE;
	omegalast = omegabin;
	state.x[anglebin] = 1;
	state.x[omegabin] = 1;

	
	for (int i = 0 ; i < N_BINS ; i++){
		state.xBar[i] = oldStates[0].xBar[i] * LAMBDA + ( 1.0 - LAMBDA) * oldStates[0].x[i];
		state.e[i] = oldStates[0].e[i] * DELTA + (1.0 - DELTA) * oldStates[0].x[i] * oldStates[0].u;
		state.w[i] = oldStates[0].w[i] + ALPHA * oldStates[0].rHat * oldStates[0].e[i];
		state.v[i] = oldStates[0].v[i] + BETA * oldStates[0].rHat * oldStates[0].xBar[i];
	}
	
	float uSum = 0;
	for (int i = 0 ; i < N_BINS ; i++){
		uSum += state.w[i]*state.x[i];
	}
	float noise = ((float)(rand() %  1000)) *2 * NOISE_ABS /1000.0 - NOISE_ABS;
	uSum += noise;
	//float uProb = (1 / (1+ exp(-1 * (uSum / .3))));
	//float uClamped = uProb - ( (float) (rand() % 1000))/1000;
	if(uSum <= 0){state.u = -1;} else {state.u = 1;}
	
	float pSum = 0;
	for ( int i = 0 ; i < N_BINS ; i++){
		pSum += state.v[i] * state.x[i];	
	}
	state.p = pSum;
	state.rHat = state.r  + GAMMA * oldStates[0].p - oldStates[1].p;
	
	
	(*netOut) =state.u;

}
void CPSimulation::envStep(float envOut[3], float * netOut){
	float constant = 200.0;
	b2Vec2 force(constant * (*netOut),0.0f);
	cart->ApplyForce( force, cart->GetWorldCenter());		
	// Prepare for simulation. Typically we use a time step of 1/60 of a
	// second (60Hz) and 10 iterations. This provides a high quality simulation
	// in most game scenarios.
	float32 timeStep = 1.0f / 60.0f;
	int32 iterations = 10;
	
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	float v[2] = { -1*.2 * actors[1]->getVelX(), 0};
	actors[1]->accelerateBy(v[0],v[1]);
	actors[2]->accelerateBy(v[0],v[1]);

	world->Step(timeStep, iterations);
	
	
	float xWidth = xBounds[1] - xBounds[0];
	if(actors[1]->getX() < xBounds[0]){
		actors[1]->moveBy(xWidth,0);
		actors[2]->moveBy(xWidth,0);
	}
	if(actors[1]->getX() > xBounds[1]){
		actors[1]->moveBy(-xWidth,0);
		actors[2]->moveBy(-xWidth,0);
	}
	
	float angle = pole->GetAngle();
	float omega = pole->GetAngularVelocity();
	float reward = 0;
	if( absf(angle) >= PI/4) reward = -1.0;
	//if( absf(angle) <= PI/25) reward = .02;
	//if( absf(angle - PI/10) <= PI/10) reward = .05;
	//if( absf(angle + PI/10) <= PI/10) reward = -.05;
	envOut[0] = angle;
	envOut[1] = omega;
	envOut[2] = reward;
	
}

extern CPSimulation * CPMakeSimulation(){
	CPSimulation * sim = new CPSimulation();
	return sim;
}
extern void CPDestroySimulation(CPSimulation * sim){
	delete sim;
}
extern void CPStep(CPSimulation * sim){
	sim->step();
}
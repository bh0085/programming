/*
 *  CPSimulation.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "GLISim.h"
void GLISim::initialize(){}
GLISim::GLISim(){}
GLISim::~GLISim(){};
void GLISim::draw(){
}
void GLISim::reset(){
}
void GLISim::step(){
}

extern GLISim * GLISimMakeSimulation(){
	return new GLISim();
}
void GLISimInitSimulation(GLISim * sim){
	sim->initialize();
};

extern void GLISimDestroy(GLISim * sim){
	delete sim;
}
extern void GLISimStep(GLISim * sim){
	sim->step();
}
extern void GLISimDraw(GLISim * sim){
	sim->draw();
}
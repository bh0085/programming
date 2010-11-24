/*
 *  Vacuum.h
 *  Vacuum_World
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef HEADERS_LOADED
#define HEADERS_LOADED
#include "Shared_Headers.h"
#endif
#ifndef ENVIRONMENT
#define ENVIRONMENT
#include "Environment.h"
#endif
#ifndef VACUUM
#define VACUUM
#include "Vacuum.h"
#endif

using namespace std;
class Vacuum{
private:
	unsigned int currentSquare;
	Environment * myEnvironment;
	
	//spaces that the vacuum has seen clean
	vector < unsigned int > sawClean;
	
	//vacuum properties
	bool isLazy;
	bool isDirty;	
	
public: 
	Vacuum(Environment * e);
	~Vacuum();

	//Custom settings for our vacuum...
	//is it a lazy vacuum? a dirty vacuum?
	void Vacuum::setLazy();
	void Vacuum::setDirty();
	
	//Called by the main thread ... one simulation time step.
	void act();
	
	void moveTo(unsigned int newSquare);
	void print_XY();
};
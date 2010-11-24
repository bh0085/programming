/*
 *  Environment.h
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

//World maxiumum isze parameters
#define WORLD_MAX_X 10
#define WORLD_MAX_Y 10

using namespace std;

class Environment{
public:
	int squares[WORLD_MAX_X +1][WORLD_MAX_Y+1];
	int nDirty;
	
public:
	Environment();
	~Environment();
	
	//functions to initialize the environment
	void init_Dirty_Square_World_Of_Size(unsigned int x,unsigned int y);
	void init_Mixed_Square_World_Of_Size(unsigned int x,unsigned int y);
	
	//Called by agent to determine whether square is dirty or not
	bool isDirty(unsigned int x, unsigned int y);
	
	//Public functions to change the environment
	void makeClean(unsigned int x, unsigned int y);
	void makeDirty(unsigned int x, unsigned int y);
	
	//Called by vacuum placement function
	unsigned int get_Start_Index();
	
	//Called by vacuum to find possible moves
	void get_Possible_Move_Indices(unsigned int index, vector < unsigned int> * moves);
	
	//Translates from IDX to XY
	 int get_X_From_Index(unsigned int index);
	 int get_Y_From_Index(unsigned int index);
									
	//performance measure
	float Environment::getPercentCleaned();
	unsigned int Environment::getNumberCleaned();
										
	
	//Functions to translate indices not yet implemented or needed
	//since the vacuum is provided with a list of indices and makes
	//a random choice.
	
	/*
	void move_Left(unsigned int index);
	void move_Right(unsigned int index);
	void move_Up(unsigned int index);
	void move_Down(unsigned int index);
	 */
		
	
};

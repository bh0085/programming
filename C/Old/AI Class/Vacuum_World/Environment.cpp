/*
 *  Environment.cpp
 *  Vacuum_World
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef ENVIRONMENT
#define ENVIRONMENT
#include "Environment.h"
#endif

using namespace std;

Environment::Environment(){}
Environment::~Environment(){}

void Environment::init_Dirty_Square_World_Of_Size(unsigned int x, unsigned int y){
	if( x > WORLD_MAX_X) x = WORLD_MAX_X;
	if( y > WORLD_MAX_Y) y = WORLD_MAX_Y;
	nDirty = 0;
	for(int i = 0 ; i < x ; i++){
		for(int j = 0 ; j < y ; j++){
			squares[i][j] = 1;
			if(squares[i][j] ==1) nDirty++;
		}
	}
}
void Environment::init_Mixed_Square_World_Of_Size(unsigned int x, unsigned int y){
	if( x > WORLD_MAX_X) x = WORLD_MAX_X;
	if( y > WORLD_MAX_Y) y = WORLD_MAX_Y;
	for(int i = 0 ; i < x ; i++){
		for(int j = 0 ; j < y ; j++){
			unsigned int r = (rand() % 2) +1;
			squares[i][j] = r;
			if(squares[i][j] ==1) nDirty++;
		}
	}
}
bool Environment::isDirty(unsigned int x, unsigned int y){
	if(squares[x][y] == 1) return true; else return false;
}

void Environment::makeClean(unsigned int x, unsigned int y){
	squares[x][y] = 2;
}
void Environment::makeDirty(unsigned int x, unsigned int y){
	squares[x][y] = 1;
}

unsigned int Environment::get_Start_Index(){
	for(int i = 0; i < WORLD_MAX_X ; i++){
		for(int j = 0 ; j < WORLD_MAX_Y ; j++){
			if(squares[i][j] != 0){
				return i + j * WORLD_MAX_X;
			}
		}
	}
	return 0;
}
int Environment::get_X_From_Index(unsigned int index){
	return index % WORLD_MAX_X;
}
int Environment::get_Y_From_Index(unsigned int index){
	return index / WORLD_MAX_X;
}
unsigned int index_From_XY( int x,  int y){
	return (x + y * WORLD_MAX_X);
}

void Environment::get_Possible_Move_Indices(unsigned int index,vector <unsigned int> * moves){
	int x = get_X_From_Index(index);
	int y = get_Y_From_Index(index);
	if(y - 1 >= 0){
		if(squares[x,y-1] != 0){
			(*moves).push_back(index_From_XY(x,y-1));
		}
	}
	if(y + 1 <= WORLD_MAX_Y){
		if(squares[x,y+1] != 0){
			(*moves).push_back(index_From_XY(x,y+1));
		}
	}
	if(x - 1 >= 0){
		if(squares[x-1,y-1] != 0){
			(*moves).push_back(index_From_XY(x-1,y));
		}
	}
	if(x + 1 <= WORLD_MAX_X){
		if(squares[x+1,y] != 0){
			(*moves).push_back(index_From_XY(x+1,y));
		}
	}
}

float Environment::getPercentCleaned(){
	int dirtyNow = 0;
	for (int i = 0 ; i < WORLD_MAX_X ; i++){
		for(int j = 0 ; j < WORLD_MAX_Y ; j++){
			if (squares[i][j] == 1) dirtyNow++;
		}
	}
	return 100*(1 -((float)dirtyNow)/((float)nDirty));
}
unsigned int Environment::getNumberCleaned(){
	int dirtyNow = 0;
	for (int i = 0 ; i < WORLD_MAX_X ; i++){
		for(int j = 0 ; j < WORLD_MAX_Y ; j++){
			if (squares[i][j] == 1) dirtyNow++;
		}
	}
	return (nDirty - dirtyNow);
}




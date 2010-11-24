/*
 *  Vacuum.cpp
 *  Vacuum_World
 *
 *  Created by Benjamin Holmes on 7/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef VACUUM
#define VACUUM
#include "Vacuum.h"
#endif
#include <iostream>

Vacuum::Vacuum(Environment * e){
	isLazy = false;
	isDirty = false;
	myEnvironment = e;
	currentSquare = myEnvironment->get_Start_Index();
}
Vacuum::~Vacuum(){}

void Vacuum::print_XY(){
	printf("%i,%i \n",myEnvironment->get_X_From_Index(currentSquare),
		   myEnvironment->get_Y_From_Index(currentSquare));
}
void Vacuum::moveTo(unsigned int newSquare){
	currentSquare = newSquare;
}

void Vacuum::setLazy(){
	isLazy = true;
}
void Vacuum::setDirty(){
	isDirty = true;
}

void Vacuum::act(){
	unsigned int currx = myEnvironment->get_X_From_Index(currentSquare);
	unsigned int curry = myEnvironment->get_Y_From_Index(currentSquare);
	
	if((myEnvironment->isDirty(currx, curry)) ){
			myEnvironment->makeClean(currx, curry);
	} else {
		
		sawClean.push_back(currentSquare);		
		vector <unsigned int> moves;
		myEnvironment->get_Possible_Move_Indices(currentSquare,&moves);
		
		for(int i = 0 ; i < moves.size(); i ++){
			if(sawClean.size() == 0){
				moveTo(moves[i]);
				break;
			} else { 
				//check to see if the current square is clean...
				bool foundClean = false;
				for(int j =0 ; j < sawClean.size() ; j++){
					if(sawClean[j] == moves[i]){foundClean = true;}
				}
				//now decide whether the cleanliness of the square makes it desirable
				bool gotoSquare = false;
				if(isLazy  & foundClean) gotoSquare = true;
				if(!isLazy & !foundClean) gotoSquare = true;
				
				if(gotoSquare){
					if(isDirty) myEnvironment->makeDirty(currx,curry);
					moveTo(moves[i]);
					break;
				}				
			}
			
			//none of the squares have seemed particularly appealing... so just go to a random square
			if(i == (moves.size() - 1)){
				cout<<"choosing a random square";
				unsigned int idx = rand() % moves.size();	
				moveTo(moves[idx]);
			}
		}
		//say that the current square is clean
	}
}
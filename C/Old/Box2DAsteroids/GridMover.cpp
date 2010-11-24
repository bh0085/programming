/*
 *  GridMove.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/22/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "GridMover.h"
#include "vector"
#include <iostream>
using namespace std;

GridMover::GridMover(){
	lambda = .8;
	xSize = XGRID;
	ySize = YGRID;
}

void GridMover::setReward(int fromSquare, int toSquare,float reward){
	
	vector <float> * temp = new vector <float> ();
	temp->push_back((float)fromSquare);
	temp->push_back((float)toSquare);
	temp->push_back(reward);
	rewards.push_back( * temp );
}

float GridMover::getReward(int fromSquare, int toSquare){
	for(int i = 0 ; i<rewards.size(); i++){
		if(rewards[i][0] == fromSquare && rewards[i][1] == toSquare)  return rewards[i][2];
	}
	return 0;
}

float GridMover::getQHat(int fromSquare, int toSquare){
	for(int i = 0 ; i < QHats.size() ; i++){
		if(QHats[i][0] == fromSquare && QHats[i][1] == toSquare) return QHats[i][2];
	}
	return 0;
}
void GridMover::setQHat(int fromSquare, int toSquare, float val){
	for(int i = 0 ; i < QHats.size() ; i++){
		if(QHats[i][0] == fromSquare && QHats[i][1] == toSquare) {
			QHats[i][2] = val;
			return;
		}
	}	
	float temp[3] = {(float)fromSquare, (float)toSquare, val};
	vector <float> * tvec = new vector <float> (temp, temp + sizeof(temp) / sizeof(float) );
	QHats.push_back(*tvec);
}
float GridMover::getQHatMax(int fromSquare){
	vector <int> adjacent;
	adjacentInVector(fromSquare, &adjacent);
	float qMax = 0.0;
	for(int i = 0 ; i < adjacent.size() ; i++){
		float temp = getQHat(fromSquare,adjacent[i]);
		if(temp > qMax) qMax = temp;
	}
	return qMax;
}

float GridMover::testQHat(int fromSquare, int toSquare){
	float jumpQ = getQHatMax(toSquare);
	float reward = getReward(fromSquare, toSquare);	
	return reward + lambda * jumpQ;
}

void GridMover::trainingRun(){
	currentSquare = 0;
	while(1){
		incrementTrainingRun();		
		if(currentSquare == 24) break;
	}
}

void GridMover::run(){
	currentSquare = 0;
	while(1){
		incrementRun();		
		if(currentSquare == 24) break;
		//cout<<currentSquare<<"\n";
	}
}

void GridMover::incrementTrainingRun(){
	vector <int> adjacent;
	adjacentInVector(currentSquare, &adjacent);
	int target = adjacent[rand() % adjacent.size()];
	
	setQHat(currentSquare, target, testQHat(currentSquare,target) );
	currentSquare = target;
}
void GridMover::incrementRun(){
	vector <int> adjacent;
	adjacentInVector(currentSquare, &adjacent);
	float qMax = 0;
	int idxBest = 0;
	for(int i = 0 ; i < adjacent.size() ; i++){
		float val = getQHat(currentSquare,adjacent[i]);
		if(val > qMax){
			idxBest = i;
			qMax = val;
		}
	}
	int target = adjacent[idxBest];
	currentSquare = target;
}


int GridMover::getXSize(){
	return xSize;
}
int GridMover::getYSize(){
	return ySize;
}
int GridMover::getIndexOfXY(int x, int y){
	return x + xSize * y;
}
void GridMover::adjacentInVector(int square, vector <int> * v){
	if(square % xSize != 0) v->push_back(square - 1);
	if(square % xSize != xSize -1) v->push_back(square +1);
	if(square / xSize != 0) v->push_back(square - xSize);
	if(square / xSize != ySize -1) v-> push_back(square + xSize);
}
/*
 *  GridMoverNN.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GridMoverNN.h"
#include "vector"
#include "NeuralNet.h"
#include <iostream>
using namespace std;

GridMoverNN::GridMoverNN(){
	lambda = .3;
	xSize = XGRID;
	ySize = YGRID;

	for(int i = 0 ; i < 4 ; i++){
		NNs[i].setAlpha(0.4);
		NNs[i].setRate(.6);
		NNs[i].setWeightAbs(.3);
		NNs[i].initSingleLayer(2,3,1);
	}
}


void GridMoverNN::trainingRun(){
	currentSquare = xSize * ySize - 2;
	
	for(int i = 0 ; i < 10 ; i++){
		incrementTrainingRun();		
		if(currentSquare == xSize * ySize - 1) break;
	}
	 
}


void GridMoverNN::run(){
	currentSquare = 5;
	for(int i = 0 ; i < 5; i++){
		incrementRun();		
		if(currentSquare == xSize * ySize -1) break;
		cout<<currentSquare<<"\n";
	}
}

void GridMoverNN::incrementTrainingRun(){

	
	int jitter = 3;
	int chainLength = 3;
	int numChains = 2;
	vector <vector <int> > squares;
	vector <vector <int> > actions;
	for(int i = 0 ; i < numChains ; i++){
		vector <int> blank;
		squares.push_back(blank);
		actions.push_back(blank);
		//cout<<"\n Chain "<<i<< ":";
		for(int j = 0 ; j < chainLength ; j++){
			if(j == 0){
				squares[i].push_back(currentSquare);
			} else {
				squares[i].push_back(getConsequence(squares[i][j-1], actions[i][j-1]));
			}
			actions[i].push_back(randomAction(squares[i][j]));
			//cout<<squares[i][j];

		}
	}
	for(int i = 0 ; i < jitter ; i++){
		for(int j = 0 ; j <numChains;j++){
			for(int k = 1 ; k < chainLength ; k++){ 
				trainNNQHat(squares[j][k-1], squares[j][k], actions[j][k-1]);
			};
		};
	};
	
	vector <int> currentActions;
	actionsInVector(currentSquare, &currentActions);	
	int action = currentActions[rand() % currentActions.size()];
	takeAction(action);
}
void GridMoverNN::trainNNQHat(int oldSquare, int newSquare, int action){
	vector <int> actions;
	actionsInVector(newSquare, &actions);
	float qMax = 0;
	float idxBest = -1;
	for(int i = 0 ; i < actions.size(); i++){
		float val = getNNQHat(newSquare, actions[i]);
		if(val > qMax || idxBest ==-1){
			idxBest = i;
			qMax = val;
		}
	}
	float newTrainingValue =lambda * qMax + getReward(oldSquare, action);
	//cout<<newSquare<<"  "<<qMax<<"  "<<newTrainingValue<<"\n";
	vector <float> trainingIn;
	vector <float> trainingOut;
	trainingIn.push_back(currentSquare % xSize);
	trainingIn.push_back(currentSquare / xSize);
	trainingOut.push_back(newTrainingValue);
	NNs[action].trainingRun(&trainingIn, &trainingOut);

}
float GridMoverNN::getNNQHat(int square, int action){
	vector <float> input;
	vector <float> output;
	input.push_back(square % xSize);
	input.push_back(square / xSize);
	NNs[action].run(&input, &output);
	return output[0];
};
void GridMoverNN::incrementRun(){
	vector <int> actions;
	actionsInVector(currentSquare, &actions);
	float qMax = -1;
	int idxBest = -1;

	for(int i = 0 ; i < actions.size() ; i++){
		int action = actions[i];
		float val = getNNQHat(currentSquare,action);
		if(val > qMax || idxBest == -1){
			idxBest = i;
			qMax = val;
		}
	}

	takeAction(actions[idxBest]);
}
float GridMoverNN::getReward(int square , int action){
	if(action == 1 && square == xSize * ySize -2) return .6;
	//if(action == 1 && square == 22) return .6;
	//if(action == 1 && square == 18) return .6;
	if(action == 3 && square == xSize * ySize - xSize -1) return .6;
	return 0.1;
}


int GridMoverNN::getXSize(){
	return xSize;
}
int GridMoverNN::getYSize(){
	return ySize;
}
int GridMoverNN::getIndexOfXY(int x, int y){
	return x + xSize * y;
}
NeuralNet * GridMoverNN::getNN(int action){
	return &(NNs[action]);
}
						
void GridMoverNN::actionsInVector(int square, vector <int> * v){
	//actions are 0:L 1:R 2:D 3:U
	if(square % xSize != 0) v->push_back(0);
	if(square % xSize != xSize -1) v->push_back(1);
	if(square / xSize != 0) v->push_back(2);
	if(square / xSize != ySize -1) v-> push_back(3);
}
int GridMoverNN::randomAction(int square){
	vector <int> v;
	actionsInVector(square,&v);
	return v[rand() % v.size()];
}
int GridMoverNN::getConsequence(int square ,int action){
	switch(action){
		case 0:
			return square-1;
			break;
		case 1:
			return square+1;
			break;
		case 2:
			return square-xSize;
			break;
		case 3:
			return square+xSize;
			break;
		default:
			return 0;
	}
	
	
}
void GridMoverNN::takeAction(int action){
	switch (action) {
		case 0:
			currentSquare-=1;
			break;
		case 1:
			currentSquare+=1;
			break;
		case 2:
			currentSquare-=xSize;
			break;
		case 3:
			currentSquare+=xSize;
			break;
	}
}
/*
 *  GridMoverNN.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */



#define XGRID 4
#define YGRID 4
#include "NeuralNet.h"
#include <vector>
using namespace std;

class GridMoverNN {
protected:
	float lambda;
	int xSize;
	int ySize;
	NeuralNet NNs[4];
	int currentSquare;
public:
	GridMoverNN();
	int getXSize();
	int getYSize();
	int getIndexOfXY(int x, int y);
	
	float getReward(int fromSquare, int action);
	void adjacentInVector(int square, vector <int> * v);
	void actionsInVector(int square,vector <int> * v);
	
	float getNNQHat(int fromSquare, int action);
	void trainNNQHat(int fromSquare, int toSquare, int action);
	
	void trainingRun();
	void run();
	void takeAction(int action);
	int getConsequence(int square , int action);
	NeuralNet * getNN(int action);
	int randomAction(int square);
	void incrementRun();
	void incrementTrainingRun();
};
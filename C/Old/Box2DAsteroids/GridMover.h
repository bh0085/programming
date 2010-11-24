/*
 *  GridMove.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/22/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#define XGRID 5
#define YGRID 5

#include <vector>
using namespace std;

class GridMover {
protected:
	float lambda;
	int xSize;
	int ySize;
	vector <vector <float> > rewards;
	vector <vector <float> > QHats;
	int currentSquare;
public:
	GridMover();
	int getXSize();
	int getYSize();
	int getIndexOfXY(int x, int y);
	void setReward(int fromSquare, int toSquare,float reward);
	float getReward(int fromSquare, int toSquare);
	void adjacentInVector(int square, vector <int> * v);
	float getQHat(int fromSquare, int toSquare);
	void setQHat(int fromSquare, int toSquare, float val);
	void trainingRun();
	void run();
	void incrementRun();
	void incrementTrainingRun();
	float getQHatMax(int fromSquare);
	float testQHat(int fromSquare, int toSquare);

};
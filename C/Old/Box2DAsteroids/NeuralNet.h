/*
 *  NeuralNet.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef NEURALNET_H
#define NEURALNET_H
#include <vector>
using namespace std;

#include "LinearUnit.h"
#include "SigmoidUnit.h"
#include "InputUnit.h"
#include "ComputableUnit.h"
#include "RBFUnit.h"

#define MAX_HIDDENS 100
#define MAX_OUTPUTS 100
#define MAX_INPUTS 100
#define MAX_LINEAR_UNITS 100
#define MAX_SIGMOID_UNITS 100
#define MAX_INPUT_UNITS 100
#define MAX_RBF_UNITS 100

#define LAYER_MAX_UNITS 100
#define NET_MAX_LAYERS 5

struct nncomputablelayer
{
	int nUnits;
	bool isTrainable;
	ComputableUnit * units[LAYER_MAX_UNITS];
};
typedef struct nncomputablelayer  CompLayer; 
class NeuralNet {
private:
	int nHidden;
	int nOut;
	int nIn;
	int nRBF;
	
	float inputRange[2];
	
	LinearUnit linearUnits[MAX_LINEAR_UNITS];
	SigmoidUnit sigmoidUnits[MAX_SIGMOID_UNITS];
	InputUnit inputUnits[MAX_INPUT_UNITS];
	RBFUnit rbfUnits[MAX_RBF_UNITS];
	
	int nCompLayers;
	CompLayer compLayers[NET_MAX_LAYERS];
	
	ComputableUnit * hiddens[MAX_HIDDENS];
	RBFUnit * rbfs[MAX_RBF_UNITS];
	ComputableUnit * outputs[MAX_OUTPUTS];
	InputUnit * inputs[MAX_INPUTS];
	float rate;
	float weightMaxAbs;
	float alpha;
	
	void initRBFs();
public:
	
	NeuralNet();

	void NeuralNet::initNLayersRBF(int numlayers, int numin, int numhidperlayer, int numout);
	void initNLayers(int numlayers, int numin, int numhidperlayer, int numout);
	void initSingleLayer(int ninput, int nhidden, int nout);
	
	
	int nInputs();
	int nOutputs();
	float weightOfOutputAtIndex(int out, int idx);
	float weightOfHiddenAtIndex(int hidden, int idx);
	ComputableUnit * getHidden(int idx);
	ComputableUnit * getOutput(int idx);
	InputUnit * getInput(int idx);
	
	void setRate(float newRate);
	void setWeightAbs(float newAbs);
	void setAlpha(float newAlpha);
	void drawNet();


	
			//Run with training input and expected output. 
			//First sends the input through the network then runs
			//backpropgation to tune neural weights.
	void trainingRun(vector <float> * trainingInput, vector <float> * expectedOutput);
	
			//A real run on the input vector. Fills the vector output with
			//results.
	void run(vector <float> * input, vector <float> * output);
};
#endif
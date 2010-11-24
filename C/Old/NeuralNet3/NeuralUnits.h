#include <iostream>
#include <vector>
#include <math.h>
#include <string>
#include <sstream>


using namespace std;
class NeuralUnit;
class ComputableUnit;


class NeuralUnit{
public:
	vector <ComputableUnit*> outputs ;
	vector <int> outputIDXs;
	float val;
	int addOutput(ComputableUnit* unit ,int idx);
	void connectForward(ComputableUnit* unit);
	void setValue(float newVal);
	float query();
	
};
class ComputableUnit: public NeuralUnit{
public:

	vector <NeuralUnit*> inputs;
	vector <int> inputIDXs;
	float delta;
	virtual void compute(){};
	virtual void computeDelta(){};
	void setDelta(float newDelta){delta=newDelta;};
	float getDelta(){ return delta;};
	vector <float> weights;
	vector <float> lastWeightChange;
	float alpha;
	
	string printWeights();
	void setAlpha(float newAlpha);
	void randomWeights(float maxabs);
	float getWeight(int idx);
	int addInput(NeuralUnit* unit, int idx);
	void computeWeights();
};

class LinearUnit: public ComputableUnit{
public:
	
	void compute();
	void computeDelta();
};

class SigmoidUnit: public ComputableUnit{
public:
	void compute();
	void computeDelta();
	void trainingDelta(float trainingValue);
};
class InputUnit: public NeuralUnit{
public:
	InputUnit();
};

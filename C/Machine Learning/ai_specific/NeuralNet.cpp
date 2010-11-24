#include "NeuralNet.h"
#include <iostream>
#include <vector>
#include <math.h>
#include <string>
#include <sstream>

using namespace std;

class NeuralUnit;
class nUnit;
class ComputableUnit;


class NeuralUnit{
public:
	vector <ComputableUnit*> outputs ;
	vector <int> outputIDXs;
	float val;
	
	//methods for connecting neurons to one another - automatically creating input/output slots
	void connectForward(ComputableUnit*);
	int addOutput(ComputableUnit*,int);

	void setValue(float newVal){
		val = newVal;		
	}
	float query(){
		return val;
	}
	
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

	string printWeights(){
		ostringstream ossbuffer;
		for(int i = 0 ; i < weights.size() ; i ++){
			ossbuffer << "W"<<i<<": "<<floor(weights[i] * 1000)/1000<<",     ";
		}
		return ossbuffer.str();			
	};
	void randomWeights(float maxabs = .05){
		weights.erase(weights.begin(), weights.begin() + weights.size());
		for( int i = 0 ; i < inputs.size() ; i++){
			float random = (((float)rand())/RAND_MAX - .5)* 2 * maxabs;
			weights.push_back(random);
		};
	};
	float getWeight(int idx){
		return weights[idx];
	};
	int addInput(NeuralUnit* unit, int idx){
		inputs.push_back(unit);
		inputIDXs.push_back(idx);
		return inputs.size() - 1;
	};
	void computeWeights(){
		for(int i = 0 ; i < weights.size() ; i++){
			weights[i] += .5*delta*inputs[i]->query();
		};
	};
};

//a few Neural Unit methods defined after Computable Unit
int NeuralUnit::addOutput(ComputableUnit* unit,int idx){
	outputs.push_back(unit);
	outputIDXs.push_back(idx);
	return outputs.size() - 1;
};
void NeuralUnit::connectForward(ComputableUnit* unit){
	int idx = outputs.size();
	int newIdx = unit->addInput(this,idx);
	addOutput(unit,newIdx);
};

class LinearUnit: public ComputableUnit{
public:

	void compute(){
		val = 0;
		for ( int i = 0 ; (i <inputs.size() && i < weights.size()) ; i++){
			val += inputs[i]->query()*weights[i];
		};
	};
	void computeDelta(){
		//THIS METHOD IS BLANK FOR NOW... I DON'T NEED IT YET
		delta = 0;
	}
};

class SigmoidUnit: public ComputableUnit{
public:
	void compute(){
		val = 0;
		for ( int i = 0 ; (i <inputs.size() && i < weights.size()) ; i++){
			val += inputs[i]->query()*weights[i];
		}
		val = 1/(1 + exp(-1 * val));
	}
	void computeDelta(){
		float sum = 0;
		for( int i = 0 ; i < outputs.size() ; i++){
			int idx = outputIDXs[i];
			float weight = (outputs[i])->getWeight(idx);
			float deltaCurrent = (outputs[i])->getDelta();
			sum+=weight*deltaCurrent;
		}
		sum*=query() * (1-query());
		setDelta(sum);
	};
	void trainingDelta(float trainingValue){
		float sum = 0;
		sum=query() * (1-query())*(trainingValue - query());
		setDelta(sum);
	};
};
class InputUnit: public NeuralUnit{
public:
	InputUnit(float startingVal = 0){
		val = startingVal;
	};	
};

extern "C" void findIdentity(){
	srand(time(NULL));
	//create a dummy set of neurons
	int nHidden = 3;
	int nIn = 8;
	int nOut = 8;
	vector <SigmoidUnit*> hiddens;
	vector <InputUnit*> inputs;
	vector <SigmoidUnit*> outputs;
	
	for(int j = 0 ; j < nIn ; j++){
		inputs.push_back(new InputUnit);
	};
	for(int j = 0 ; j < nHidden ; j++){
		hiddens.push_back(new SigmoidUnit);
		for(int i = 0 ; i < nIn ; i++ ){
			inputs[i]->connectForward(hiddens[j]);
		};
		hiddens[j]->randomWeights();
	};
	for(int j = 0 ; j < nOut ; j++){
		outputs.push_back(new SigmoidUnit);
		for(int i = 0 ; i < nHidden ; i++){
			hiddens[i]->connectForward(outputs[j]);
		}
		outputs[j]->randomWeights();
	};
	for(int itr=0 ; itr<1 ; itr++){
		for(int i = 0 ; i < 8 ; i ++){
			for(int j = 0 ; j < 8 ; j ++){
				if( j != i ){
					inputs[j]->setValue(.3);
				} else {
					inputs[j]->setValue(.8);
				};
			};
			for(int j = 0; j < nHidden ; j++){
				hiddens[j]->compute();

			}
			for(int j = 0; j < nOut ; j++){
				outputs[j]->compute();
				float e = inputs[j]->query();
				outputs[j]->trainingDelta(e);
				cout<<e<<""<<"q"<<outputs[j]->query()<<"d"<<outputs[j]->getDelta()<<",     ";

			};
			cout<<"\n";
			for(int j = 0 ; j < nHidden ; j++){
				hiddens[j]->computeDelta();
			};
			for(int j = 0 ; j < nHidden ; j++){
				hiddens[j]->computeWeights();	
			}
			for(int j = 0 ; j < nOut; j++){
				outputs[j]->computeWeights();
			}
			if(itr == 4500){
				for( int k = 0 ; k < 8 ; k++){
					cout<<outputs[k]->query();
				}
				cout << "\n";

			}
		};
		
		if(0 & itr % 500 == 0){
			cout<<outputs[0]->printWeights()<<"\n";
			cout<<"  "<<hiddens[0]->printWeights()<<"\n";			
			cout<<outputs[1]->printWeights()<<"\n";
			cout<<"  "<<hiddens[1]->printWeights()<<"\n";
			cout<<"\n";
		};
	};
};
		
	



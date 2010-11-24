#include "NeuralUnits.h"
#include <iostream>
#include <vector>
#include <math.h>
#include <string>
#include <sstream>
#import <OpenGL/OpenGL.h>

using namespace std;

void	NeuralUnit::setValue(float newVal){
		val = newVal;		
};
float	NeuralUnit::query(){
		return val;
};
int		NeuralUnit::addOutput(ComputableUnit* unit,int idx){
	outputs.push_back(unit);
	outputIDXs.push_back(idx);
	return outputs.size() - 1;
};
void	NeuralUnit::connectForward(ComputableUnit* unit){
	int idx = outputs.size();
	int newIdx = unit->addInput(this,idx);
	addOutput(unit,newIdx);
};
	
string	ComputableUnit::printWeights(){
		ostringstream ossbuffer;
		for(int i = 0 ; i < weights.size() ; i ++){
			ossbuffer << "W"<<i<<": "<<floor(weights[i] * 1000)/1000<<",     ";
		}
		return ossbuffer.str();			
	};
void	ComputableUnit::randomWeights(float maxabs){
		weights.erase(weights.begin(), weights.begin() + weights.size());
	
		for( int i = 0 ; i < inputs.size() ; i++){
			float random = (((float)rand())/RAND_MAX - .5)* 2 * maxabs;
			weights.push_back(random);
			lastWeightChange.push_back(0.0);
		};
	
	};
float	ComputableUnit::getWeight(int idx){
		return weights[idx];
	};
int		ComputableUnit::addInput(NeuralUnit* unit, int idx){
		inputs.push_back(unit);
		inputIDXs.push_back(idx);
		return inputs.size() - 1;
	};
void	ComputableUnit::computeWeights(){
		for(int i = 0 ; i < weights.size() ; i++){
			lastWeightChange[i] = .3*delta*inputs[i]->query() + alpha*lastWeightChange[i];
			weights[i] +=lastWeightChange[i];
		};
	};
void	ComputableUnit::setAlpha(float newAlpha){
	alpha = newAlpha;
}

void	LinearUnit::compute(){
		val = 0.0;
		for ( int i = 0 ; (i < weights.size()) ; i++){
			val += inputs[i]->query()*weights[i];
		};
	};
void	LinearUnit::computeDelta(){
		//THIS METHOD IS BLANK FOR NOW... I DON'T NEED IT YET
		delta = 0;
};

void	SigmoidUnit::compute(){
		val = 0.0;
		for ( int i = 0 ; (i < weights.size()) ; i++){
			val +=inputs[i]->query()*weights[i];
		}
		val = 1/(1 + exp(-1 * val));
	}
void	SigmoidUnit::computeDelta(){
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
void	SigmoidUnit::trainingDelta(float trainingValue){
		float sum = 0;
		sum=query() * (1-query())*(trainingValue - query());
		setDelta(sum);
	};

		InputUnit::InputUnit(){
	val = 0;
};	


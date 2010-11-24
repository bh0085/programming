/*
 *  NeuralNet.cpp
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 7/23/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
//#include "InputUnit.h"
#include "NeuralNet.h"
#include "SigmoidUnit.h";
#include "InputUnit.h"
#include <iostream>
#include "MyCIDL.h"
#include "GLIDL.h"
#include <OpenGL/OpenGL.h>

#define PI 3.14159
#define N_RBF 4
#include <math.h>

NeuralNet::NeuralNet(){
	rate = .1;
	weightMaxAbs = .02;
	inputRange[0] = 0;
	inputRange[1] = 10;
};
void NeuralNet::setRate(float newRate){
	rate = newRate;
}
void NeuralNet::setAlpha(float newAlpha){
	alpha = newAlpha;
}
void NeuralNet::setWeightAbs(float newWeight){
	weightMaxAbs = newWeight;
}

//Initializers.

void NeuralNet::initNLayersRBF(int numlayers, int numin, int numhidperlayer, int numout){
	nCompLayers = numlayers;
	int nSig = 0;
	int nLin = 0;
	nRBF = 0;
	nIn = numin;
	nHidden = 0;
	nOut =0;
	
	// creates computable layers starting with the output and moving towards the input
	for(int i = numlayers - 1 ; i >= 1  ; i--){
		compLayers[i].nUnits= 0;
		compLayers[i].isTrainable = true;
		if( i == numlayers - 1 ){
			for(int j = 0 ; j < numout ; j++){
				outputs[nOut++] = &sigmoidUnits[nSig++];
				compLayers[i].units[compLayers[i].nUnits++] = outputs[nOut-1];
			}
		} else {
			for(int j = 0 ; j < numhidperlayer ; j++){
				hiddens[nHidden++] = &sigmoidUnits[nSig++];
				compLayers[i].units[compLayers[i].nUnits++] = hiddens[nHidden -1];
				for(int k = 0 ; k < compLayers[i+1].nUnits ; k++){
					compLayers[i].units[compLayers[i].nUnits - 1]->
					connectForward(compLayers[i+1].units[k]);
				}
			}
		}		
	}
	
	compLayers[0].nUnits = 0;
	compLayers[0].isTrainable = false;	

	for(int i = 0 ; i < N_RBF ; i++){
		rbfs[nRBF]=&rbfUnits[nRBF];
		compLayers[0].units[compLayers[0].nUnits++] = rbfs[nRBF];
		nRBF++;
		for(int k = 0 ; k < compLayers[1].nUnits ; k++){
			compLayers[0].units[compLayers[0].nUnits - 1]->
			connectForward(compLayers[1].units[k]);
		}		
	}	

	for(int i = 0 ; i < numin ; i++){
		inputs[i] = &inputUnits[i];
		for(int j = 0 ;  j < compLayers[0].nUnits; j++){
			inputs[i]->connectForward(compLayers[0].units[j]);
		}
	}
	for (int i = 0 ; i < nOut ; i++){
		outputs[i]->setRandomWeights(weightMaxAbs);
	}
	for (int i = 0 ; i < nHidden ; i++){
		hiddens[i]->setRandomWeights(weightMaxAbs);
	}	
	initRBFs();	
}

void NeuralNet::initRBFs(){
	float inputWidth = inputRange[1] - inputRange[0];
	int rbfDims = nIn;
	float rbfWidths[nIn];
	int hPerDim = sqrt(nRBF);
	
	for(int i = 0 ; i < nIn ; i++){
		rbfWidths[i] = inputWidth/hPerDim ;
	}

	if (nIn == 2){
		for (int i = 0 ; i < nRBF ; i++){
			float xfrac = ((float)(i % hPerDim))/hPerDim;
			float yfrac = ((float)(i / hPerDim))/hPerDim;
			float h_x = (inputWidth)*xfrac + inputRange[0];
			float h_y = (inputWidth)*yfrac + inputRange[0];
			float centers[2] = {h_x,h_y};
			rbfUnits[i].setKernel(rbfWidths,centers,rbfDims);
			
		}
		
	} else {
		for(int i = 0 ; i < N_RBF ; i++){
			
			float rbfCenters[nIn];
			for(int j = 0 ; j < nIn ; j++){
				rbfCenters[j] = (float)(rand()%100) / 100 * inputWidth;
			}		
			rbfUnits[i].setKernel(rbfWidths,rbfCenters,rbfDims);
		}
	}
}

void NeuralNet::initNLayers(int numlayers, int numin, int numhidperlayer, int numout){
	nCompLayers = numlayers;
	int nSig = 0;
	int nLin = 0;
	int nRBF = 0;
	
	nIn = numin;
	nHidden = numhidperlayer * (numlayers - 1);
	nOut = numout;
	
	// creates computable layers starting with the output and moving towards the input
	for(int i = numlayers - 1 ; i >= 0  ; i--){
		compLayers[i].nUnits= 0;
		compLayers[i].isTrainable = true;
		if( i == numlayers - 1 ){
			for(int j = 0 ; j < numout ; j++){
				outputs[j] = &sigmoidUnits[nSig++];
				compLayers[i].units[compLayers[i].nUnits++] = outputs[j];
			}
		} else {
			for(int j = 0 ; j < numhidperlayer ; j++){
				hiddens[j] = &sigmoidUnits[nSig++];
				compLayers[i].units[compLayers[i].nUnits++] = hiddens[j];
				for(int k = 0 ; k < compLayers[i+1].nUnits ; k++){
					compLayers[i].units[compLayers[i].nUnits - 1]->
						connectForward(compLayers[i+1].units[k]);
				}
			}
		}		
	}
	for(int i = 0 ; i < numin ; i++){
		inputs[i] = &inputUnits[i];
		for(int j = 0 ;  j < compLayers[0].nUnits; j++){
			inputs[i]->connectForward(compLayers[0].units[j]);
		}
	}
	for (int i = 0 ; i < nOut ; i++){
		outputs[i]->setRandomWeights(weightMaxAbs);
	}
	for (int i = 0 ; i < nHidden ; i++){
		hiddens[i]->setRandomWeights(weightMaxAbs);
	}	
}
//Run with training input and expected output. 
void NeuralNet::trainingRun(vector <float> * trainingInput, vector <float> * expectedOutput){
	vector <float> output;
	
	run(trainingInput,&output);
	
	for(int i = 0 ; i <nOut; i++){
		outputs[i]->setDelta( output[i] * (1 - output[i]) * ((*expectedOutput)[i] - output[i]));
	}
	for(int i = nCompLayers - 2 ; i >= 0 ; i--){
		if(compLayers[i].isTrainable){
			for(int j = 0 ; j < compLayers[i].nUnits ; j++){
				compLayers[i].units[j] ->computeDelta();
			}
		}
	}
	for(int i = nCompLayers - 1 ; i >= 0 ; i--){
		if(compLayers[i].isTrainable){
			for(int j = 0 ; j < compLayers[i].nUnits ; j++){
				compLayers[i].units[j]->computeWeights(rate,alpha);
			}
		}
	}
};

//A real run on the input vector.
void NeuralNet::run(vector <float> * input, vector <float> * output){
	for(int i = 0 ; i < input->size() ; i++){
		inputs[i]->setValue((*input)[i]);
	};
	for(int i = 0 ; i < nCompLayers ; i++){
		for(int j = 0 ; j < compLayers[i].nUnits; j++){
			compLayers[i].units[j]->computeValue();
		}
	}
	for(int i = 0 ; i < nOut ; i++){
		output->push_back(outputs[i]->getValue());
	}
};

//Accessor methods.
int NeuralNet::nInputs(){
	return nIn;
};
int NeuralNet::nOutputs(){
	return nOut;
};
float NeuralNet::weightOfOutputAtIndex(int out, int idx){
	return outputs[out]->weightAtIndex(idx);
}
float NeuralNet::weightOfHiddenAtIndex(int hidden, int idx){
	return hiddens[hidden]->weightAtIndex(idx);
}
ComputableUnit * NeuralNet::getHidden(int idx){
	return hiddens[idx];
};
ComputableUnit * NeuralNet::getOutput(int idx){
	return outputs[idx];
};
InputUnit * NeuralNet::getInput(int idx){
	return inputs[idx];
};

//Graphics Methods
void NeuralNet::drawNet(){

	glClearColor(.2,.2,.2,1);
	GLIDLClear();
	float bounds[6] = {-1,11,-1,11,-10,20};
	GLIDLSetViewBoundsWithMargin(bounds,.3);
	//GLIDLSetBoundsToArrayWithMargin(hin_x, hin_y, nHidden, .5);
	GLIDLLabelAxes();
	glColor3d(1,1,1);
	float pixScale[2];
	GLIDLorthoXYOfOnePixel(pixScale);
	int thetaDivs = 2;
	
	for(int i = 0 ; i < nRBF ; i ++){
		float centers[2];
		rbfs[i]->getCenters(centers);
		float widths[2];
		rbfs[i]->getWidths(widths);
		
		
		float color[3] = {1,1,1};
		glColor3fv(color);
		glLineWidth(1);
		
		//printf("centers, %f , %f \n",centers[0],centers[1]); 
		float ry =widths[1];
		float rx =widths[0];
		
		
		plots_ellipse(centers[0], centers[1], rx, ry);
		
	}
	if( nRBF == 0){
		float hin_x[nHidden];
		float hin_y[nHidden];
		float hradii[nHidden];
		
		float hidden_radius = 20;
		int hidden_thick = 0;
		
		
		for(int i = 0 ; i < nHidden ; i++){
			hradii[i] =hidden_radius;
		}
		for(int i = 0 ; i < nHidden ; i++){
			hin_x[i] = hiddens[i]->getWeight(inputs[0]);
			hin_y[i] = hiddens[i]->getWeight(inputs[1]);
		}
		for(int i = 0 ; i < nHidden ; i++){
			float frac = ((float)i)/nHidden;
			float color[3] = {1,1,1};
			glColor3fv(color);
			glLineWidth(hidden_thick);

			plots_ellipse(hin_x[i], hin_y[i], hradii[i]*pixScale[0], hradii[i]*pixScale[1]);

			for(int j = 0 ; j < nOut ; j++){
				bool sign = false;
				float weight = outputs[j]->getWeight(hiddens[i]);
				if(weight > 0) sign = true;
				float out_thick = 20* sqrt(absf(weight));
				float dist = hidden_radius + 10;
				float coffs = 4;
				float rpix = dist;
				
				float thetai = PI * 2 * j / thetaDivs;
				float thetaf = PI * 2 * (j + 1)/thetaDivs;
				float thetaAvg = (thetai + thetaf) /2;
				float xarc = hin_x[i] + cos(thetaAvg) * coffs * pixScale[0];
				float yarc = hin_y[i] + sin(thetaAvg) * coffs * pixScale[1];

				float thickscale = (out_thick + rpix) / rpix;
				float ry =rpix*pixScale[1];
				float rx =rpix*pixScale[0];

				GLIDLSetArcFilled(1);
				if (sign) glColor4d(1, 0, 0,.5);  else  glColor4d(0, 0, 1,.5);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);
				GLIDLSetArcFilled(0);
				glColor4d(1, 1, 1,.8);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);

			}
		}
	} else {
		int hPerDim = sqrt(nHidden);
		for (int i = 0 ; i < nHidden ; i++){
			float xfrac = ((float)(i % hPerDim))/hPerDim;
			float yfrac = ((float)(i / hPerDim))/hPerDim;
			float h_x = (bounds[1] - bounds[0])*xfrac + bounds[0];
			float h_y = (bounds[3] - bounds[2])*yfrac + bounds[0];
			float hidden_radius = 10;
			plots_ellipse(h_x, h_y, hidden_radius*pixScale[0], hidden_radius*pixScale[1]);
			float circ_max_thick
			= 0;
			
			for(int j = 0 ; j < nRBF ; j++){
				bool sign = false;
				float weight = hiddens[i]->getWeight(rbfs[j]);
				if(weight > 0) sign = true;
				float out_thick = 40* sqrt(absf(weight));
				float dist = hidden_radius + 10;
				
				float coffs = 4;
				float rpix = dist;
				
				
				
				float thetai = PI * 2 * j / nRBF;
				float thetaf = PI * 2 * (j + 1)/nRBF;
				float thetaAvg = (thetai + thetaf) /2;
				float xarc = h_x + cos(thetaAvg) * coffs * pixScale[0];
				float yarc = h_y + sin(thetaAvg) * coffs * pixScale[1];
				
				float thickscale = (out_thick + rpix) / rpix;
				float ry =rpix*pixScale[1];
				float rx =rpix*pixScale[0];
				
				if(circ_max_thick < rpix *thickscale)circ_max_thick = rpix *thickscale;
				
				
				GLIDLSetArcFilled(1);
				if (sign) glColor4d(1, 0, 0,.5);  else  glColor4d(0, 0, 1,.5);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);
				GLIDLSetArcFilled(0);
				glColor4d(1, 1, 1,.8);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);				
			}
			for(int j = 0 ; j < nOut ; j++){
				bool sign = false;
				float weight = outputs[j]->getWeight(hiddens[i]);
				if(weight > 0) sign = true;
				float out_thick = 40* sqrt(absf(weight));
				float dist = hidden_radius + 10 + circ_max_thick;
				float coffs = 4;
				float rpix = dist;
				
				float thetai = PI * 2 * j / thetaDivs;
				float thetaf = PI * 2 * (j + 1)/thetaDivs;
				float thetaAvg = (thetai + thetaf) /2;
				float xarc = h_x + cos(thetaAvg) * coffs * pixScale[0];
				float yarc = h_y + sin(thetaAvg) * coffs * pixScale[1];
				
				float thickscale = (out_thick + rpix) / rpix;
				float ry =rpix*pixScale[1];
				float rx =rpix*pixScale[0];
				
				GLIDLSetArcFilled(1);
				if (sign) glColor4d(1, 0, 0,.5);  else  glColor4d(0, 0, 1,.5);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);
				GLIDLSetArcFilled(0);
				glColor4d(1, 1, 1,.8);
				plots_ellipse_arc(xarc, yarc, rx, ry, thetai, thetaf,thickscale);
				
			}

		}
		
	}
	GLIDLFlushBuffer();

	
	
}

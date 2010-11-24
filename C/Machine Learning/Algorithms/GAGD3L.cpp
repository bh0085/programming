/*
 *  GAGD3L.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 9/1/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GAGD3L.h"
#include <stdlib.h>
#include <math.h>
#include "GLIDL.h"
#include "stdio.h"

#define G3L_WABS .1



GAGD3L::GAGD3L(){
	/*
	nHidden = G3L_HID;
	nIn = G3L_IN;
	nOut = G3L_OUT;
	 */
	for(int i = 0 ; i < G3L_HID; i++){
		for(int j = 0 ; j < G3L_IN +1 ; j++){
			l2weights[i][j] = (((float(rand() %1000))/500)-1) * G3L_WABS;
		}
	}
	for(int i = 0 ; i < G3L_OUT ; i++){
		for(int j = 0 ; j < G3L_HID+1 ; j++){
			l3weights[i][j] = (((float(rand() %1000))/500)-1)* G3L_WABS;
		}
	}	
}
void GAGD3L::train(float *input, unsigned htargets [], float *output){
	hiddenTargets = htargets; //this variable is *not* stored locally.
	hiddenNormInvSq = 0.0;
	
	for(int i = 0 ; i < G3L_HID ; i++){
		hiddenNormInvSq += hiddenTargets[i];
	}
	hiddenNormInvSq = 1/hiddenNormInvSq;		

	for(int i = 0 ; i < G3L_OUT ; i ++){
		outputTargets[i] = output[i];
	}
	for(int j = 0 ; j < G3L_IN ; j++){
		l1vals[j] = input[j];
	}
	feedTraining();
	descend();
}
void GAGD3L::feedTraining(){
	for(int i = 0 ; i < G3L_HID ; i++){
		float val = 0.0;
		for(int j = 0 ; j < G3L_IN ; j++){
			val+= l1vals[j]*l2weights[i][j];
		}
		val+= l2weights[i][G3L_IN];
		l2vals[i]=false;
		if(val >0)l2vals[i] = true;
	}
	for(int i = 0 ; i < G3L_OUT ; i++){
		float val = 0.0;
		for(int j = 0 ; j < G3L_HID ; j++){
			if(hiddenTargets[j] != 0)val+=l3weights[i][j];
		}
		val += l3weights[i][G3L_HID];
		l3vals[i] = val;
	}
}
void GAGD3L::feedReal(){
	for(int i = 0 ; i < G3L_HID ; i++){
		float val = 0.0;
		for(int j = 0 ; j < G3L_IN ; j++){
			val+= l1vals[j]*l2weights[i][j];
		}
		val+= l2weights[i][G3L_IN];
		l2vals[i]=false;
		if(val >0)l2vals[i] = true;
	}
	for(int i = 0 ; i < G3L_OUT ; i++){
		float val = 0.0;
		for(int j = 0 ; j < G3L_HID ; j++){
			if(l2vals[j])val+=l3weights[i][j];
		}
		val += l3weights[i][G3L_HID];
		l3vals[i] = val;
	}	
}
void GAGD3L::descend(){
//current, descent uses the perceptron learning rule for
//hidden weights and the alpha LMS learning rule for the output weights
	float alpha = .1;
	for(int i = 0 ; i < G3L_OUT ; i ++){
		for(int j = 0 ; j < G3L_HID ; j++){
			l3weights[i][j] += alpha*(outputTargets[i] - l3vals[i])*(float)(hiddenTargets[j])*hiddenNormInvSq;
		}
		l3weights[i][G3L_HID] += alpha*(outputTargets[i] - l3vals[i])*hiddenNormInvSq;
	}
	
	float rho = .0001;
	for(int i = 0 ; i < G3L_HID ; i++){
		float delta;
		//printf("%f  ", l1vals[i]);

		if(l2vals[i]){
			//printf("l1  ");

			if(hiddenTargets[i]) delta = 0; else delta = -1.0;
		} else {
			//printf("l2  ");

			if(hiddenTargets[i]) delta = 1.0;else delta = 0.0;
		}
		for(int j = 0 ; j < G3L_IN ; j++){
			l2weights[i][j] += rho*delta*l1vals[j];
		}
		l2weights[i][G3L_IN] += rho*delta;
	}
}
float GAGD3L::getError(float *input, float *output){
	for(int i = 0 ; i < G3L_IN ; i++){
		l1vals[i] = input[i];
	}
	feedReal();
	float error = 0;
	for(int i = 0 ; i < G3L_OUT ; i++){
		error += pow(output[i] - l3vals[i],2);
	}
	return error;
	
}
void GAGD3L::getOutput(float *input, float *output){
	for(int i = 0 ; i < G3L_IN ; i++){
		l1vals[i] = input[i];
	}
	feedReal();
	float error = 0;
	for(int i = 0 ; i < G3L_OUT ; i++){
		output[i] = l3vals[i];
	}
	
}
float GAGD3L::getVal(){
	return l3vals[0];
}


void GAGD3L::drawHiddenWeights(){
	for (int i = 0 ; i < G3L_HID ; i++){
		plots_screen_circle((float)i, l2weights[i][0], 5);
	}
	GLIDLFlushBuffer();

	
}
void GAGD3L::drawOutputWeights(){
	for (int i = 0 ; i < G3L_HID ; i++){
		plots_screen_circle((float)i, l3weights[0][i], 5);
	}
	GLIDLFlushBuffer();
	
	
}
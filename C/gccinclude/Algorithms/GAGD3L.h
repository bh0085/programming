/*
 *  GAGD3L.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 9/1/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef GAGD3L_H
#define GAGD3L_H

#define G3L_IN  1
#define G3L_HID 10
#define G3L_OUT 1
//implementation of a combined GA/GD procedure with an LTU hidden layer and a linear output layer
class GAGD3L{
public:	
	GAGD3L();
	void train(float * input, unsigned hiddenTargets [], float * output);
	float getError(float * input, float * output);
	void getOutput(float * input, float * output);
	void GAGD3L::drawHiddenWeights();
	void GAGD3L::drawOutputWeights();
	
	float GAGD3L::getVal();
	float l3weights[G3L_OUT][G3L_HID+1];	
	bool l2vals[G3L_HID];
	static const unsigned nHidden = G3L_HID;
	static const unsigned nIn = G3L_IN;
	static const unsigned nOut = G3L_OUT;


private:
	
	unsigned * hiddenTargets;
	float outputTargets[G3L_OUT];
	float hiddenNormInvSq ;
	
	float l1vals[G3L_IN];
	float l3vals[G3L_OUT];
	float l2weights[G3L_HID][G3L_IN+1];
	
	void feedReal();
	void feedTraining();
	void descend();
	
};

#endif
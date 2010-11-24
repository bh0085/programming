/*
 *  Kohonen1D.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifdef __cplusplus
#define K1_INPUT_DIMENSION 2
#define	K1_N_NEURONS 15
#define K1_N_INPUTS 1000


#define K1_START_MAXABS 5.5f
#define K1_START_RES 1000
#define K1_INPUT_RES 10000
#define K1_INPUT_RADIUS 10.0f

typedef struct kNeuron1D{

	float x;
	float m [K1_INPUT_DIMENSION];
} kNeuron1D;


class Kohonen1D{
private:
	float metric_xmax;
	float metric_xmin;
	float metric_xwidth;
	float nRadSq;
	float nSqMin;
	float alphaCurrent ;
	float expectedRuns;
	float nDecay;
	float aDecay;
	float hat_width_cof;
	float brim_sq_width;
	float brim_sq_mag;
	bool doTanh;
	bool tanhSlope; 
	kNeuron1D units[K1_N_NEURONS];
	float inputs[K1_N_INPUTS][K1_INPUT_DIMENSION];
public:
	Kohonen1D();
	void initWithInputs();
	void initToSquare();
	void initToTube();
	void initToCircle();
	void iterate();
	void draw();
	
};

#endif
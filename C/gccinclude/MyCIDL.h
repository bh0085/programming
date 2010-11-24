/*
 *  MyCIDL.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef MyCIDL_H
#define MyCIDL_H

#ifdef __cplusplus
extern "C" {
#endif
//Some basic mathematical functions
void indgen(int array[], int size);
void findgen(float array[], int size);
void multArraysf(float array1[], float array2[], float array3[], int size);
void addArraysf(float array1[], float array2[], float array3[], int size);
void scaleArrayf(float array[], float scaleFactor, int size);
void addConstantToArrayf(float array[], float constant, int size);
void cosOfArrayf(float array[],int size);
void sinOfArrayf(float array[],int size);
void modOfArrayf(float array[],int modby,int size);
	
float absf(float x);
int absi(int x);

	
#ifdef __cplusplus
}
#endif

#endif

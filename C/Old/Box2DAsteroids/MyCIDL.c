/*
 *  MyCIDL.c
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/13/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "MyCIDL.h"
#include "math.h"

//IDL global math functions

extern void indgen(int array[], int size){
	for (int i = 0 ; i < size ; i++){
		array[i] = i;
	}
}
extern void findgen(float array[], int size){
	for (int i = 0 ; i < size ; i++){
		array[i] = i;
	}
}
extern void addArraysf(float array1[], float array2[], float array3[], int size){
	for (int i = 0 ; i < size ; i++){
		array3[i] = array2[i] + array1[i];
	}
}
extern void scaleArrayf(float array[], float scaleFactor, int size){
	for(int i = 0 ; i < size ; i++){
		array[i]*=scaleFactor;
	}
}
extern void addConstantToArrayf(float array[], float constant, int size){
	for(int i = 0 ; i < size ; i++){
		array[i]+=constant;
	}
}
extern void multArraysf(float array1[], float array2[], float array3[], int size){
	for (int i = 0 ; i < size ; i++){
		array3[i] = array2[i] *array1[i];
	}	
}
extern void cosOfArrayf(float array[],int size){
	for(int i = 0 ; i < size ; i++){
		array[i] = cos(array[i]);
	}
}
extern void sinOfArrayf(float array[], int size){
	for(int i = 0 ; i < size ; i++) array[i] = sin(array[i]);
	
}
extern void modOfArrayf(float array[], int modby, int size){
	for(int i = 0 ; i < size ; i++) array[i] = ((int)array[i]) % modby + (array[i] - (int)array[i]);
}
extern void modOfArrayi(int array[],int modby, int size){
	for(int i = 0 ; i < size ; i++) array[i] = (array[i]) % modby;	
}

extern float absf(float x){
	if(x < 0) return -1 * x;
	return x;
}
extern int absi(int x){
	if(x < 0) return -1 * x;
	return x;
}
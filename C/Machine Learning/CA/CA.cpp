/*
 *  CA.cpp
 *  CA
 *
 *  Created by Benjamin Holmes on 10/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "stdio.h"
#include "CA.h"
#include <math.h>
CA::CA(unsigned num, unsigned max_itr){
	N = num;
	M = max_itr;
	rval = 1;
	BitArray arr = BitArray(N*M);
	BitArray rules = BitArray(pow(2,2*rval + 1));
							
}
void CA::Display(){
	for(int j = 0; j < M ; j++){
		for(int i = 0 ; i < N ; i++){
			unsigned pos = (i + j * N);
			printf("%i",arr.getBit(pos));
		}
		printf("\n");
	}
}
void CA::initRandom(){
	for(int i = 0 ; i < N ; i++){
		arr.randomizeBit(i);
	}
}
void CA::run(){
	
}
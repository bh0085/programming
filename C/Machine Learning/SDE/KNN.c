/*
 *  KNN.c
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <gsl/gsl_sort_float.h>
#include "KNN.h"
#include <math.h>
#include "CMath.h"
void ftest(){
	
};


void fvnGetKNN(unsigned data_dimension,  unsigned data_size, const float * data, unsigned k, unsigned * KNNs){
	//KNNS should be an array of size data_size * data_size
	printf("ENTERED ROUTINE!!");
	unsigned n = data_size;
	for ( int i = 0 ; i < data_size * data_dimension ; i ++){
		KNNs[i] = 0;
	}
	
	for( int i = 0 ; i < n ; i++){
		float sqdistances[n];
		for (int j = 0 ; j < n ; j++){
			float sqdist = 0;
			unsigned pos1 = i* data_dimension;
			unsigned pos2 = j* data_dimension;
			for (int k = 0 ; k < data_dimension ; k++){
				sqdist += pow(data[pos1 + k] - data[pos2+k],2);
			}
			sqdistances[j] = sqdist;
		};
		size_t idxs[k];
		//take the k+1 smallest in order to ignore the 
		gsl_sort_float_smallest_index(idxs, k + 1, sqdistances, 1, n);
		for (int j = 0 ; j < k ; j++){
			if(idxs[j] != i) KNNs[i*data_dimension +idxs[j]] = 1;
		};
	};
	uvnSymmetrizeMatrix(data_size, KNNs);
};

void uvnSymmetrizeMatrix(unsigned data_size, unsigned *data ){
	for (int i = 0 ; i < data_size ; i++){
		for(int j = 0 ; j < i ; j++){
			unsigned idx1 = i * data_size + j;
			unsigned idx2 = j * data_size + i;
			if (data[idx1]>data[idx2] )  data[idx2] = data[idx1];
			else data[idx1] = data[idx2];
		}
	}
};

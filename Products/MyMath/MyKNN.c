/*
 *  KNN.c
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <gsl/gsl_sort_float.h>
#include "MyKNN.h"
#include <math.h>
#include "MyMath.h"
#include "MySparse.h"

SCMat knnNewSCMat(unsigned m){
	SCMat SC = (SCMat)malloc(sizeof(SCMat));
	SC->m = m;
	SC->smats =(SMat *)malloc(sizeof(SMat) * m);
	SC->constraints=(float *)malloc(sizeof(float) * m);
	return SC;
};
void knnSetConstraint(SCMat SC, unsigned idx, SMat S, float constraint){
	SC->constraints[idx] = constraint;
	SC->smats[idx] = S;
}
void knnFreeSCMat(SCMat SC){
	for(int i = 0 ; i < SC->m ; i++){
		svdFreeSMat(SC->smats[i]);
	}
	free(SC->smats);
	free(SC->constraints);
	free(SC);
}



SCMat fvsGetConstraints(unsigned data_size, unsigned * KNNs,unsigned data_dim, float * data){
	unsigned KNN2[data_size * data_size];
	uvnSquareMatrix(data_size, KNNs, KNN2);
	//actually, zero the knn2 matrix for now ---only use the nn matrix.
	for(int i = 0; i < data_size * data_size; i++) KNN2[i] = 0;
	unsigned m = 0;
	
	for(int i = 0 ; i < data_size ; i++){
		for(int j = 0 ; j < i ; j++){
			if(KNNs[i + j * data_size] > 0 || KNN2[i+j*data_size] > 0 ){
				m++;
			}
		}
	}
	SCMat SC = knnNewSCMat(m);
	unsigned count = 0;
	

	//this loop gets the constraint and constraint matrix for each nonzero element of the nearest neighbor matrices.
	for(int i = 0 ; i < data_size ; i++){
		for(int j = 0 ; j< i ; j++){
			if(KNNs[i + j * data_size] > 0 || KNN2[i+j*data_size] > 0){
				float G11 = fvDotProduct(data_dim,&data[i*data_dim],&data[i*data_dim]);
				float G22 = fvDotProduct(data_dim,&data[j*data_dim],&data[j*data_dim]);
				float G12 = fvDotProduct(data_dim,&data[i*data_dim],&data[j*data_dim]);
				
				double * array = (double *)calloc(sizeof(double), data_size * data_size);
				array[i + i * data_size] = 1;
				array[j + j * data_size] = 1;
				array[i + j * data_size] = -1;
				array[j + i * data_size] = -1;
				
				float constraint = G11 + G22 - 2 * G12;
				SMat S = sparseFromArray(data_size, data_size, array);
				free(array);
				
				knnSetConstraint(SC, count, S, constraint);
				count++;
			}
		}
	}
	return SC;
}
float fvDotProduct(unsigned data_dimension,const  float * d1,const  float * d2){
	float out = 0.0;
	for(int i = 0 ; i < data_dimension ; i++){
		out += d1[i] * d2[i];
	}
	return out;
}
void uvnSquareMatrix(unsigned data_size, unsigned * data, unsigned * square){
	for(int i = 0 ; i < data_size ; i++){
		for(int j = 0 ; j < data_size ; j++){
			square[i+j*data_size] = 0;
			for(int k = 0 ; k < data_size ; k++){
				square[i + j* data_size] += data[i+k*data_size]*data[k+j*data_size];
			}
		}
	}
}
	
void fvnGetKNN(unsigned data_dim,  unsigned data_size, const float * data, unsigned k, unsigned * KNNs){
	//KNNS should be an array of size data_size * data_size
	unsigned n = data_size;
	for ( int i = 0 ; i < data_size * data_size ; i ++){
		KNNs[i] = 0;
	}
	
	for( int i = 0 ; i < n ; i++){
		float sqdistances[n];
		for (int j = 0 ; j < n ; j++){
			float sqdist = 0;
			unsigned pos1 = i* data_dim;
			unsigned pos2 = j* data_dim;
		
			for (int k = 0 ; k < data_dim ; k++){
				sqdist += pow(data[pos1 + k] - data[pos2+k],2);
			}
			
			sqdistances[j] = sqdist;

		};
		size_t idxs[k];
		//take the k+1 smallest in order to ignore the 
		gsl_sort_float_smallest_index(idxs, k + 1, sqdistances, 1, n);
		for (int j = 0 ; j < k +1 ; j++){
			if(idxs[j] != i) KNNs[i + data_size * idxs[j]] = 1;
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

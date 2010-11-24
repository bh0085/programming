/*
 *  MySparse.c
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/20/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "MySparse.h"
#include "stdlib.h"
#include "math.h"

SMat  sparseFromArray(long rows, long columns, double * array){
	long count = 0;
	
	//I am going to work with the idl convention that in the one
	for(unsigned i = 0 ; i < columns ; i++){
		for(unsigned j = 0 ; j < rows ; j++){
			if(array[i + j * rows] == 0) continue;
			count++;
		}
	}
	long vals = count;
	
	SMat S = svdNewSMat(rows, columns, vals);
	count = 0;
	for(unsigned i = 0 ; i < columns ; i++){
		S->pointr[i] = count;
		for(unsigned j = 0 ; j < rows ; j++){
			if(array[i+j*rows] ==0) continue;
			S->rowind[count] = j;
			S->value[count] = array[i + j* rows];
			count++;
		}
	}
	S->pointr[columns] = vals;
	return S;
};

//Computes a "D" eigensystem of a semidefinite sparse matrix S.
ESys sparseSDEig(SMat S, long d){
	unsigned dim = S->cols;
	
	SVDRec svd = svdLAS2A(S,d);
	ESys E = newESys(dim, d);
	for (unsigned i = 0 ; i < d ; i++){
		for(unsigned j = 0 ; j < dim ; j++){
			E -> vecs[i][j] = svd->Vt->value[i][j];
		}
		E ->vals[i] = (svd->S[i]);
	}
	return E;
}
void freeESys(ESys E){
	//minimal error checking...
	if (!E) return;
	free(E->vecs[0]);
	free(E->vecs);
	free(E);
}

ESys newESys(unsigned dim, unsigned num) {
	ESys E = (ESys) malloc(sizeof(struct esys));
	E ->	dim = dim;
	E -> num = num;
	
	//returns an eigensystem structure with vectors stored as vecs[#][entry]
	//and eigenvalues stored as vals[#]
	
	E -> vecs = (double **)malloc(num* sizeof(double *));
	E -> vecs[0] = (double *)calloc(num * dim , sizeof(double));
	for(unsigned i = 1 ; i < num ; i++){
		E->vecs[i] = E->vecs[i-1]+dim;
	}
	E -> vals = (double *)calloc(num , sizeof(double));
	return E;
}
	
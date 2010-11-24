/*
 *  MyKNN.h
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef KNN_H
#define KNN_H
#include "svdlib.h"


#ifdef __cplusplus 
extern "C"{
#endif
	struct scmat {
		long m;					//number of constraints
		SMat * smats;			//constraint matrices
		float * constraints;	//constraint values
	};
	typedef struct scmat *SCMat;

	SCMat knnNewSCMat(unsigned m);      //creates an empty matrix of constraints.
	void knnSetConstraint(SCMat SC, unsigned idx, SMat S, float constraint);
	SCMat fvsGetConstraints(unsigned data_size, unsigned * KNNs,unsigned data_dim, float * data);	
	float fvDotProduct(unsigned data_dimension, const float * d1, const float * d2);
	void uvnSquareMatrix(unsigned data_size, unsigned * data, unsigned * square);

	void fvnKNN2Constraints(unsigned data_size, unsigned * data, unsigned **);
	void fvnGetKNN(unsigned data_dimension, unsigned data_size, const float * data, unsigned k, unsigned * KNNs);
	void uvnSymmetrizeMatrix(unsigned data_size, unsigned * data);
	//void fvsGetKNN(
#ifdef __cplusplus 
}
#endif
	
#endif
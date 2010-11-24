/*
 *  KNN.h
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef KNN_H
#define KNN_H

#ifdef __cplusplus 
extern "C"{
#endif
	
	void fvnGetKNN(unsigned data_dimension, unsigned data_size, const float * data, unsigned k, unsigned * KNNs);
	void uvnSymmetrizeMatrix(unsigned data_size, unsigned * data);
	//void fvsGetKNN(
#ifdef __cplusplus 
}
#endif
	
#endif
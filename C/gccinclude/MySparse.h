/*
 *  MySparse.h
 *  SDE
 *
 *  Created by Benjamin Holmes on 9/20/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef MySparse_H
#define MySparse_H
#include "svdlib.h"

typedef struct esys * ESys;
struct esys {
	unsigned dim;
	unsigned num;
	double ** vecs;
	double * vals;
};

void printSparse(SMat S);
ESys sparseSDEig(SMat S, long d);
void freeESys(ESys E);
ESys newESys(unsigned dim, unsigned num) ;
SMat sparseFromArray(long rows, long columns, double * vals);

#endif
/*
 *  MySDE.c
 *  MyMath
 *
 *  Created by Benjamin Holmes on 9/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "MySDE.h"
#include <stdio.h>

void SDEPrintConstraints(FILE * file, SCMat SC){
	unsigned dim = SC->smats[0]->rows;
	fprintf(file, "%ld\n1\n%ld\n",
			//notice that there are m+1 constraints when you include the criterion that elements of k sum to zero.
			SC->m+1,dim);

	fprintf(file,"  0.0");
	for(int i = 0 ; i < SC->m ; i++){
		fprintf(file,"  %.18e" ,SC->constraints[i]);
	}
	//print the final constraint that all entries sum to zero.
	fprintf(file," \n");
	
	//print the matrix for the objective function.
	for(int i = 0 ; i < dim;i++){
			fprintf(file, "0 1 %ld %ld -1\n", i+1, i+1);
	}

	//print the sum to zero constraint matrix
	for(int i = 0 ; i<dim ;  i++){
		for(int j = i ; j < dim ; j++){
			fprintf(file,"%ld 1 %ld %ld %g\n",1, i+1, j+1, 1.0);
		}
	}
	
	//print each of the first m sparse constraint matrices
	for(int m= 2 ; m <= SC->m + 1 ; m++){
		unsigned col = 0;
		SMat S=SC->smats[m-2];
		for(int v = 0; v<S->vals; v++){
			while(v >= S->pointr[col +1])col++;
			unsigned row = S->rowind[v];
			double val = S->value[v];
			//print only upper triangular constraints
			if(row >= col) fprintf(file,"%ld 1 %ld %ld %g\n", m, col + 1, row + 1, val);
		}
	}

}


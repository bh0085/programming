/*
 *  geneStream.h
 *  Agents1
 *
 *  Created by Benjamin Holmes on 10/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define MAX_GENES 200
#define N_BYTES 50
typedef struct geneStream {
	int maxGenes;
	int nBytes;
	int byteCushion;
	int nGenes;
	unsigned char stream[N_BYTES*MAX_GENES];	
} geneStream;


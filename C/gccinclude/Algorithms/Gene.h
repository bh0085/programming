/*
 *  Gene.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef GENE_H
#define GENE_H
#include "BitArray.h"
class Gene:public BitArray{
public:
	float Gene::nByteFraction(unsigned byte_offset,unsigned n_bytes) const;
	Gene();	
	Gene(int maxlength);	
	Gene(const Gene& g);
	static void Gene::singleCross(Gene& g1,Gene& g2,unsigned position);
	static void Gene::doubleCross(Gene& g1, Gene& g2, unsigned p1, unsigned p2);
	void Gene::matrixExtractColumnToInt(unsigned * extracted, unsigned column, unsigned columnSize) const;
	static void Gene::matrixCrossColumn(Gene & g1, Gene & g2, unsigned column, unsigned columnSize);

	void mutate();

};

#endif
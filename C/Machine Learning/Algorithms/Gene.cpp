/*
 *  Gene.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "Gene.h"
#include <cstring>
#include <stdlib.h>
#include <math.h>
#include <climits> // FOR CHAR_BIT

static const char BIT_MASK=1;
static const unsigned bits_per_word = CHAR_BIT * sizeof(char);

//since Gene has no members that BitArray does not, I can just call the Bitarray Constructors and not worry about slicing
Gene::Gene():BitArray(){};
Gene::Gene(int maxlength):BitArray(maxlength){};	
Gene::Gene(const Gene& g):BitArray((BitArray)g){};

void Gene::singleCross(Gene& g1,Gene& g2,unsigned position){
	Gene g1temp = g1;
	unsigned word = position / bits_per_word;
	unsigned bit = position % bits_per_word;
	unsigned byte_before = word * sizeof(g1.data[0]);
	memcpy(g1temp.data, g2.data, byte_before);
	memcpy(g2.data, g1.data, byte_before);
	for(int i = 0 ; i < bit ; i++){
		if( (g1.data[word] & (BIT_MASK << i)) != (g2.data[word] & (BIT_MASK << i)) ){
			unsigned pos = i + word * bits_per_word;
			g1temp.toggle(pos);
			g2.toggle(pos);
		}
	}
	g1 = g1temp;
};
void Gene::doubleCross(Gene& g1, Gene& g2, unsigned p1, unsigned p2){
	Gene gtemp = g1;
	singleCross(g1,g2,p1);
	singleCross(g1,g2,p2);
}
void Gene::matrixExtractColumnToInt(unsigned * extracted, unsigned column, unsigned columnSize) const{
	unsigned start = column * columnSize;
	for (int i = 0 ; i < columnSize ; i++){
		unsigned pos = start +i;
		extracted[i] = getBit(pos);
	}
}
	
void Gene::matrixCrossColumn(Gene & g1, Gene & g2, unsigned column, unsigned columnSize){
	unsigned p1 = column*columnSize;
	unsigned p2 = (column + 1)*columnSize;
	doubleCross(g1,g2,p1,p2);
}

void Gene::mutate(){
	unsigned r = rand() % length();
	toggle(r);
}
float Gene::nByteFraction(unsigned byte_offset,unsigned n_bytes) const{
	float sum = 0.0;
	for(int i = 0 ; i < n_bytes ; i++){
		unsigned char b;
		bytesAtByte(byte_offset + i, &b, 1);
		sum= sum + ( ( (float)b ) * pow(256,i));
	}
	return sum / pow(256,n_bytes);
}



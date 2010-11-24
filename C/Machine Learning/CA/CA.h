/*
 *  CA.h
 *  CA
 *
 *  Created by Benjamin Holmes on 10/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "BitArray.h"
class CA{
public:
	unsigned N;
	unsigned M;
	BitArray arr;
	BitArray rules;
	unsigned rval;
	CA(unsigned num,unsigned max_itr);
	void CA::Display();
	void CA::initRandom();
	void CA::run();

};
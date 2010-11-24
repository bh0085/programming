/*
 *  main.h
 *  Algorithms
 *
 *  Created by Benjamin Holmes on 10/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "stdio.h"
#include "BitArray.h"
//#include "GA0.h"

int main(int argc, char *argv[])
{
	//GA0 * ga = new GA0();
	BitArray * ba = new BitArray;
	BitArray ba2;
	ba2 = *(ba);
	printf("hello world");
	return 0;
}

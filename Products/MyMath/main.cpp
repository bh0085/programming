/*
 *  main.cpp
 *  Algorithms
 *
 *  Created by Benjamin Holmes on 10/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "stdio.h"
#include "BitArray.h"

int main(int argc, char *argv[])
{
	BitArray * ba = new BitArray;
	BitArray ba2;
	ba2 = *ba;
	printf("hello world");
}
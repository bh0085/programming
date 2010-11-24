/*
 *  GLFT.h
 *  MyGL
 *
 *  Created by Benjamin Holmes on 6/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
//#ifndef __cplusplus
#ifndef GLFT_H
#define GLFT_H
#include <OpenGL/OpenGL.h>
#include "FreetypeManager.h"


unsigned int makeDisplayLists(FreetypeManager * manager);
void printCharacter(  unsigned int whichChar, unsigned int baseList);
void printString(FreetypeManager * manager, const char * printThis, unsigned int baseList);
#endif
//#endif
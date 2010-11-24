/*
 *  GLFT.c
 *  MyGL
 *
 *  Created by Benjamin Holmes on 6/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GLFT.h"

unsigned int makeDisplayLists(FreetypeManager * manager){
	
	glColor3d(1, 1, 1);
	glOrtho(0, 1, 0, 1, -100, 100);
	glClearColor(.4,.4,.4,0);
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	unsigned char charBase = 32;
	unsigned char count = 96;
	
	unsigned int baseList = glGenLists(128);
		
	for(int i = 0 ; i < count ; i++){
		//call myfreetype function getfontpixels
		unsigned char * pixels = getFontPixels(manager, i + charBase );
		glNewList(baseList+i+charBase, GL_COMPILE); 
		glDrawPixels(getFTWidth(manager),getFTHeight(manager),GL_ALPHA,GL_UNSIGNED_BYTE,pixels);		
		glEndList();
		free(pixels);
	}
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	return baseList;
};
void printCharacter(  unsigned int whichChar , unsigned int baseList){
	glCallList(baseList + whichChar);
};
void printString(FreetypeManager * manager, const char * printThis, unsigned int baseList){
		
	GLfloat rasPos[4];
	glGetFloatv(GL_CURRENT_RASTER_POSITION, rasPos);

	for(int i = 0 ; i < strlen(printThis) ; i++){
		unsigned char temp = printThis[i];
		printCharacter( temp,baseList);
		rasPos[0]+=(0+ widthOfCharacter(manager,printThis[i]));
		glRasterPos4fv(rasPos);
	}
}
 


/*
 *  GLFT.c
 *  MyGL
 *
 *  Created by Benjamin Holmes on 6/29/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
//#include "GLIDL.h"
#include "GLFT.h"

unsigned int makeDisplayLists(FreetypeManager * manager){
	
	unsigned char charBase = 32;
	unsigned char count = 96;
	float RGBA[4];
	glGetFloatv(GL_CURRENT_COLOR, RGBA) ;
	unsigned int baseList = glGenLists(128);
	for(int i = 0 ; i < count ; i++){
		//call myfreetype function getfontpixels
		unsigned char * pixels = getFontRGBA(manager, i + charBase ,RGBA);
		glNewList(baseList+i+charBase, GL_COMPILE); 
		glDrawPixels(getFTWidth(manager),getFTHeight(manager),GL_RGBA,GL_UNSIGNED_BYTE,pixels);
		glEndList();
		free(pixels);
	}
	
	return baseList;
};
void printCharacter(  unsigned int whichChar , unsigned int baseList){
	glCallList(baseList + whichChar);
};
void printString(FreetypeManager * manager, const char * printThis, unsigned int baseList){
		
	GLfloat rasPos[4];
	glGetFloatv(GL_CURRENT_RASTER_POSITION, rasPos);
	float viewXY[2];
	viewXY[0] = rasPos[0];
	viewXY[1] = rasPos[1];

	for(int i = 0 ; i < strlen(printThis) ; i++){
		unsigned char temp = printThis[i];
		printCharacter( temp,baseList);
		viewXY[0] +=widthOfCharacter(manager,printThis[i]);
		glWindowPos3f(viewXY[0], viewXY[1], 0);
	}
}

 


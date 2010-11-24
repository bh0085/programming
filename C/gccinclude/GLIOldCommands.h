//
//  GLIOldCommands.h
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 8/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifndef GLIOLDCOMMANDS_H
#define GLIOLDCOMMANDS_H
#ifdef __cplusplus
extern "C"{
#endif

unsigned int plotNormalized(float x[], float y[],unsigned int size);
unsigned int getEmptyArray();	
void GLIGetOrthoViewBounds(float bounds[6]);
void GLIViewBounds(float bounds[6]);
void GLIClear();
void GLIFlush();
void GLIColorRed(unsigned int whichArray);
void GLIColorBlue(unsigned int whichArray);
void GLIColorGreen(unsigned int whichArray);
void GLIColorOrange(unsigned int whichArray);
void GLIColorPurple(unsigned int whichArray);
void GLIPlotStyleLines(unsigned int whichArray);
void GLIPlotStyleLineLoop(unsigned int whichArray);
void GLIPlotStylePoints(unsigned int whichArray);
void GLIAxis2f(float x, float y);
void GLIPlot3f(unsigned int whichArray, float x, float y, float z);
void GLIPlotNormalizedCircle3f( int array, float x, float y, float radius);
void GLIColor3f(unsigned int whichArray, float r, float g, float b);

#ifdef __cplusplus
}
#endif
#endif
	

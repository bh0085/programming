//
//  GLIOldCommands.m
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 8/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLIOldCommands.h"

static unsigned int GLIPlotArraySizes[256];
static unsigned int GLIPlotArrayIndices[256];
static float *  GLIPlotArrayPointers[256];
static float GLIPlotArrayColors[256][3];
static unsigned int GLIPlotArrayTypes[256];

extern void GLIViewBounds(float bounds[]){
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(bounds[0],bounds[1],bounds[2],bounds[3],bounds[4],bounds[5]);
	glMatrixMode(GL_MODELVIEW);		
}
extern void GLIGetOrthoViewBounds(float bounds[6]){
	float proj16[16];
	glGetFloatv(GL_PROJECTION_MATRIX,proj16);
	float proj16inverse[16];
	for(int i = 0 ; i < 16; i++){
		proj16inverse[i] = 0;
	}
	
	proj16inverse[0] =1/proj16[0];
	proj16inverse[5] =1/proj16[5];
	proj16inverse[10]=1/proj16[10];
	proj16inverse[12]=-proj16[12]/proj16[0];
	proj16inverse[13]=-proj16[13]/proj16[5];
	proj16inverse[14]=-proj16[14]/proj16[10];
	proj16inverse[15]=proj16[15];
	
	bounds[0] = -1*proj16inverse[0] + proj16inverse[12];
	bounds[1] =  1*proj16inverse[0] + proj16inverse[12];
	bounds[2] = -1*proj16inverse[5] + proj16inverse[13];	
	bounds[3] =  1*proj16inverse[5] + proj16inverse[13];	
	bounds[4] = -1*proj16inverse[10] + proj16inverse[14];	
	bounds[5] =  1*proj16inverse[10] + proj16inverse[14];	
}
extern void GLIClear(){
	glClear(GL_COLOR_BUFFER_BIT);
}
extern void GLIPlotNormalizedCircle3f(int array, float x, float y, float radius){
#define PI 3.14159
	glColor3f(GLIPlotArrayColors[array][0],GLIPlotArrayColors[array][1],GLIPlotArrayColors[array][2]);	
	int npoints = 10;
	
	float viewBounds[6];
	GLIGetOrthoViewBounds(viewBounds);
	
	float plotx = x*(viewBounds[1] - viewBounds[0]) + viewBounds[0];
	float ploty = y*(viewBounds[3] - viewBounds[2]) + viewBounds[2];
	float plotradius =  radius*(viewBounds[1] - viewBounds[0]);
	glBegin(GL_LINE_LOOP);
	for(int i=0; i <npoints; i++)
		glVertex3f(plotx + sin(((float)i)/npoints*PI* 2)*plotradius,ploty+ cos(((float)i)/npoints*PI* 2)*plotradius, 0);
	glEnd();
}
extern void GLIFlush(){
	
	
	//now search plot each nonempty array.
	for(int i = 0 ; i < 256 ; i++){
		
		glColor3f(GLIPlotArrayColors[i][0],GLIPlotArrayColors[i][1],GLIPlotArrayColors[i][2]);
		switch (GLIPlotArrayTypes[i]){
			case 0:
				glBegin(GL_POINTS);
				break;
			case 1:
				glBegin(GL_LINE_STRIP);
				break;
			case 2:
				glBegin(GL_LINE_LOOP);
				break;
			default:
				glBegin(GL_POINTS);
				
		}
		
		if(GLIPlotArrayTypes[i] == 0){
			glBegin(GL_POINTS);
		} else {
			glBegin(GL_LINE_LOOP);
		}
		for(int j = 0 ; (j + 2) < (GLIPlotArrayIndices[i]) ; j+=3){
			glVertex3f(	
					   GLIPlotArrayPointers[i][j],
					   GLIPlotArrayPointers[i][j+1],
					   GLIPlotArrayPointers[i][j+2]
					   );
			
		}	
		glEnd();
		if( GLIPlotArraySizes[i] !=0){
			free(GLIPlotArrayPointers[i]);
		}
		GLIPlotArrayIndices[i] = 0;
		GLIPlotArraySizes[i] = 0;
		
	}
	
	
	[[NSOpenGLContext currentContext] flushBuffer];	
}
extern void GLIAxis2f(float x, float y){
	
	glColor4f(1,1,1,.1);
	glBegin(GL_LINES);
	glVertex2f(x - 100, y);
	glVertex2f(x + 100, y);
	//glVertex2f(x,y-100);
	//glVertex2f(x,y+100);
	glEnd();
}
//plot a point to one of 256 arrays...
extern void GLIPlot3f(unsigned int whichArray ,float x, float y, float z){
	//first, if no points have been added to the current plot generate an array pointer.
	if(GLIPlotArrayIndices[whichArray] == 0){
		GLIPlotArrayPointers[whichArray] = malloc(sizeof(float) * 30000);
		GLIPlotArraySizes[whichArray] = 30000;
	}
	//next, if points have been added but the array is at capacity, resize by creating a larger copy.
	if(GLIPlotArrayIndices[whichArray] + 2 >= GLIPlotArraySizes[whichArray]){
		unsigned int newSize = GLIPlotArraySizes[whichArray] + 30000;
		float * newArray = malloc(sizeof(float) * newSize);
		memcpy(newArray, GLIPlotArrayPointers[whichArray], sizeof(float) * GLIPlotArraySizes[whichArray]);
		free(GLIPlotArrayPointers[whichArray]);
		GLIPlotArrayPointers[whichArray] = newArray;
		GLIPlotArraySizes[whichArray] = newSize;
	}
	//finally, place the new point in the appropriately sized array
	GLIPlotArrayPointers[whichArray][GLIPlotArrayIndices[whichArray]] = x;
	GLIPlotArrayPointers[whichArray][GLIPlotArrayIndices[whichArray]+1] = y;
	GLIPlotArrayPointers[whichArray][GLIPlotArrayIndices[whichArray]+2] = z;
	//and increment the index by three - the number of floats added.
	GLIPlotArrayIndices[whichArray]+=3;
	
};
extern unsigned int plotNormalized(float x[], float y[], unsigned int size){
	float viewBounds[6];
	GLIGetOrthoViewBounds(viewBounds);
	unsigned int whichArray = getEmptyArray();
	for(int i = 0 ; i <size ; i++){
		float plotx = x[i]*(viewBounds[1] - viewBounds[0]) + viewBounds[0];
		float ploty = y[i]*(viewBounds[3] - viewBounds[2]) + viewBounds[2];
		
		GLIPlot3f(whichArray,plotx,ploty , 0);
		
	}	
	
	
	return whichArray;
}
extern unsigned int getEmptyArray(){
	for( int i = 0 ; i < 256 ; i++){
		if(GLIPlotArrayIndices[i] == 0){return i;}
	}
	return -1;
}
extern void GLIColorRed(unsigned int whichArray){
	GLIColor3f(whichArray,1,0,0);
};
extern void GLIColorBlue(unsigned int whichArray){
	GLIColor3f(whichArray,0,0,1);
};
extern void GLIColorGreen(unsigned int whichArray){
	GLIColor3f(whichArray,0,1,0);
};
extern void GLIColorOrange(unsigned int whichArray){
	GLIColor3f(whichArray,1,.5,0);
};
extern void GLIColorPurple(unsigned int whichArray){
	GLIColor3f(whichArray,.5,0,.5);
};
extern void GLIPlotStyleLines(unsigned int whichArray){
	GLIPlotArrayTypes[whichArray] =1;
}
extern void GLIPlotStyleLineLoop(unsigned int whichArray){
	GLIPlotArrayTypes[whichArray] =2;
}
extern void GLIPlotStylePoints(unsigned int whichArray){
	GLIPlotArrayTypes[whichArray] =0;
}
extern void GLIColor3f(unsigned int whichArray, float r, float g, float b){
	GLIPlotArrayColors[whichArray][0]=r;
	GLIPlotArrayColors[whichArray][1]=g;
	GLIPlotArrayColors[whichArray][2]=b;
};


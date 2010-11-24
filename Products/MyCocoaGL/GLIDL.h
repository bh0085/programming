/*
 *  GLIDL.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/7/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef GLIDL_H
#define GLIDL_H
#ifndef __cplusplus
#include "GLIController.h"
#else
class GLIController;
#endif

#ifdef __cplusplus
extern "C"{
#endif
	
	struct plotPrefsStructure
	{
		int drawtype;
		int psym;
		int draw3ftype;
		int scanwidth;
		bool filledarc;
	};
	typedef struct plotPrefsStructure  PPStruct; 

	void window( int idx);
	void windowAtXY( int idx, int xy[2]);
	void windowAtXYWithSize( int idx, int xy[2], int size[2]);
	void plot2f(float xs[],float ys[], int size);
	void plot3f(float xs[],float ys[], float zs[], int size);
	void oplot2f(float xs[],float ys[], int size);
	void oplot3f(float xs[],float ys[], float zs[], int size);
	void splot_increment();
	void splot1f(float y);

	void plots_circle(float x, float y, float r);
	void plots_screen_circle(float x, float y, float r);
	void plots_ellipse(float x, float y, float rx, float ry);
	void plots_ellipse_arc(float x, float y, float rx, float ry, float thetai, float theta,float thick);
	void fullScreenQuad();

	
	void GLIDLSetPSym(int psym);
	void GLIDLSetScanWidth(int scanwidth);
	
	void GLIDLSetViewBounds(float bounds[6]);	
	void GLIDLSetViewBoundsWithMargin(float bounds[6],float margin);	
	void GLIDLSetBoundsToArrayWithMargin(float xs[], float ys[], float size, float margin);
	void GLIDLSetBoundsToArrayWithMarginAndTolerance(float xs[], float ys[], float size, float margin, float tolerance);
	void GLIDLClear();
	void GLIDLLabelAxes();
	void GLIDLFlushBuffer();
	
	//preferences
	extern void GLIDLSetArcFilled(int filled);
	
	void GLIDLviewportXYOfOrtho(float orthoXY[2], float viewXY[2]);
	void GLIDLorthoXYOfViewport(float viewXY[2], float orthoXY[2]);
	void GLIDLorthoXYOfOnePixel(float orthoXY[2]);
	void GLIDLGetOrthoViewBounds(float bounds[6]);
	float get_scan_x();



 
#ifdef __cplusplus
}
#endif
#endif
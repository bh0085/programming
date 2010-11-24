//
//  NN3GLView.h
//  NeuralNet3
//
//  Created by Benjamin Holmes on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifndef __cplusplus

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>


@interface NN3GLView : NSOpenGLView {
	

}
-(NSOpenGLPixelFormat *) createMultisamplePixelFormat;
-(void) reshape;
-(void) initNowWithFrame:(NSRect)frame;
-(void) drawView;
-(void) setRange:(float *) params;


@end

#endif
#ifdef __cplusplus
extern "C"{
#endif
unsigned int NNGLPlotArraySizes[256];
unsigned int NNGLPlotArrayIndices[256];
float *  NNGLPlotArrayPointers[256];
float NNGLPlotArrayColors[256][3];
void NNGLFlush();
	
	void NNGLColorRed(unsigned int whichArray);
	void NNGLColorBlue(unsigned int whichArray);
	void NNGLColorGreen(unsigned int whichArray);
	void NNGLColorOrange(unsigned int whichArray);
	void NNGLColorPurple(unsigned int whichArray);
	
	
void NNGLAxis2f(float x, float y);
void NNGLPlot3f(unsigned int whichArray, float x, float y, float z);
void NNGLColor3f(unsigned int whichArray, float r, float g, float b);
#ifdef __cplusplus
}
#endif

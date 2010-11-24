/*
 *  GLIDL.m
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/7/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "GLIController.h"
#include "GLIDL.h"
#include "MyCIDL.h"
#include <math.h>
#include <OpenGL/OpenGL.h>

#define PI 3.14159
#define circnum 40
#define SPLOT_MEMORY 10
static bool isInitialized;
static PPStruct plotPrefs;

//Forward Declarations of Local Functions

void compute_circle();
void GLIDLDrawArray2f(float xs[], float ys[], int size);
void GLIDLDrawArray3f(float xs[], float ys[], float zs[], int size);
void setOrthoForPlot(float xs[], float ys[], int size);
void glDoubleBufferFlush();
void printTextAtViewXY(const char * str, float *viewXY);
void printTextAtOrthoXY(const char * str, float *viewXY);
void labelAxes();
void drawAxis();
void initGLIDL();
void get_circle(float cx[circnum],float cy[circnum],float x,float y, float r);
void get_ellipse(float cx[circnum],float cy[circnum],float x,float y, float rx,float ry);
void GLIDLDrawPoint2f(float x, float y);


//IDL Global display functions
extern void window(int idx){
	[[GLIController getActiveController] window:idx];
	if(!isInitialized)initGLIDL();
}
extern void windowAtXY(int idx, int xy[2]){
	[[GLIController getActiveController] window:idx AtXY:xy];
	if(!isInitialized)initGLIDL();
}
extern void windowAtXYWithSize(int idx, int xy[2], int size[2]){
	[[GLIController getActiveController] window:idx AtXY:xy WithSize:size];
	if(!isInitialized)initGLIDL();
}
extern void plot2f(float xs[],float ys[], int size){
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	setOrthoForPlot(xs, ys, size);
	labelAxes();
	GLIDLDrawArray2f(xs,ys,size);
}
extern void plot3f(float xs[],float ys[], float zs[], int size){
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	setOrthoForPlot(xs, ys, size);
	labelAxes();
	GLIDLDrawArray3f(xs,ys,zs,size);
}
extern void oplot2f(float xs[],float ys[], int size){
	GLIDLDrawArray2f(xs,ys,size);
}

extern void oplot3f(float xs[],float ys[],float zs[],int size){
	GLIDLDrawArray3f(xs,ys,zs,size);
}

float scan_x;
float point_lastxys[SPLOT_MEMORY][2];
int splot_memory_marker;
extern float get_scan_x(){
	return scan_x;
};
extern void splot1f(float y){
	GLIDLDrawPoint2f(scan_x,y);
	point_lastxys[splot_memory_marker][0] = scan_x;
	point_lastxys[splot_memory_marker][1] = y;
	splot_memory_marker++;



}
extern void splot_increment(){
	scan_x += 1.0;
	if(((int)scan_x) == plotPrefs.scanwidth){
		scan_x = 0.0;
		GLIDLClear();
	}
	splot_memory_marker = 0;
}
void GLIDLDrawPoint2f(float x, float y){
	if (plotPrefs.psym == -1){
		if(scan_x != 0){
		glBegin(GL_LINES);
		glVertex3f(point_lastxys[splot_memory_marker][0],point_lastxys[splot_memory_marker][1],0);
		glVertex3f(x,y,0.0);
		glEnd();
		}
	} else if (plotPrefs.psym == 0) {
		float pixScale[2];
		GLIDLorthoXYOfOnePixel(pixScale);
		float rx = 5 * pixScale[0];
		float ry = 5 * pixScale[1];
		plots_ellipse(x,y,rx,ry);
	} else if (plotPrefs.psym = 1) {
		glBegin(GL_POINTS);
		glVertex3f(x,y,0.0);
		glEnd();
		
	}
}

extern void plots_circle(float x, float y, float r){
	float xs[circnum];
	float ys[circnum];
	get_circle(xs, ys, x, y, r);
	glBegin(GL_LINE_LOOP);
	for(int i = 0 ; i < circnum ; i++){
		glVertex3f(xs[i],ys[i],0);
	}
	glEnd();
}
extern void plots_ellipse(float x, float y, float rx, float ry){
	float xs[circnum];
	float ys[circnum];
	get_ellipse(xs, ys, x, y, rx,ry);
	glBegin(GL_LINE_LOOP);
	for(int i = 0 ; i < circnum ; i++){
		glVertex3f(xs[i],ys[i],0);
	}
	glEnd();	
 
}
extern void plots_screen_circle(float x, float y, float r){
	float xs[circnum];
	float ys[circnum];
	float pixScale[2];
	GLIDLorthoXYOfOnePixel(pixScale);
	float rx = pixScale[0]*r;
	float ry = pixScale[1]*r;
	get_ellipse(xs, ys, x, y, rx,ry);
	glBegin(GL_LINE_LOOP);
	for(int i = 0 ; i < circnum ; i++){
		glVertex3f(xs[i],ys[i],0);
	}
	glEnd();	
	
}
extern void plots_ellipse_arc(float x, float y, float rx, float ry, float thetai, float thetaf,float thick){
	float xs[circnum];
	float ys[circnum];
	findgen(xs,circnum);
	findgen(ys,circnum);
	scaleArrayf(xs, (thetaf - thetai)/(circnum -1), circnum);
	scaleArrayf(ys, (thetaf - thetai)/(circnum -1), circnum);
	addConstantToArrayf(xs, thetai, circnum);
	addConstantToArrayf(ys, thetai, circnum);
	cosOfArrayf(xs, circnum);
	sinOfArrayf(ys, circnum);
	scaleArrayf(xs, rx, circnum);
	scaleArrayf(ys, ry, circnum);	
	
	float xouter[circnum];
	float youter[circnum];
	for(int i = 0 ; i < circnum ; i++){
		xouter[i] = xs[i]*thick;
		youter[i] = ys[i]*thick;
		xs[i]+=x;
		ys[i]+=y;
		xouter[i]+=x;
		youter[i]+=y;
	}
	GLfloat verts[circnum*2][3];
	for(int i = 0 ; i < circnum;i++){
		verts[(2*i)][0] = xs[i];
		verts[(2*i)][1] = ys[i];
		verts[(2*i)][2] = 0;
		verts[(2*i)+1][0]=xouter[i];
		verts[(2*i)+1][1]=youter[i];
		verts[(2*i)+1][2] = 0;
	}
	
	if( plotPrefs.filledarc){
		GLubyte indices[(circnum-1)*4];
	
		for(GLubyte i = 0 ; i < circnum-1 ; i++){
			indices[4*i] = 2*(i);
			indices[4*i +1] = 2*(i)+1;
			indices[4*i +2] = 2*(i+1)+1;
			indices[4*i +3] = 2*(i+1);
		}

		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, verts);
		glDrawElements(GL_QUADS , (circnum -1)*4, GL_UNSIGNED_BYTE, indices);
		glDisableClientState(GL_VERTEX_ARRAY);	
	} else {
		GLubyte indices[(circnum)*2];
		
		for(GLubyte i = 0 ; i < circnum*2 ; i++){
			if(i < circnum){
				indices[i] = (2*(i%circnum) );
			} else {
				indices[i] = (2 * circnum - (2*(i%circnum) )) - 1;
			}
		}
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, verts);
		glDrawElements(GL_LINE_LOOP , (circnum )*2, GL_UNSIGNED_BYTE, indices);
		glDisableClientState(GL_VERTEX_ARRAY);			
	}
	
}
extern void fullScreenQuad(){
	float bounds[6];
	GLIDLGetOrthoViewBounds(bounds);
	glBegin(GL_QUADS);
	glVertex2f(bounds[0],bounds[2]);
	glVertex2f(bounds[1],bounds[2]);
	glVertex2f(bounds[1],bounds[3]);
	glVertex2f(bounds[0],bounds[3]);
	glEnd();
}

//Non IDL Global functions
extern void GLIDLSetBoundsToArrayWithMargin(float xs[], float ys[], float size, float margin){
	float xRange[2] = {xs[0],xs[0]};
	float yRange[2] = {ys[0],ys[0]};
	for( int i = 0 ; i < size ; i++){
		if(xs[i] > xRange[1]) xRange[1] = xs[i];
		if(xs[i] < xRange[0]) xRange[0] = xs[i];
		if(ys[i] > yRange[1]) yRange[1] = ys[i];
		if(ys[i] < yRange[0]) yRange[0] = ys[i];		
	}
	float width = xRange[1] - xRange[0];
	float height= yRange[1] - yRange[0];
	xRange[0]-=margin*width;
	xRange[1]+=margin*width;
	yRange[0]-=margin*height;
	yRange[1]+=margin*height;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(xRange[0], xRange[1], yRange[0], yRange[1], -100, 100); 
	glMatrixMode(GL_MODELVIEW);
}
extern void GLIDLSetBoundsToArrayWithMarginAndTolerance(float xs[], float ys[], float size, float margin, float tolerance){
	float xRange[2] = {xs[0],xs[0]};
	float yRange[2] = {ys[0],ys[0]};
	for( int i = 0 ; i < size ; i++){
		if(xs[i] > xRange[1]) xRange[1] = xs[i];
		if(xs[i] < xRange[0]) xRange[0] = xs[i];
		if(ys[i] > yRange[1]) yRange[1] = ys[i];
		if(ys[i] < yRange[0]) yRange[0] = ys[i];		
	}
	float width = xRange[1] - xRange[0];
	float height= yRange[1] - yRange[0];
	xRange[0]-=margin*width;
	xRange[1]+=margin*width;
	yRange[0]-=margin*height;
	yRange[1]+=margin*height;
	float xTol = width*tolerance;
	float yTol = height*tolerance;
	
	float currentBounds[6];
	GLIDLGetOrthoViewBounds(currentBounds);
	if(
		absf(xRange[0] - currentBounds[0]) > xTol ||
		absf(xRange[1] - currentBounds[1]) > xTol ||
		absf(yRange[0] - currentBounds[2]) > yTol ||
		absf(yRange[1] - currentBounds[3]) > yTol
	   ){
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(xRange[0], xRange[1], yRange[0], yRange[1], -100, 100); 
		glMatrixMode(GL_MODELVIEW);
	}
}
extern void GLIDLSetViewBounds(float bounds[6]){
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(bounds[0],bounds[1],bounds[2],bounds[3],bounds[4],bounds[5]);
	glMatrixMode(GL_MODELVIEW);		
}
extern void GLIDLSetViewBoundsWithMargin(float bounds[6],float margin){
	float xWidth = bounds[1] - bounds[0];
	float yWidth = bounds[3] - bounds[2];
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(bounds[0]-margin * xWidth,bounds[1]+margin*xWidth,
			bounds[2]-margin*yWidth,bounds[3]+margin * yWidth,bounds[4],bounds[5]);
	glMatrixMode(GL_MODELVIEW);		
}
extern void GLIDLGetOrthoViewBounds(float bounds[6]){
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
extern void GLIDLLabelAxes(){
	labelAxes();
}
extern void GLIDLClear(){
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}
extern void GLIDLFlushBuffer(){
	glDoubleBufferFlush();
}


//IDL Global Accessor Methods
extern void GLIDLorthoXYOfOnePixel(float orthoXY[2]){
	float proj16[16];
	glGetFloatv(GL_PROJECTION_MATRIX,proj16);
	orthoXY[0] =1/proj16[0];
	orthoXY[1] =1/proj16[5];
	int view4[4];
	glGetIntegerv(GL_VIEWPORT, view4);
	int viewSize[2] = {view4[2]-view4[0],view4[3]-view4[1]};
	orthoXY[0]/=viewSize[0];
	orthoXY[1]/=viewSize[1];
}
extern void GLIDLviewportXYOfOrtho(float orthoXY[2], float viewXY[2]){
	float proj16[16];
	glGetFloatv(GL_PROJECTION_MATRIX,proj16);
	float proj16inverse[16];
	for(int i = 0 ; i < 16; i++){
		proj16inverse[i] = 0;
	}
	
	int view4[4];
	glGetIntegerv(GL_VIEWPORT, view4);
	int viewSize[2] = {view4[2]-view4[0],view4[3]-view4[1]};
	
	viewXY[0] =viewSize[0]*((proj16[0]*orthoXY[0] + proj16[12]) +1)/2;
	viewXY[1] =viewSize[1]*((proj16[5]*orthoXY[1] + proj16[13]) +1)/2;
}
extern void GLIDLorthoXYOfViewport(float viewXY[2],float orthoXY[2]){
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
	
	int view4[4];
	glGetIntegerv(GL_VIEWPORT, view4);
	int viewSize[2] = {view4[2]-view4[0],view4[3]-view4[1]};		
	
	float normXY[2]={viewXY[0]/viewSize[0] * 2 -1,viewXY[1]/viewSize[1] *2 -1};
	orthoXY[0] = normXY[0]*proj16inverse[0] + proj16inverse[12];
	orthoXY[1] = normXY[1]*proj16inverse[5] + proj16inverse[13];
	
}

//GLIDL Supporting methods
void setOrthoForPlot(float xs[], float ys[],int size ){
	float xRange[2] = {0,0};
	float yRange[2] = {0,0};
	for(int i = 0 ; i < size ; i++){
		if(xs[i] > xRange[1]) xRange[1] = xs[i];
		if(xs[i] < xRange[0]) xRange[0] = xs[i];
		if(ys[i] > yRange[1]) yRange[1] = ys[i];
		if(ys[i] < yRange[0]) yRange[0] = ys[i];
	}
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(xRange[0], xRange[1], yRange[0], yRange[1], -100, 100); 
	glMatrixMode(GL_MODELVIEW);
}
void initGLIDL(){

	scan_x = -1;
	plotPrefs.drawtype = 0;
	plotPrefs.psym = -1;
	plotPrefs.draw3ftype = 0;
	plotPrefs.filledarc = 0;
	isInitialized = true;
	compute_circle();
	
}

//GLIDL Preferences
extern void GLIDLSetPSym(int psym){
	plotPrefs.psym = psym;
}
extern void GLIDLSetScanWidth(int scanwidth){
	plotPrefs.scanwidth = scanwidth;
}
extern void GLIDLSetArcFilled(int filled){
	plotPrefs.filledarc = filled;
}

//GLIDL Stores circles to make them draw faster.
static float cxs[circnum];
static float cys[circnum];
void compute_circle(){
	findgen(cxs, circnum);
	findgen(cys, circnum);
	scaleArrayf(cxs,2 * PI / circnum, circnum);
	scaleArrayf(cys, 2* PI / circnum, circnum);
	cosOfArrayf(cxs, circnum);
	sinOfArrayf(cys, circnum);	
}
void get_circle(float cx[circnum],float cy[circnum],float x,float y, float r){
	for (int i = 0 ; i < circnum ; i++){
		cx[i] = (cxs[i] * r) + x;
		cy[i] = (cys[i] * r) + y;
	}
}
void get_ellipse(float cx[circnum],float cy[circnum],float x,float y, float rx,float ry){
	for (int i = 0 ; i < circnum ; i++){
		cx[i] = (cxs[i] * rx) + x;
		cy[i] = (cys[i] * ry) + y;
	}
}

//Miscellaneous internal methods
void labelAxes(){
	float viewBounds[6];
	GLIGetOrthoViewBounds(viewBounds);
	
	
	float orthoUL[2] = {viewBounds[0],viewBounds[3]};
	float viewUL[2];
	GLIDLviewportXYOfOrtho(orthoUL, viewUL);
	
	NSString * strTemp = [[NSNumber numberWithFloat:viewBounds[3]] stringValue];
	const char * cstr = [strTemp UTF8String];
	viewUL[1]-=20;
	printTextAtViewXY(cstr,viewUL);	
	
	strTemp = [[NSNumber numberWithFloat:viewBounds[1]] stringValue];
	cstr = [strTemp UTF8String];
	int nchars=strlen(cstr);
	float orthoLR[2] = {viewBounds[1],viewBounds[2]};
	float viewLR[2];
	GLIDLviewportXYOfOrtho(orthoLR, viewLR);	
	viewLR[0]-=15*nchars;
	printTextAtViewXY(cstr,viewLR);	
	
}
void drawAxis(){
	
	float viewBounds[6];
	GLIGetOrthoViewBounds(viewBounds);
	float xWidth = viewBounds[1] - viewBounds[0];
	float yWidth = viewBounds[3] - viewBounds[2];
	
	glColor4f(1,1,1,1);
	
	GLfloat xAxis[2][3] = {
		{viewBounds[0] + xWidth * .05, viewBounds[2] + yWidth*.05,0},
		{viewBounds[0] + xWidth * .95, viewBounds[2] + yWidth*.1,0}
	};    
	GLfloat yAxis[2][3] = {
		{viewBounds[0] + xWidth *.05, viewBounds[2]+yWidth*.05,0},
		{viewBounds[0] + xWidth *.1, viewBounds[2]+yWidth*.95,0}
	}; 	
	
	
	// activate and specify pointer to vertex array
	glEnableClientState(GL_VERTEX_ARRAY);
	
	int nTicks = 6;
	GLfloat yTicks[nTicks][6];
	GLfloat xTicks[nTicks][6];
	GLubyte idxs[nTicks*2];
	
	for(int i = 0 ; i < nTicks*2 ; i++){idxs[i] = i;}	
	for(int i = 0 ; i < nTicks ; i++){
		
		
		
		yTicks[i][0] = yAxis[0][0]- xWidth *.01;
		yTicks[i][1] = yAxis[0][1]+ yWidth/nTicks * i -.01; 
		yTicks[i][2] = 0;
		yTicks[i][3] = yAxis[0][0]+ xWidth *.01;
		yTicks[i][4] = yAxis[0][1]+ yWidth/nTicks*i +.01; 
		yTicks[i][5] = 0;
		
		
		xTicks[i][1] = xAxis[0][1]- yWidth *.01;
		xTicks[i][0] = xAxis[0][0]+ xWidth/nTicks * i +.01; 
		xTicks[i][2] = 0;
		xTicks[i][4] = xAxis[0][1]+ yWidth *.01;
		xTicks[i][3] = xAxis[0][0]+ xWidth/nTicks*i -.01; 
		xTicks[i][5] = 0;
		
		
		
	}
	
	
	glVertexPointer(3, GL_FLOAT, 0, yTicks);
	glDrawElements(GL_LINES, nTicks*2, GL_UNSIGNED_BYTE, idxs);		
	glVertexPointer(3, GL_FLOAT, 0, xTicks);
	glDrawElements(GL_LINES, nTicks*2, GL_UNSIGNED_BYTE, idxs);		
	// deactivate vertex arrays after drawing
	glDisableClientState(GL_VERTEX_ARRAY);	
}
void glDoubleBufferFlush(){
	[[NSOpenGLContext currentContext] flushBuffer];	
}
void GLIDLDrawArray3f(float xs[], float ys[], float zs[],int size){
	switch (plotPrefs.draw3ftype) {
		case 0:{
			float pixScale[2];
			GLIDLorthoXYOfOnePixel(pixScale);
			float sxs[10];
			float sys[10];			
			
			for(int i = 0 ; i < size ; i++){
				findgen(sxs, 10);
				scaleArrayf(sxs, .1*2*PI, 10);
				cosOfArrayf(sxs,10);
				scaleArrayf(sxs, pixScale[0]*1*zs[i], 10);
				
				findgen(sys,10);
				scaleArrayf(sys, .1*2*PI, 10);
				sinOfArrayf(sys, 10);
				scaleArrayf(sys, pixScale[1]*1*zs[i], 10);
				
				
				glBegin(GL_LINE_LOOP);
				
				for(int j = 0 ; j < 10 ; j++){
					glVertex3f(xs[i] + sxs[j], ys[i] + sys[j],0);
				}
				glEnd();
			}
			break;
		}
		default:
			break;
	}

	
}
void GLIDLDrawArray2f(float xs[], float ys[], int size){
	
	switch(plotPrefs.psym){
			
			
		case -1:{
			glBegin(GL_LINE_STRIP);
			for(int i =  0; i < size ; i++){
				glVertex3f(xs[i],ys[i],0);
			}
			glEnd();
			break;
		}
		case 0:{
			
			float pixScale[2];

			GLIDLorthoXYOfOnePixel(pixScale);
			float sxs[10];
			findgen(sxs, 10);
			scaleArrayf(sxs, .1*2*PI, 10);
			cosOfArrayf(sxs,10);
			scaleArrayf(sxs, pixScale[0]*3, 10);

			float sys[10];
			findgen(sys,10);
			scaleArrayf(sys, .1*2*PI, 10);
			sinOfArrayf(sys, 10);
			scaleArrayf(sys, pixScale[1]*3, 10);
			float scaling[10];
			findgen(scaling,10);
			modOfArrayf(scaling, 2, 10);
			addConstantToArrayf(scaling, 1, 10);
			multArraysf(sxs, scaling,sxs, 10);
			multArraysf(sys, scaling,sys, 10);
			
			for(int i = 0 ; i < size ; i++){
				glBegin(GL_LINE_LOOP);

				for(int j = 0 ; j < 10 ; j++){
					glVertex3f(xs[i] + sxs[j], ys[i] + sys[j],0);
				}
				glEnd();
			}
			break;
		}
	}	

}
void printTextAtViewXY(const char * str, float * viewXY){
	[[GLIController getActiveController] ftPrint:str atViewXY:viewXY];
}
void printTextAtOrthoXY(const char * str, float * orthoXY){
	[[GLIController getActiveController] ftPrint:str atOrthoXY:orthoXY];
}





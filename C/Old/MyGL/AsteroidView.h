//
//  AsteroidView.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CellShadedModelView.h"
//#import "MyFreetype.h"
#import "FreetypeManager.h"
#import "GLFT.h"
#import <math.h>

@interface AsteroidView : CellShadedModelView {
	GLuint base;    // Base display list for the font set
	GLfloat cnt1;   // 1st Counter Used To Move Text & For Coloring
	GLfloat cnt2;   // 2nd Counter Used To Move Text & For Coloring
	//unsigned char * characterImage;
	FreetypeManager * fontManager;
	unsigned int fontBaseList;
	unsigned int timer;
}
-(void) makeOffsets;
-(void) drawView;
-(void) initMeshes;
-(void) reshape;
-(void) initGL;
-(void) initLighting;
-(void) timeStep;
-(void) reinitializeGL;
@end

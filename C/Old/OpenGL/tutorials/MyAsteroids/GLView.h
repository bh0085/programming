//
//  GLView.h
//  MyAsteroids
//
//  Created by Benjamin Holmes on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

struct object
{
	int fx, fy;   // Fine movement position
};

@interface GLView : NSOpenGLView
{
	int colorBits, depthBits;
	BOOL gameover;              // Is the game over?
	BOOL anti;                  // Antialiasing
	struct object player;       // Player information
	struct object enemy[ 9 ];   // Enemy information

}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits;
- (void) reshape;
- (void) drawRect:(NSRect)rect;
- (void) toggleAntialiasing;
- (void) updateGame;
- (void) movePlayerRight;
- (void) movePlayerLeft;
- (void) movePlayerDown;
- (void) movePlayerUp;

@end
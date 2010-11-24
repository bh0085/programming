//
//  GLIWindow.m
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#include "GLIWindow.h"
//#include "GLIDL.h"

@implementation GLIWindow


-(bool) getVisible{
	return isVisible;
}
-(id) init{
	size[0] = 400;
	size[1] = 400;
	pos[0] = 100;
	pos[1] = 100;
	isVisible = false;
	return self;
}
-(void)		setViewRangeToDefault{
	rangeParams[0]=0;
	rangeParams[1]=1;
	rangeParams[2]=0;
	rangeParams[3]=1;
	rangeParams[4]=-100;
	rangeParams[5]=100;	
	GLIViewBounds(rangeParams);
	
}
-(void) setPos:(int [2])p{
	pos[0] = p[0];
	pos[1] = p[1];
};
-(void) setSize:(int [2])s{
	size[0] = s[0];
	size[1] = s[1];
};

-(void) displayNow{
	self = [self initWithContentRect:NSMakeRect(pos[0],pos[1],size[0],size[1]) 
						   styleMask:NSTitledWindowMask | NSClosableWindowMask |NSResizableWindowMask
							 backing:NSBackingStoreBuffered 
							   defer:NO];
	view = [GLIView alloc];
	[view initNowWithFrame:[self frame]];	
	[self setViewRangeToDefault];
	[self setContentView:view];	
	
	[ [ view openGLContext ] makeCurrentContext ];	
	[self makeKeyAndOrderFront:nil];
	isVisible = true;
}
-(void) setCurrent{
	[ [ view openGLContext ] makeCurrentContext ];		
	glClearColor(.2,.2,.2,0);
	//clears to black and tells the depth buffer to stay out of it.
	glClearDepth(1);
	//glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);
	glDepthMask(GL_TRUE);
	glDepthFunc(GL_ALWAYS);
	
	glDisable(GL_LINE_SMOOTH);
	glEnable (GL_LINE_SMOOTH);	
	
	glDisable(GL_MULTISAMPLE);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glHint (GL_LINE_SMOOTH_HINT, GL_NICEST);
};



-(void)		dealloc{
	[view release];
	[super dealloc];
}


@end

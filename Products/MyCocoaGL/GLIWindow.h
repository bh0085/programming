/*
 *  GLIWindow.h
 *  Box2DAsteroids
 *
 *  Created by Benjamin Holmes on 8/7/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef GLIWINDOW_H
#define GLIWINDOW_H
#include "GLIView.h"
#ifndef	__cplusplus
#import "FreetypeManager.h"
#import "GLFT.h"

@interface GLIWindow : NSWindow {
	GLIView * view;
	NSWindow * glWindow;
	float rangeParams[6];
	bool isVisible;
	int pos[2];
	int size[2];

}
-(void) setCurrent;
-(bool) getVisible;
-(void) setPos:(int [2])p;
-(void) setSize:(int [2])s;
-(id) init;
-(void) displayNow;
-(void) dealloc;
-(void)	setViewRangeToDefault;
@end


#endif
#endif
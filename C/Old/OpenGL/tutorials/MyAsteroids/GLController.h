//
//  GLController.h
//  MyAsteroids
//
//  Created by Benjamin Holmes on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLView.h"


@interface GLController : NSResponder
{
	IBOutlet NSWindow *glWindow;
	
	NSTimer *renderTimer;
	GLView *glView;
}

- (void) awakeFromNib;
- (void) keyDown:(NSEvent *)theEvent;
- (void) dealloc;

@end


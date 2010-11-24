//
//  glController.h
//  FullscreenTest
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "glView.h"


@interface glController : NSResponder {
	NSWindow * glWindow;
	glView * myView;
	NSTimer * renderTimer;
}
-(void) applicationWillFinishLaunching:(NSNotification *)not;
-(void) applicationDidFinishLaunching:(NSNotification *)not;
-(void) applicationWillTerminate:(NSNotification *)not;
-(void) dealloc;	
-(void) createWindow;
-(void) keyDown:(NSEvent *)theEvent;


@end

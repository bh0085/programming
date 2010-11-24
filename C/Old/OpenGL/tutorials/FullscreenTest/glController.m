//
//  glController.m
//  FullscreenTest
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "glController.h"

@interface glController (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
@end

@implementation glController


-(void) createWindow{
	renderTimer = nil;
	glWindow = [[NSWindow alloc] 
					initWithContentRect:NSMakeRect(100,100,400,400) 
					styleMask:NSTitledWindowMask 
					backing:NSBackingStoreBuffered 
				defer:NO];
	myView = [glView alloc];
	
	[myView initNowWithFrame:[glWindow frame]];
	[glWindow setContentView:myView];
	[ glWindow makeFirstResponder:self ];
	[self setupRenderTimer];


	
}

- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	[self createWindow];	
}
- (void) applicationDidFinishLaunching: (NSNotification *)not
{
	[glWindow makeKeyAndOrderFront: nil];
	[myView drawView];//run the necessary opengl setup routines...

}

/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
	unichar unicodeKey;
	
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	printf("Running: %c ",unicodeKey);
	ushort keyCode = [theEvent keyCode];
	printf("KeyCode %i",(int)keyCode);
	if( [theEvent modifierFlags] & NSCommandKeyMask ){
		printf("Pressed \n");
	} else printf("\n");
	
	switch( unicodeKey )
	{
		case 'f':
			[myView toggleFullScreen];
			break;
	}
	switch( keyCode )
	{
			
	}
}

/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 0.1;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
	[myView timeStep];
	[myView drawView ];
}  


-(void) applicationWillTerminate:(NSNotification *)not{
	[self release];
}

-(void) dealloc{
	[myView release];
	[glWindow release];
	[super dealloc];
	[renderTimer release];
	CGReleaseAllDisplays();
}

@end

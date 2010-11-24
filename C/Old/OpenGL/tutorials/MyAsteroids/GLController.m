//
//  GLController.m
//  MyAsteroids
//
//  Created by Benjamin Holmes on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLController.h"

@interface GLController (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end


@implementation GLController

- (void) awakeFromNib
{  
	[ NSApp setDelegate:self ];   // We want delegate notifications
	renderTimer = nil;
	[ glWindow makeFirstResponder:self ];
	glView = [ [ GLView alloc ] initWithFrame:[ glWindow frame ]
										  colorBits:16 depthBits:16 ];
	
	if( glView != nil )
	{
		printf("settingContent");
		[ glWindow setContentView:glView ];
		[ glWindow makeKeyAndOrderFront:self ];
		[ self setupRenderTimer ];
	}
	else
		[ self createFailed ];
}  

/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 0.02;
	
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
	if( glView != nil )
	{
		[ glView drawRect:[ glView frame ] ];
		[ glView updateGame ];
	}
}  


/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
	NSWindow *infoWindow;
	
	infoWindow = NSGetCriticalAlertPanel( @"Initialization failed",
                                         @"Failed to initialize OpenGL",
                                         @"OK", nil, nil );
	[ NSApp runModalForWindow:infoWindow ];
	[ infoWindow close ];
	[ NSApp terminate:self ];
}


/* 
 * Cleanup
 */
- (void) dealloc
{
	[ glWindow release ]; 
	[ glView release ];
	if( renderTimer != nil && [ renderTimer isValid ] )
		[ renderTimer invalidate ];
	[super dealloc];
}



@end

//
//  CustomView1Controller.m
//  MinGLApple
//
//  Created by Benjamin Holmes on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomView1Controller.h"

@interface CustomView1Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end


@implementation CustomView1Controller
/*
- (void) awakeFromNib
{  
	printf("running");
	
	[ NSApp setDelegate:self ];   // We want delegate notifications
	renderTimer = nil;
	[  makeFirstResponder:self ];
	glView = [ [ Lesson01View alloc ] initWithFrame:[ glWindow frame ]
										  colorBits:16 depthBits:16 fullscreen:FALSE ];

		[ glWindow setContentView:glView ];
		[ glWindow makeKeyAndOrderFront:self ];
		[ self setupRenderTimer ];
}   */

- (void) awakeFromNib
{  	

	[self setupRenderTimer];
}


/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 0.005;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateCustomView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateCustomView:(NSTimer *)timer
{
	if( customView != nil )
		[ customView drawRect:[ customWindow frame ] ];
}  

- (void) dealloc
{
	[ customWindow release ]; 
	[ customView release ];
	[super dealloc];
}



@end

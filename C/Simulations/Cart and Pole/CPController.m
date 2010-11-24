//
//  AsteroidsGameController.m
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CPController.h"
@interface CPController (InternalMethods)
-(void) setupRenderTimer;	
@end
@implementation CPController

-(void) applicationDidFinishLaunching:(NSNotification *)not{
	simulation = CPMakeSimulation();
	
	[self setupRenderTimer];
}

- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = (float)1/30;
	
	renderTimer =[ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													 target:self
												   selector:@selector( simulationTimeStep: )
					//CHANGED REPEATS FROM YES TO NO TO HALT SIMULATION...
												   userInfo:nil repeats:YES ] retain];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
	[self release];
}
- (void) simulationTimeStep:(NSTimer *)timer
{
	CPStep(simulation);	
}  


-(void)		dealloc{
	CPDestroySimulation(simulation);
	[super dealloc];
}
- (void)	keyDown:(NSEvent *)theEvent{
	unichar unicodeKey;
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	ushort keyCode = [theEvent keyCode];
	
	switch( unicodeKey )
	{
		case 'i':
			break;
	}
	switch(keyCode)
	{
		default:
			break;
			
	}
	
}


@end

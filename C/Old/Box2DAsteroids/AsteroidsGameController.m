//
//  AsteroidsGameController.m
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AsteroidsGameController.h"
@interface AsteroidsGameController (InternalMethods)
	-(void) setupRenderTimer;	

@end
@implementation AsteroidsGameController


-(void) applicationDidFinishLaunching:(NSNotification *)not{
	game = makeGame(self);	
	[self setupRenderTimer];
}

- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = (float)1/30;
	
	renderTimer =[ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( gameTimeStep: )
												   //CHANGED REPEATS FROM YES TO NO TO HALT SIMULATION...
												   userInfo:nil repeats:YES ] retain];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
	[self release];
}
- (void) gameTimeStep:(NSTimer *)timer
{
	gameTimeStep(game);	
}  


-(void)		dealloc{
	destroyGame(game);
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
	//printf("%i",keyCode);
	switch(keyCode)
	{
		//left button
		case 123:
			asteroidsCommandLeft(game,5.0f);
			break;
		//right
		case 124:
			asteroidsCommandRight(game,5.0f);
			break;
		//down
		case 125:
			asteroidsCommandDown(game,5.0f);
			break;
		//up
		case 126:
			asteroidsCommandUp(game,50.0f);
			break;
	
			
	}
	
}


@end

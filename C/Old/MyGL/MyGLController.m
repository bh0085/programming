#import "MyGLController.h"
#import "GLViewCube.h"
#import "MyGLView.h"
#import "AsteroidView.h"

@interface MyGLController (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
@end

@implementation MyGLController


-(void) createWindow{
	renderTimer = nil;
	glWindow = [[NSWindow alloc] 
				initWithContentRect:NSMakeRect(100,100,400,400) 
				styleMask:NSTitledWindowMask 
				backing:NSBackingStoreBuffered 
				defer:NO];
	myView = [AsteroidView alloc];
	
	[myView initNowWithFrame:[glWindow frame]];
	[glWindow setContentView:myView];
	[glWindow makeFirstResponder:self ];
	[self setupRenderTimer];
	
	
	
}

//Window creation routines.
- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	[self createWindow];	
}
- (void) applicationDidFinishLaunching: (NSNotification *)not
{
	[glWindow makeKeyAndOrderFront: nil];	
}

//Handles key pressed... fullscreen.
- (void) keyDown:(NSEvent *)theEvent
{
	unichar unicodeKey;
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	ushort keyCode = [theEvent keyCode];

	switch( unicodeKey )
	{
		case 'f':
			[myView toggleFullScreen];
			break;
	}
}
//Calls Update GLView at time Intervals
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = (float)1/30;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}
//increments myview's timestep and then run's myview's drawview.
- (void) updateGLView:(NSTimer *)timer
{
	//printf("%p \n",[NSOpenGLContext currentContext]);

	[myView timeStep];
	//printf("%p tween \n",[NSOpenGLContext currentContext]);

	[myView drawView ];
	//printf("%p \n",[NSOpenGLContext currentContext]);

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

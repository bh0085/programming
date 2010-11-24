/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* Lesson02Controller.m */

#import "Lesson02Controller.h"

@interface Lesson02Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

@implementation Lesson02Controller

NSView * mainView;
Lesson02View * glView;
NSWindow * myWindow;

- (void) createWindow
{
	unsigned int styleMask = NSTitledWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
	NSRect rect = NSMakeRect (100, 100, 600,400);
	myWindow = [NSWindow alloc];
	myWindow = [myWindow initWithContentRect: rect
								   styleMask: styleMask
									 backing: NSBackingStoreBuffered
									   defer: NO];	
	mainView = [[NSView alloc] initWithFrame: [myWindow frame]];
	[myWindow setContentView:mainView];
	[myWindow makeFirstResponder:self];
	glView = [ [ Lesson02View alloc ] initWithFrame:[ mainView frame ]
										  colorBits:16 depthBits:16 fullscreen:FALSE ];	
	[mainView addSubview:glView];
}

- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	[self createWindow];	
}
- (void) applicationDidFinishLaunching: (NSNotification *)not
{
	[myWindow makeKeyAndOrderFront: nil];
	[glView drawScene];
	[glView drawRect:[glView frame]];
	//[ self setupRenderTimer ];
	sleep(1);
	[self setFullScreen:self];
	sleep(1);
	[self setFullScreen:self];
	
	
}


/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
   NSTimeInterval timeInterval = 0.005;

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
	   [glView drawScene];
      [ glView drawRect:[ glView frame ] ];
}  


/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
   unichar unicodeKey;

   unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
   switch( unicodeKey )
   {
      // Handle key presses here
   }
}


/*
 * Set full screen.
 */
- (IBAction)setFullScreen:(id)sender
{
	printf("fulling");
	[glView removeFromSuperview];
   if( [ glView isFullScreen ] )
   {
	   printf("unsetting");
	   if( ![ glView setFullScreen:FALSE inFrame:[ myWindow frame ] ] ){
		   printf("failing Return");
		   [ self createFailed ];
	   }
      else
         [ mainView addSubview:glView ];
   }
   else
   {
	   printf("setting");
	   if( ![ glView setFullScreen:TRUE inFrame:NSMakeRect( 0, 0, 800, 600 ) ] ){
		   printf("failing Set");
         [ self createFailed ];
	   }
   }
}


/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
   NSWindow *infoWindow;

   infoWindow = NSGetCriticalAlertPanel( @"Initialization failed!!!!!!!",
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

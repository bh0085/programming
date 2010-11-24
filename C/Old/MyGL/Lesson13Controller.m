/*
 * Original Windows comment:
 * "This Code Was Created By Jeff Molofee 2000
 * Modified by Shawn T. to handle (%3.2f, num) parameters.
 * A HUGE Thanks To Fredric Echols For Cleaning Up
 * And Optimizing The Base Code, Making It More Flexible!
 * If You've Found This Code Useful, Please Let Me Know.
 * Visit My Site At nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* Lesson13Controller.m */

#import "Lesson13Controller.h"

@interface Lesson13Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

@implementation Lesson13Controller

- (void) awakeFromNib
{ 
   [ NSApp setDelegate:self ];   // We want delegate notifications
   renderTimer = nil;
   [ glWindow makeFirstResponder:self ];
   glView = [ [ Lesson13View alloc ] initWithFrame:[ glWindow frame ]
              colorBits:16 depthBits:16 fullscreen:FALSE ];
   if( glView != nil )
   {
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
   }
}  


/*
 * Set full screen.
 */
- (IBAction)setFullScreen:(id)sender
{ 
   [ glWindow setContentView:nil ];
   if( [ glView isFullScreen ] ) 
   {
      if( ![ glView setFullScreen:FALSE inFrame:[ glWindow frame ] ] )
         [ self createFailed ];
      else 
         [ glWindow setContentView:glView ];
   }
   else
   {
      if( ![ glView setFullScreen:TRUE
                    inFrame:NSMakeRect( 0, 0, 800, 600 ) ] )
         [ self createFailed ];
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
}

@end

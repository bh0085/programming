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

/* Lesson02View.m */

#import "Lesson02View.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

@interface Lesson02View (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (void) switchToOriginalDisplayMode;
- (BOOL) initGL;
@end

@implementation Lesson02View

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
       depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen
{
   NSOpenGLPixelFormat *pixelFormat;

   colorBits = numColorBits;
   depthBits = numDepthBits;
   runningFullScreen = runFullScreen;
   originalDisplayMode = (NSDictionary *) CGDisplayCurrentMode(
                                             kCGDirectMainDisplay );
   pixelFormat = [ self createPixelFormat:frame ];
   if( pixelFormat != nil )
   {
      self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
      [ pixelFormat release ];
      if( self )
      {
         [ [ self openGLContext ] makeCurrentContext ];
         if( runningFullScreen )
            [ [ self openGLContext ] setFullScreen ];
         [ self reshape ];
         if( ![ self initGL ] )
         {
            [ self clearGLContext ];
            self = nil;
         }
      }
   }
   else
      self = nil;

   return self;
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
   NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
   int pixNum = 0;
   NSDictionary *fullScreenMode;
	NSOpenGLPixelFormat *pixelFormat;

	if(!runningFullScreen){
	

   pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = 16;//colorBits;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = 16;//depthBits;
		pixelAttribs[ pixNum ] = 0;
		pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
					   initWithAttributes:pixelAttribs ];

	}
   if( runningFullScreen )  // Do this before getting the pixel format
   {
	   NSOpenGLPixelFormatAttribute FSpixelAttribs[] = { // 1
		   
		   NSOpenGLPFAFullScreen,
		   
		   NSOpenGLPFAScreenMask,
		   
		   CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
		   
		   NSOpenGLPFAColorSize, 24,  // 2
		   
		   NSOpenGLPFADepthSize, 16,
		   
		   NSOpenGLPFADoubleBuffer,
		   
		   NSOpenGLPFAAccelerated,
		   
		   0
		   
	   };
	   
      fullScreenMode = (NSDictionary *) CGDisplayBestModeForParameters(
                                           kCGDirectMainDisplay,
                                           colorBits, frame.size.width,
                                           frame.size.height, NULL );
      CGDisplayCapture( kCGDirectMainDisplay );
      CGDisplayHideCursor( kCGDirectMainDisplay );
      CGDisplaySwitchToMode( kCGDirectMainDisplay,
                             (CFDictionaryRef) fullScreenMode ); 
	   pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
					  initWithAttributes:FSpixelAttribs ];

   }


	printf("%s", (pixelFormat == nil)? "nilPixelformat" : "nonNil");
	
   return pixelFormat;
}


/*
 * Enable/disable full screen mode
 */
- (BOOL) setFullScreen:(BOOL)enableFS inFrame:(NSRect)frame
{
   BOOL success = FALSE;
   NSOpenGLPixelFormat *pixelFormat;
   NSOpenGLContext *newContext;

   [ [ self openGLContext ] clearDrawable ];
   if( runningFullScreen )
      [ self switchToOriginalDisplayMode ];
   runningFullScreen = enableFS;
	printf("atpixel");
	pixelFormat = [self createPixelFormat:frame];
	
	if( pixelFormat != nil )
   {
	   printf("pixelgood");
      newContext = [ [ NSOpenGLContext alloc ] initWithFormat:pixelFormat
                     shareContext:nil ];
      if( newContext != nil )
      {
		  printf("contextgood");
         [ super setFrame:frame ];
         [ super setOpenGLContext:newContext ];
		  printf("atSetContext");
		  
         [ newContext makeCurrentContext ];
		  printf("atSetContext");

         if( runningFullScreen )
            //[ newContext setFullScreen ];
		  printf("atreshape");
         [ self reshape ];
         if( [ self initGL ] )
			 printf("initgood");
            success = TRUE;
      }
      [ pixelFormat release ];
   }
   if( !success && runningFullScreen )
      [ self switchToOriginalDisplayMode ];

   return success;
}


/*
 * Switch to the display mode in which we originally began
 */
- (void) switchToOriginalDisplayMode
{
   CGDisplaySwitchToMode( kCGDirectMainDisplay,
                          (CFDictionaryRef) originalDisplayMode );
   CGDisplayShowCursor( kCGDirectMainDisplay );
   CGDisplayRelease( kCGDirectMainDisplay );
}


/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{ 
   glShadeModel( GL_SMOOTH );                // Enable smooth shading
   glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
   glClearDepth( 1.0f );                     // Depth buffer setup
   glEnable( GL_DEPTH_TEST );                // Enable depth testing
   glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
   // Really nice perspective calculations
   glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
   
   return TRUE;
}


/*
 * Resize ourself
 */
- (void) reshape
{ 
   NSRect sceneBounds;
   
   [ [ self openGLContext ] update ];
   sceneBounds = [ self bounds ];
   // Reset current viewport
   glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
   glMatrixMode( GL_PROJECTION );   // Select the projection matrix
   glLoadIdentity();                // and reset it
   // Calculate the aspect ratio of the view
   gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
                   0.1f, 100.0f );
   glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
   glLoadIdentity();                // and reset it
}


/*
 * Called when the system thinks we need to draw.
 */

- (void) drawScene{
	// Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glLoadIdentity();   // Reset the current modelview matrix
	
	glTranslatef( -1.5f, 0.0f, -6.0f );   // Left 1.5 units, into screen 6.0
	
	glBegin( GL_TRIANGLES );             // Draw a triangle
	glVertex3f(  0.0f,  1.0f, 0.0f );    // Top
	glVertex3f( -1.0f, -1.0f, 0.0f );    // Bottom left
	glVertex3f(  1.0f, -1.0f, 0.0f );    // Bottom right
	glEnd();                             // Done with the triangle
	
	glTranslatef( 3.0f, 0.0f, 0.0f );    // Move right 3 units
	
	glBegin( GL_QUADS );                // Draw a quad
	glVertex3f( -1.0f,  1.0f, 0.0f );   // Top left
	glVertex3f(  1.0f,  1.0f, 0.0f );   // Top right
	glVertex3f(  1.0f, -1.0f, 0.0f );   // Bottom right
	glVertex3f( -1.0f, -1.0f, 0.0f );   // Bottom left
	glEnd();      	
}

- (void) drawRect:(NSRect)rect
{
                      // Quad is complete

   [ [ self openGLContext ] flushBuffer ];
}


/*
 * Are we full screen?
 */
- (BOOL) isFullScreen
{
   return runningFullScreen;
}


/*
 * Cleanup
 */
- (void) dealloc
{
   if( runningFullScreen )
      [ self switchToOriginalDisplayMode ];
   [ originalDisplayMode release ];
	[super dealloc];
}

@end

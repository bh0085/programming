//
//  glView.m
//  FullscreenTest
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "glView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

@interface glView (InternalMethods)
-(void) initGL;
-(void) switchToOriginalDisplayMode;
@end


@implementation glView

// Ambient light values
static GLfloat lightAmbient[] = { .1f, .0f, .0f, 1.0f };
// Diffuse light values
static GLfloat lightDiffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
// Light position
static GLfloat lightPosition[] = { 0.0f, 0.0f, 2.0f, 1.0f };
float yRot = 0;

-(void) initNowWithFrame:(NSRect)frame{
	originalDisplayMode = (NSDictionary *) CGDisplayCurrentMode(kCGDirectMainDisplay );
	runningFullScreen = FALSE;
	[self makeWithFrame:frame];
	[self initGL];

	
}

-(BOOL) isFullScreen {
	return runningFullScreen;
}
-(void) makeWithFrame:(NSRect)frame{
	NSOpenGLPixelFormat * pixelFormat = [self createWindowedPixelFormat];
	self = [ super initWithFrame:[[self superview]frame] pixelFormat:pixelFormat ];
	[pixelFormat release];
	[ [ self openGLContext ] makeCurrentContext ];	
	[self initGL];
	[self reshape];
}

-(void) toggleFullScreen{
	if(runningFullScreen) [self unMakeFullScreen]; else [self makeFullScreen];
}

-(void) reshape
{
	//NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	//sceneBounds = [ self bounds ];
	// Reset current viewport
	//glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
//	gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
//                   0.1f, 100.0f );
	glOrtho(-5, 5, -5, 5, -4, 4);
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it	
}

-(void) makeFullScreen{
	runningFullScreen = TRUE;
	NSRect res = NSMakeRect(0, 0, 1440, 900);
	NSOpenGLContext *fullScreenContext;
	NSOpenGLPixelFormat *pixelFormat = [self createFullScreenPixelFormat];
	fullScreenContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat						 
												   shareContext:NULL];	
	[pixelFormat release];
	CFDictionaryRef displayMode ;
	CGDisplayCapture (kCGDirectMainDisplay); // 1
	boolean_t exactMatch ;
	displayMode = CGDisplayBestModeForParametersAndRefreshRate (kCGDirectMainDisplay,												  
																32,res.size.width,res.size.height,60,&exactMatch); // 2 (Null is for exactmatch boolean parameter)
	CGDisplaySwitchToMode (kCGDirectMainDisplay, displayMode);	
	[fullScreenContext setFullScreen]; // 4
	[fullScreenContext makeCurrentContext]; 	
}

-(void) unMakeFullScreen{
	runningFullScreen = FALSE;
	[self switchToOriginalDisplayMode];
	[[NSOpenGLContext currentContext] release];
	[[self openGLContext] makeCurrentContext];
	[self reshape];
}

-(void) initGL{
	
	glEnable( GL_TEXTURE_2D );                // Enable texture mapping
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	// Setup ambient light
	glLightfv( GL_LIGHT1, GL_AMBIENT, lightAmbient );
	// Setup diffuse light
	glLightfv( GL_LIGHT1, GL_DIFFUSE, lightDiffuse );
	// Position the light
	glLightfv( GL_LIGHT1, GL_POSITION, lightPosition );
	
	glColor4f( 1.0f, 1.0f, 1.0f, 0.5f );   // Full brightness, 50% alpha
	// Blending function for translucency based on source alpha value
	glBlendFunc( GL_SRC_ALPHA, GL_ONE );
	
}

-(NSOpenGLPixelFormat *) createWindowedPixelFormat{
	NSOpenGLPixelFormatAttribute pixelAttribs[16];
	int pixNum = 0;
	NSOpenGLPixelFormat * pixelFormat;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = 16;//colorBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = 16;//depthBits;
	pixelAttribs[ pixNum ] = 0;
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
				   initWithAttributes:pixelAttribs ];
	return pixelFormat;	
}
-(NSOpenGLPixelFormat *) createFullScreenPixelFormat{
	NSOpenGLPixelFormatAttribute attrs[] = { // 1		
		NSOpenGLPFAFullScreen,		
		NSOpenGLPFAScreenMask,		
		CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),		
		NSOpenGLPFAColorSize, 24,  // 2		
		NSOpenGLPFADepthSize, 16,		
		NSOpenGLPFADoubleBuffer,		
		NSOpenGLPFAAccelerated,		
		0		
	};
	
	NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc]										
										initWithAttributes:attrs];	
	return pixelFormat;
}

-(void) timeStep{
	yRot++;
	
}
-(void) drawView{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	glLoadIdentity();   // Reset the current modelview matrix
	glRotated(yRot, 1, 0, 0);
	glTranslated(0, 0, 5);
	glEnable( GL_LIGHT1 );   // Enable light 1
	
	glLoadIdentity();
	glRotated(yRot, 0,1,0);
	glRotated(40, .5, .5, 1);
	glEnable(GL_LIGHTING);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glBegin( GL_QUADS ); 
	// Front Face
	glNormal3f( 0.0f, 0.0f, 1.0f );      // Normal Pointing Towards Viewer
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 1 (Front) 
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 2 (Front)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Front)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 4 (Front)
	// Back Face
	glNormal3f( 0.0f, 0.0f, -1.0f );     // Normal Pointing Away From Viewer
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Back)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 2 (Back)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 3 (Back)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 4 (Back)
	// Top Face
	glNormal3f( 0.0f, 1.0f, 0.0f );      // Normal Pointing Up
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 1 (Top)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 2 (Top)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Top)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 4 (Top)
	// Bottom Face
	glNormal3f( 0.0f, -1.0f, 0.0f );     // Normal Pointing Down
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Bottom)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 2 (Bottom)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 3 (Bottom)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 4 (Bottom)
	// Right face
	glNormal3f( 1.0f, 0.0f, 0.0f);       // Normal Pointing Right
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 1 (Right)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 2 (Right)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Right)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 4 (Right)
	// Left Face
	glNormal3f( -1.0f, 0.0f, 0.0f );     // Normal Pointing Left
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Left)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 2 (Left)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 3 (Left)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 4 (Left)
	glEnd();                             // Done Drawing Quads
	
	[[NSOpenGLContext currentContext] flushBuffer];
}

-(void) dealloc{
	if( [self isFullScreen] )
		[ self switchToOriginalDisplayMode ];
	[super dealloc];
	[originalDisplayMode release];
}

- (void) switchToOriginalDisplayMode
{
	CGDisplaySwitchToMode( kCGDirectMainDisplay,(CFDictionaryRef) originalDisplayMode );
	CGDisplayShowCursor( kCGDirectMainDisplay );
	CGDisplayRelease( kCGDirectMainDisplay );
}



@end


#import "MyGLView.h"


@interface MyGLView (InternalMethods)
-(void) switchToOriginalDisplayMode;
@end


@implementation MyGLView


-(void) initNowWithFrame:(NSRect)frame{
	yRot=0.0;
	originalDisplayMode = (NSDictionary *) CGDisplayCurrentMode(kCGDirectMainDisplay );
	runningFullScreen = FALSE;
	[self makeWithFrame:frame];
	[self initGL];
	
	
}

-(BOOL) isFullScreen {
	return runningFullScreen;
}
-(void) makeWithFrame:(NSRect)frame{
	NSOpenGLPixelFormat * pixelFormat = [self createMultisamplePixelFormat];
	self = [ super initWithFrame:[[self superview]frame] pixelFormat:pixelFormat ];
	[pixelFormat release];
	[ [ self openGLContext ] makeCurrentContext ];	
	[self reshape];
}

-(void) toggleFullScreen{
	if(runningFullScreen) [self unMakeFullScreen]; else [self makeFullScreen];
}

-(void) reshape
{
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height);
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	/*gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
                   -50.0f, 100.0f );	*/
	glOrtho(-5,5,-5,5,-10,10);
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}


//FULLSCREEN MODE IS BROKEN... THE CONTEXT REVERTS IMMEDIATELY OR THE DRAWFUNCTION IS NOT BEING CALLED
-(void) makeFullScreen{
	runningFullScreen = TRUE;
	NSRect res = NSMakeRect(0, 0,640, 480);
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
	//printf("%p \n",fullScreenContext);
	[fullScreenContext makeCurrentContext]; 
	//printf("%p \n",[NSOpenGLContext currentContext]);
	
	//[self reshape];
	//[self reinitializeGL];
}
-(void) reinitializeGL{
	
}
-(void) unMakeFullScreen{
	runningFullScreen = FALSE;
	//printf("%p \n",[NSOpenGLContext currentContext]);

	[self switchToOriginalDisplayMode];
	//printf("%p \n",[NSOpenGLContext currentContext]);
	
	//[[NSOpenGLContext currentContext] release];
	[[self openGLContext] makeCurrentContext];
	[self reshape];
}

-(void) initGL{

}

-(NSOpenGLPixelFormat *) createMultisamplePixelFormat{
	NSOpenGLPixelFormat * pixelFormat;
	
	NSOpenGLPixelFormatAttribute pixelAttribs[] = { // 1		
		
		NSOpenGLPFAColorSize, 8,  // 2		
		NSOpenGLPFADepthSize, 8,		
		NSOpenGLPFADoubleBuffer,		
		NSOpenGLPFAAccelerated,	
		NSOpenGLPFASampleBuffers, 1,
		NSOpenGLPFASamples, 3,
		NSOpenGLPFANoRecovery,		
		0		
	};	
	
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
	
}
-(void) drawView{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
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

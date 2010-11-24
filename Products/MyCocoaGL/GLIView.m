
#import "GLIView.h"

@interface GLIView (InternalMethods)
-(void) makeWithFrame:(NSRect)frame;
-(void) initGL;
-(NSOpenGLPixelFormat *) createMultisamplePixelFormat;

@end
@implementation GLIView


-(void) initNowWithFrame:(NSRect)frame{
	[self makeWithFrame:frame];
	[self initGL];

}

-(void) makeWithFrame:(NSRect)frame{
	NSOpenGLPixelFormat * pixelFormat = [self createMultisamplePixelFormat];
	self = [ super initWithFrame:[[self superview]frame] pixelFormat:pixelFormat ];
	[pixelFormat release];
	[ [ self openGLContext ] makeCurrentContext ];	
	[self reshape];
}

-(void) initGL{
	
}

-(NSOpenGLPixelFormat *) createMultisamplePixelFormat{
	NSOpenGLPixelFormat * pixelFormat;
	
	NSOpenGLPixelFormatAttribute pixelAttribs[] = { // 1		

	
/*		NSOpenGLPFAColorSize, 8,  // 2		
		NSOpenGLPFADepthSize, 8,	
 */
		NSOpenGLPFADoubleBuffer,		
		NSOpenGLPFAAccelerated,	
		NSOpenGLPFASampleBuffers, 1,
		NSOpenGLPFASamples, 8,
		NSOpenGLPFANoRecovery,	
		NSOpenGLPFAMultisample,
		0		
	};	
	
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
				   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;	
}


@end


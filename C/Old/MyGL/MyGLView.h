#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

@interface MyGLView : NSOpenGLView {
	BOOL runningFullScreen;
	NSDictionary *originalDisplayMode;
	NSOpenGLContext * originalContext;
	float yRot;
}

-(void) initNowWithFrame:(NSRect)frame;
-(NSOpenGLPixelFormat *) createFullScreenPixelFormat;
-(NSOpenGLPixelFormat *) createMultisamplePixelFormat;

-(void) drawView;
-(BOOL) isFullScreen;
-(void) makeWithFrame:(NSRect)frame;
-(void) makeFullScreen;
-(void) unMakeFullScreen;
-(void) toggleFullScreen;
-(void) reshape;
-(void) timeStep;
-(void) initGL;
-(void) reinitializeGL;

@end

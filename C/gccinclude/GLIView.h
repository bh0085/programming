//GLInterfaceView
#ifndef __cplusplus

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>


@interface GLIView : NSOpenGLView 
{

}

-(NSOpenGLPixelFormat *) createMultisamplePixelFormat;
-(void) initNowWithFrame:(NSRect)frame;
@end
#endif



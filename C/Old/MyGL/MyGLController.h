#import <Cocoa/Cocoa.h>
#import "MyGLView.h"


@interface MyGLController : NSResponder {
	NSWindow * glWindow;
	MyGLView * myView;
	NSTimer * renderTimer;
}
-(void) applicationWillFinishLaunching:(NSNotification *)not;
-(void) applicationDidFinishLaunching:(NSNotification *)not;
-(void) applicationWillTerminate:(NSNotification *)not;
-(void) dealloc;	
-(void) createWindow;
-(void) keyDown:(NSEvent *)theEvent;


@end

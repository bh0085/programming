#import "NN3GLController.h"

@interface NN3GLController (InternalMethods)
- (void) updateGLView;
@end

@implementation NN3GLController

-(void) createWindow{
	yRange = 5.0;
	rangeParams[0]=-.2;
	rangeParams[1]=.2;
	rangeParams[2]=-yRange;
	rangeParams[3]=yRange;
	rangeParams[4]=-100;
	rangeParams[5]=100;
	glWindow = [[NSWindow alloc] 
				initWithContentRect:NSMakeRect(100,100,400,400) 
				styleMask:NSTitledWindowMask | NSResizableWindowMask
				backing:NSBackingStoreBuffered 
				defer:NO];
	myView = [NN3GLView alloc];
	[myView initNowWithFrame:[glWindow frame]];
	[myView setRange:rangeParams];
	[glWindow setContentView:myView];
	[glWindow makeFirstResponder:self ];	
	
}

//Window creation routines.
- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	[self createWindow];	
}
- (void) applicationDidFinishLaunching: (NSNotification *)not
{
	[glWindow makeKeyAndOrderFront: nil];
	[self updateGLView];
}

-(void) expandYRange{
	rangeParams[2] *=1.2;
	rangeParams[3] *=1.2;
	[myView setRange:rangeParams];
}

-(void) decreaseYRange{
	rangeParams[2] /=1.2;
	rangeParams[3] /=1.2;
	[myView setRange:rangeParams];
}

//Handles key pressed... fullscreen.
- (void) keyDown:(NSEvent *)theEvent
{
	unichar unicodeKey;
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	//ushort keyCode = [theEvent keyCode];
	
	switch( unicodeKey )
	{
		case 'i':
			findIdentity();
			break;
		case ']':
			[self expandYRange];
			break;
		case '[':
			[self decreaseYRange];
			break;
	}
}

//increments myview's timestep and then run's myview's drawview.
- (void) updateGLView
{
	[myView drawView ];	
}  
-(void) applicationWillTerminate:(NSNotification *)not{
	[self release];
}

-(void) dealloc{
	[myView release];
	[glWindow release];
	//free(rangeParams);
	[super dealloc];
}

@end

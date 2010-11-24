#import <Cocoa/Cocoa.h>
#import "MyGLController.h"
NSAutoreleasePool * pool;
MyGLController * controller;

int main(int argc, char *argv[])
{

	srand ( (unsigned)time ( NULL ) );
	[[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	controller = [MyGLController new];
	[NSApp setDelegate: controller];	
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);
} 
 

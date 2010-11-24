/* main.m */

#import <Cocoa/Cocoa.h>
#import "Lesson02Controller.h"

NSAutoreleasePool * pool;
int main (int argc, const char **argv)
{ 
	pool = [[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	[NSApp setDelegate: [Lesson02Controller new]];
	[pool release];
	return NSApplicationMain (argc, argv);
}

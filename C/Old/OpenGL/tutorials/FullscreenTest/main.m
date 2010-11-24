//
//  main.m
//  FullscreenTest
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "glController.h"
NSAutoreleasePool * pool;
glController * controller;
int main(int argc, char *argv[])
{
	[[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	controller = [glController new];
	[NSApp setDelegate: controller];	
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);
}

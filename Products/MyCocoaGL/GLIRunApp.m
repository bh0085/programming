/*
 *  RunApp.c
 *  GLInterface
 *
 *  Created by Benjamin Holmes on 7/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#import <Cocoa/Cocoa.h>
#import "GLIController.h"

NSAutoreleasePool * pool;
GLIController * controller;

int GLIRun(int argc, char *argv[])
{
	srand ( (unsigned)time ( NULL ) );
	[[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	controller = [GLIController new];
	[NSApp setDelegate: controller];	
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);
} 

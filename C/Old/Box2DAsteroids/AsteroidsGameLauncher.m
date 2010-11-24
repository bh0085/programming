//
//  AsteroidsGameLauncher.m
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "AsteroidsGameLauncher.h"
#import "AsteroidsGameController.h"

NSAutoreleasePool * pool;
AsteroidsGameController * controller;

int launchAsteroidsGame(int argc, char *argv[])
{
	
 
	
	srand ( (unsigned)time ( NULL ) );
	[[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	controller = [AsteroidsGameController new];
	[NSApp setDelegate: controller];
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);
} 

//
//  main.m
//  TestApplication
//
//  Created by Benjamin Holmes on 6/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NN3GLController.h"

NSAutoreleasePool * pool;
NN3GLController * controller;

int main(int argc, char *argv[])
{
	
	srand ( (unsigned)time ( NULL ) );
	[[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	controller = [NN3GLController new];
	[NSApp setDelegate: controller];	
	[pool release];
    return NSApplicationMain(argc,  (const char **) argv);
} 


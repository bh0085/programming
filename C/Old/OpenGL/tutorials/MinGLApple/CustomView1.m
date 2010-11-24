//
//  customView1.m
//  MinGLApple
//
//  Created by Benjamin Holmes on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomView1.h"


@implementation CustomView1


- (void)drawRect:(NSRect)rect

{
	
    // erase the background by drawing white
	
	[[NSColor whiteColor] set];
	
   
	[NSBezierPath fillRect:rect];

	
    // draw the draggable item
	
    //[NSBezierPath fillRect:[self calculatedItemBounds]];
	
}

- (NSRect)calculatedItemBounds

{
	
    NSRect calculatedRect;
	
	
	
    // calculate the bounds of the draggable item
	
    // relative to the location
	
    calculatedRect.origin=NSMakePoint(0.0,0.0);
	
	
	
    // the example assumes that the width and height
	
    // are fixed values
	
    calculatedRect.size.width=60.0;
	
    calculatedRect.size.height=20.0;
	
	
	
    return calculatedRect;
	
}

@end

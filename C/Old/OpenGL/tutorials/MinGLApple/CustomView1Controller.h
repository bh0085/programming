//
//  CustomView1Controller.h
//  MinGLApple
//
//  Created by Benjamin Holmes on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomView1.h"

@interface CustomView1Controller : NSResponder 
{
	NSTimer *renderTimer;

		IBOutlet NSWindow *customWindow;
		CustomView1 *customView;
}
	

	- (void) awakeFromNib;
	- (void) dealloc;
	
@end
	

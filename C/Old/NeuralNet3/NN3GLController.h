//
//  NN3GLController.h
//  NeuralNet3
//
//  Created by Benjamin Holmes on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NN3GLView.h"
#import "NeuralNet.h"

@interface NN3GLController : NSResponder {
	NSWindow * glWindow;
	NN3GLView * myView;
	float yRange;
	float rangeParams[6];
}

-(void) expandYRange;
-(void) decreaseYRange;

@end

//
//  AsteroidsGameController.h
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLISim.h"
#import "GLIController.h"


@interface GLISimController: GLIController {
	GLISim * simulation;
}
-(id)initWithSimulation:(GLISim *)sim;
@end

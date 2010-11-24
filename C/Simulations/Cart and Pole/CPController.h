//
//  AsteroidsGameController.h
//  Box2DAsteroids
//
//  Created by Benjamin Holmes on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPSimulation.h"
#import "GLIController.h"


@interface CPController: GLIController {
	CPSimulation * simulation;
}

@end

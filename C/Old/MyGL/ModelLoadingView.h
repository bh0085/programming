//
//  ModelLoadingView.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyGLView.h"
#import "Geometry.h" 
#import "Asteroid.h"
#import "TriMesh.h"

@interface ModelLoadingView : MyGLView {

}
-(void) initGL;
-(void) makeModel;

//-(POLYGON *) readModel;
@end

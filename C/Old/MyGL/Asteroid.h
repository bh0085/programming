//
//  Asteroid.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Geometry.h"
#import "TriMesh.h"

@interface Asteroid : NSObject{
	TriMesh * myTriMesh;
	NSString * name;	
}
-(void) initWithMesh;
-(void) initWithRandomMesh;
-(int) nFaces;
-(POLYGON *) mesh;
-(void) setName:(NSString *)newName;
-(NSString *) name;
@end


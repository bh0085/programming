//
//  TriMesh.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Geometry.h"


@interface TriMesh : NSObject {
	float * verts;
	int * idxs;
	int nfaces;
	//the whole idea of the 3verts is to keep track of the number of three element vertices when they
	//are in fact store in verts as single floats.
	int n3verts;
	
	//subdivision variables...
	int * pairsDivided;
	POLYGON * currentMesh;
	float meshCreationScaleFactor;
		
}
-(void) setMeshCreationScaleFactor:(float)f;
-(void) initToIsocahedron;
-(void) subdivide;
-(void) dealloc;
-(int) nFaces;
-(void) createMesh;
-(void) createRandomMesh:(float)randomness;
-(POLYGON *) mesh;

@end

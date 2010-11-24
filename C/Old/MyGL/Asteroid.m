//
//  Asteroid.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Asteroid.h"


@implementation Asteroid 


-(void) setName:(NSString *)newName{
	name = newName;
	[name retain];
}
-(NSString *) name{
	return name;
}

-(void) initWithMesh{
	myTriMesh = [TriMesh alloc];
	[myTriMesh initToIsocahedron];
	[myTriMesh subdivide];
	[myTriMesh createMesh];
}
-(void) initWithRandomMesh{
	myTriMesh = [TriMesh alloc];
	[myTriMesh initToIsocahedron];
	[myTriMesh subdivide];
//	[myTriMesh subdivide];
	[myTriMesh setMeshCreationScaleFactor:20];
	[myTriMesh createRandomMesh:1];
}

-(POLYGON *) mesh{
	return [myTriMesh mesh];
}
-(int) nFaces{
	return [myTriMesh nFaces];
}

-(void) dealloc{
	[name release];
	[myTriMesh release];
	free(myTriMesh);
	[super dealloc];
}


@end


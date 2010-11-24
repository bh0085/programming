//
//  CellShadedModelView.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelLoadingView.h"
#import "Geometry.h"

@interface CellShadedModelView : ModelLoadingView {
	NSMutableArray * meshes;
	VECTOR * offsets;
	VECTOR lightAngle;
	GLuint shaderTexture[ 1 ];  
}
-(void) initGL;
-(void) initCellShading;
-(void) initMeshes;
-(void) drawView;
-(void) makeOffsets;

@end

//
//  Geometry.h
//  MyGL
//
//  Created by Benjamin Holmes on 6/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct tagMATRIX   // A Structure To Hold An OpenGL Matrix
	{
		float Data[ 16 ];       // We Use [16] Due To OpenGL's Matrix Format
	} MATRIX;

// This union is for dealing with endian issues in readMesh


typedef struct tagVECTOR   // A Structure To Hold A Single Vector
	{
		float X;     // The components of the vector
		float Y;
		float Z;
	} VECTOR;
typedef struct tagINTVECTOR   // A Structure To Hold A Single Vector
	{
		int X;     // The components of the vector
		int Y;
		int Z;
	} INTVECTOR;

typedef struct tagVERTEX   // A Structure To Hold A Single Vertex
	{
		VECTOR Nor;             // Vertex Normal
		VECTOR Pos;             // Vertex Position
	} VERTEX;

typedef struct tagPOLYGON   // A Structure To Hold A Single Polygon
	{
		VERTEX Verts[ 3 ];       // Array Of 3 VERTEX Structures
	} POLYGON;




@interface Geometry : NSObject {
}

	+(float) dotProductOf:(VECTOR *)V1 with:(VECTOR *)V2;
	+(float) magnitudeOf:(VECTOR *)V;
	+(void) normalize:(VECTOR *)V;
	+(void) crossProductOf:(VECTOR *)V1 with:(VECTOR *)V2 into:(VECTOR *)V3;
	+(void) subtractVector:(VECTOR *)V1 from:(VECTOR *)V2 into:(VECTOR *)V3;
	+(void) rotateVectorAroundY:(VECTOR *)V radians:(float)rad;
+(void) makePolygonNormalsUnitRadial:(POLYGON *)poly;
+(void) makePolygonNormalsUnitFace:(POLYGON *)poly;
+(void) putPolygonNormal:(POLYGON *)poly inVector:(VECTOR *)vec;
+(void) addVector:(VECTOR *)V1 andVector:(VECTOR *)V2 into:(VECTOR *)V3;
+(void) scaleVector:(VECTOR *)V byFactor:(float)factor;


@end

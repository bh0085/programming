//
//  Geometry.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Geometry.h"


@implementation Geometry

const float PI = 3.1415926;


/*
 *Calculate The Angle Between The 2 Vectors
 */
+(float) dotProductOf:(VECTOR *)V1 with:(VECTOR *)V2
{
	// Return The Angle
	return V1->X * V2->X + V1->Y * V2->Y + V1->Z * V2->Z;
}
+(void) crossProductOf:(VECTOR *)V1 with:(VECTOR *)V2 into:(VECTOR *)V3;
{
	// Return The Angle
	V3->Z = V1->X * V2->Y - V1->Y * V2->X ;
	V3->X = V1->Y * V2->Z - V1->Z * V2->Y ;
	V3->Y = V1->Z * V2->X - V1->X * V2->Z ;
}

/*
 * Calculate The Length Of The Vector
 */
+(float) magnitudeOf:(VECTOR *)V
{
	// Return The Length Of The Vector
	return sqrt( V->X * V->X + V->Y * V->Y + V->Z * V->Z );
}

+(void) subtractVector:(VECTOR *)V1 from:(VECTOR *)V2 into:(VECTOR *)V3
{
	V3->X=V2->X - V1->X;
	V3->Y=V2->Y - V1->Y;
	V3->Z=V2->Z - V1->Z;
}
+(void) addVector:(VECTOR *)V1 andVector:(VECTOR *)V2 into:(VECTOR *)V3
{
	V3->X=V2->X + V1->X;
	V3->Y=V2->Y + V1->Y;
	V3->Z=V2->Z + V1->Z;
}

+(void) rotateVectorAroundY:(VECTOR *)V radians:(float)rad{
	float oldX, oldZ;
	oldX = V->X;
	oldZ = V->Z;
	V->X=cos(rad)*oldX + sin(rad)*oldZ;
	V->Z=-sin(rad)*oldX + cos(rad)*oldZ;
}

/*
 * Creates A Vector With A Unit Length Of 1
 */
+(void) normalize:(VECTOR *)V
{
	float M = [ self magnitudeOf:V ];   // Calculate The Length Of The Vector
	
	if( M != 0.0f )                     // Make Sure We Don't Divide By 0
	{
		V->X /= M;                   // Normalize The 3 Components
		V->Y /= M;
		V->Z /= M;
	}
}
+(void) scaleVector:(VECTOR *)V byFactor:(float)factor
{
		V->X *= factor;                   // Normalize The 3 Components
		V->Y *= factor;
		V->Z *= factor;
}

+(void) makePolygonNormalsUnitRadial:(POLYGON *)poly{
	for(int i = 0 ; i < 3 ; i++){
		poly->Verts[i].Nor.X = poly->Verts[i].Pos.X;
		poly->Verts[i].Nor.Y = poly->Verts[i].Pos.Y;
		poly->Verts[i].Nor.Z = poly->Verts[i].Pos.Z;
		[Geometry normalize:&(poly->Verts[i].Nor)];
	}
}
+(void) makePolygonNormalsUnitFace:(POLYGON *)poly{
	VECTOR tmpV1;
	VECTOR tmpV2;
	[Geometry subtractVector:&(poly->Verts[0].Pos) from:&(poly->Verts[1].Pos) into:&tmpV1];
	[Geometry subtractVector:&(poly->Verts[0].Pos) from:&(poly->Verts[2].Pos) into:&tmpV2]	;
	
	for(int j = 0; j<3; j++){
		[Geometry crossProductOf:&tmpV1 with:&tmpV2 into:&(poly->Verts[j].Nor)];
		[Geometry normalize:&(poly->Verts[j].Nor)];
	}	
}

+(void) putPolygonNormal:(POLYGON *)poly inVector:(VECTOR *)vec{
	VECTOR tmpV1;
	VECTOR tmpV2;
	[Geometry subtractVector:&(poly->Verts[0].Pos) from:&(poly->Verts[1].Pos) into:&tmpV1];
	[Geometry subtractVector:&(poly->Verts[0].Pos) from:&(poly->Verts[2].Pos) into:&tmpV2]	;
	
	for(int j = 0; j<3; j++){
		[Geometry crossProductOf:&tmpV1 with:&tmpV2 into:vec];
		[Geometry normalize:vec];
	}		
}

@end

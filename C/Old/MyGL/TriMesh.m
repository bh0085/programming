//
//  TriMesh.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TriMesh.h"


@implementation TriMesh

#define Xiso .525731112119133606 
#define Ziso .850650808352039932


-(void) setMeshCreationScaleFactor:(float)f{
	meshCreationScaleFactor=f;
}

-(void) initToIsocahedron{
	meshCreationScaleFactor = 1.0;

	verts = malloc(36 * sizeof(float));
	float tempVerts[36] = {  	-Xiso, 0.0, Ziso, Xiso, 0.0, Ziso, -Xiso, 0.0, -Ziso, Xiso, 0.0, -Ziso,    
		0.0, Ziso, Xiso, 0.0, Ziso, -Xiso, 0.0, -Ziso, Xiso, 0.0, -Ziso, -Xiso,    
		Ziso, Xiso, 0.0, -Ziso, Xiso, 0.0, Ziso, -Xiso, 0.0, -Ziso, -Xiso, 0.0 
	};	
	verts = malloc(36 * sizeof(float));
	for(int i = 0 ; i < 36 ; i++){
		verts[i] = tempVerts[i];
	}
	n3verts = 12;
	idxs = malloc(60 * sizeof(int));
	int tempIdxs[60] = { 
		0,1,4, 0,4,9, 9,4,5, 4,8,5, 4,1,8,    
		8,1,10, 8,10,3, 5,8,3, 5,3,2, 2,3,7,    
		7,3,10, 7,10,6, 7,6,11, 11,6,0, 0,6,1, 
		6,10,1, 9,11,0, 9,2,11, 9,5,2, 7,11,2 
	};
	for(int i = 0 ; i < 60 ; i++){
		idxs[i] = tempIdxs[i];
	}
	nfaces = 20;
}

-(void) subdivide{
	int nedges = n3verts + nfaces - 2;
	int vSoFar = 0, fSoFar = 0,pairsSoFar =0;

	float * newVerts;
	int * newIdxs;
	
	//the elements of pairsdivided are three ints:
	//1/2: the pair of vertices joined.
	//3: the index of the VECTOR where the vertex lies.
	
	pairsDivided = malloc(nedges*3*sizeof(int));
	
	//A high upper bound on the number of new vectors that may exist...
	//nfaces *4 is the number of faces that will exist at the next subdivision.
	//there are fewer vertices...

	newVerts = malloc(3*sizeof(float) *nfaces*4);
	//partially fill newverts with the old vertices...
	//note that old indices will refer to the same vertex in the new array...
	for(int i = 0 ; i < n3verts*3 ; i++){
		newVerts[i] = verts[i];
	}
	vSoFar = n3verts;

	newIdxs = malloc( 4 * nfaces * 3*sizeof(int));
	
	for(int i = 0 ; i < nfaces ; i++){
		int theseVertices[6];
		for( int j = 0 ; j < 3 ; j++){
			//start filling the new vertex matrix for this polygon
			theseVertices[2*j] = idxs[3*i + j];
			
			//and get the current edge
			int pair[2] = {idxs[3*i+j],idxs[3*i + ((j+1)%3)]};
			
			//search to see if we have already subdivided this edge
			BOOL foundVert = FALSE;
			int vertNum;
			for(int k = 0 ; k < pairsSoFar; k++){
				if( ((pair[0] == pairsDivided[3*k]) || (pair[0] ==pairsDivided[3*k+1])) &&
					((pair[1] == pairsDivided[3*k]) || (pair[1] ==pairsDivided[3*k+1]))
				   ){
					//this pair has already been subdivided...
					//grab the vector index linked to and stick it in the current six vector array
					vertNum = pairsDivided[3*k +2];
					foundVert = TRUE;
					break;
				}
			}
			if(!foundVert){
					
				//make a new vertex entry for the midpoint
				newVerts[3*vSoFar] = verts[pair[0]*3] + verts[pair[1]*3];
				newVerts[3*vSoFar+1] = verts[pair[0]*3 +1] + verts[pair[1]*3 +1];
				newVerts[3*vSoFar+2] = verts[pair[0]*3 +2] + verts[pair[1]*3 +2];
				vertNum = vSoFar;
				vSoFar++;
					
					
				//make a new entry in pairs divided linked to the new vertex...
				pairsDivided[3 * pairsSoFar]=pair[0];
				pairsDivided[3 * pairsSoFar +1] = pair[1];
				pairsDivided[3 * pairsSoFar +2] = vertNum;
				pairsSoFar++;
			}
			theseVertices[2*j + 1] = vertNum;
		}
		int threadingPattern [12] = {0,1,5,1,2,3,3,4,5,1,3,5};
		for(int j = 0 ; j < 12 ; j ++){
			newIdxs[fSoFar*3 + j] = theseVertices[threadingPattern[j]];
		}
		fSoFar+=4;
	}
	
	free(idxs);
	free(verts);
	verts = newVerts;
	idxs = newIdxs;
	nfaces = fSoFar;
	n3verts = vSoFar;
	free(pairsDivided);
}

-(int) nFaces{
	return nfaces;
}

-(void)createMesh{
	VECTOR * norms;
	norms = calloc(n3verts, sizeof(VECTOR));
	
	POLYGON* polyout;
	polyout = malloc(nfaces * sizeof(POLYGON));
	
	VECTOR tempVecs[n3verts];
	for(int i = 0 ; i < n3verts ; i++){
		tempVecs[i].X=verts[0 +3*i];
		tempVecs[i].Y=verts[1+3*i];
		tempVecs[i].Z=verts[2+3*i];
		[Geometry normalize:&(tempVecs[i])];
	}
	
	for(int i = 0 ; i < n3verts ; i++){
		[Geometry scaleVector:&(tempVecs[i]) byFactor:meshCreationScaleFactor];
	}
	
	
	
	for(int i = 0 ; i < nfaces; i ++){
		for(int j = 0 ; j < 3 ; j++){
			polyout[i].Verts[j].Pos.X=tempVecs[idxs[i*3+j]].X;
			polyout[i].Verts[j].Pos.Y=tempVecs[idxs[i*3+j]].Y;
			polyout[i].Verts[j].Pos.Z=tempVecs[idxs[i*3+j]].Z;
		}
	}
	
	for(int i = 0 ; i < nfaces ; i++){
		VECTOR tempNorm;
		[Geometry putPolygonNormal:&(polyout[i]) inVector:&(tempNorm)];
		for(int j = 0 ; j < 3 ; j++){
			[Geometry addVector:&tempNorm andVector:&(norms[idxs[i*3 +j]]) into:&(norms[idxs[i*3 +j]])];
		}
	}
	
	for(int i = 0 ; i < n3verts ; i++){
		[Geometry normalize:&(norms[i])];
	}
	


	for(int i = 0 ; i < nfaces ; i++){
		for(int j = 0 ; j < 3 ; j++){
			polyout[i].Verts[j].Nor.X=norms[idxs[i*3 + j]].X;
			polyout[i].Verts[j].Nor.Y=norms[idxs[i*3 + j]].Y;
			polyout[i].Verts[j].Nor.Z=norms[idxs[i*3 + j]].Z;			
		}
	}
	currentMesh = polyout;
}

-(void)createRandomMesh:(float)randomness{
	VECTOR * norms;
	norms = calloc(n3verts, sizeof(VECTOR));
	
	POLYGON* polyout;
	polyout = malloc(nfaces * sizeof(POLYGON));
	
	VECTOR tempVecs[n3verts];
	for(int i = 0 ; i < n3verts ; i++){
		tempVecs[i].X=verts[0 +3*i];
		tempVecs[i].Y=verts[1+3*i];
		tempVecs[i].Z=verts[2+3*i];
		[Geometry normalize:&(tempVecs[i])];
	}
	
	for(int i = 0 ; i < n3verts ; i++){
		float r = (1 +((float)(rand() %100))/100*randomness) ;
		[Geometry scaleVector:&(tempVecs[i]) byFactor:r];
	}
	
	for(int i = 0 ; i < n3verts ; i++){
		[Geometry scaleVector:&(tempVecs[i]) byFactor:meshCreationScaleFactor];
	}
	
	
	
	
	for(int i = 0 ; i < nfaces; i ++){
		for(int j = 0 ; j < 3 ; j++){
			polyout[i].Verts[j].Pos.X=tempVecs[idxs[i*3+j]].X;
			polyout[i].Verts[j].Pos.Y=tempVecs[idxs[i*3+j]].Y;
			polyout[i].Verts[j].Pos.Z=tempVecs[idxs[i*3+j]].Z;
		}
	}
	
	for(int i = 0 ; i < nfaces ; i++){
		VECTOR tempNorm;
		[Geometry putPolygonNormal:&(polyout[i]) inVector:&(tempNorm)];
		for(int j = 0 ; j < 3 ; j++){
			[Geometry addVector:&tempNorm andVector:&(norms[idxs[i*3 +j]]) into:&(norms[idxs[i*3 +j]])];
		}
	}
	
	for(int i = 0 ; i < n3verts ; i++){
		[Geometry normalize:&(norms[i])];
	}
	
	
	
	for(int i = 0 ; i < nfaces ; i++){
		for(int j = 0 ; j < 3 ; j++){
			polyout[i].Verts[j].Nor.X=norms[idxs[i*3 + j]].X;
			polyout[i].Verts[j].Nor.Y=norms[idxs[i*3 + j]].Y;
			polyout[i].Verts[j].Nor.Z=norms[idxs[i*3 + j]].Z;			
		}
	}
	currentMesh = polyout;
}

-(POLYGON *) mesh{
	return currentMesh;
}

-(void) scaleMesh{
	
}



-(void) dealloc {
	free(currentMesh);
	free(verts);
	free(idxs);
	[super dealloc];
}



@end

//
//  CellShadedModelView.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CellShadedModelView.h"
#import <math.h>
@implementation CellShadedModelView



        // Storage For One Texture

-(void) initGL {
	
	meshes = [[NSMutableArray alloc] init];	
	[self initMeshes];
	[self initCellShading];
}

-(void) initMeshes{
}


-(void) initCellShading{
	
	//a clipping plane to eliminate things behind z = .5 for testing purposes
	
	//	GLdouble eqn[4] = {0.0, 0.0, 1.0, 0.0};
	//	glClipPlane (GL_CLIP_PLANE0, eqn);
	//	glEnable (GL_CLIP_PLANE0);
	
	
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LESS )  ;                 // Type of depth test to do
	glEnable( GL_CULL_FACE );                 // Enable OpenGL Face Culling
	glEnable( GL_BLEND );                  // Enable Blending
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );  // Set The Blend Mode

	
	float shaderData[ 32 ][ 3 ];   // Storate For The 96 Shader Values
	
	for(int i = 0 ; i < 32 ; i++){
		float shade;
		//if(i > 5 && i <20 ) shade = .8; else {if(i == 20 || i == 21) shade = .3; else shade = 0;}
		
		//shaderData[i][0] = shaderData[i][1] = shaderData[i][2] =1;
		//shaderData[i][0] = 1;
		shaderData[i][0] = shaderData[i][1] = shaderData[i][2] = ((float)(i / 8)/16 +.4 );
	}	
	
	
	glGenTextures( 1, &shaderTexture[ 0 ] );           // Get A Free Texture ID
	
	// Bind This Texture. From Now On It Will Be 1D
	glBindTexture( GL_TEXTURE_1D, shaderTexture[ 0 ] );
	
	// For Crying Out Loud Don't Let OpenGL Use Bi/Trilinear Filtering!
	glTexParameteri( GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	
	// Upload
	glTexImage1D( GL_TEXTURE_1D, 0, GL_RGB, 32, 0, GL_RGB , GL_FLOAT, shaderData );
	
	lightAngle.X = 0.0f;                     // Set The X Direction
	lightAngle.Y = 0.0f;                     // Set The Y Direction
	lightAngle.Z = 1.0f;                     // Set The Z Direction
	
	[ Geometry normalize:&lightAngle ];          // Normalize The Light Direction	
	
	
	
	
	
	
	
}

-(void) drawView {
	const float PI = 3.14159;
	glClearColor(.7,.7,.7,0);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );	
	glLoadIdentity();

	if(TRUE){
		VECTOR TmpNormal;
		float TmpShade;
		glBindTexture( GL_TEXTURE_1D, shaderTexture[ 0 ] );   // Bind Our Texture	
	
		glDepthFunc( GL_LESS );             // Reset The Depth-Testing Mode
		glCullFace( GL_BACK );              // Reset The Face To Be Culled
		glEnable( GL_TEXTURE_1D );                   // Enable 1D Texturing		
		glColor4f(1,1,1,1);   // Set The Outline Color
		glEnable(GL_MULTISAMPLE);
		
		for(int k = 0 ; k < [meshes count]; k++){
			int npolys = [[meshes objectAtIndex:k] nFaces];
			POLYGON * polyMesh = [[meshes objectAtIndex:k] mesh];
			glPushMatrix();
			float rot =1000 * yRot / ( 5 + (pow( offsets[k].X ,2.0) + pow( offsets[k].Z ,2.0)));

			glRotatef(rot , 0.0,1.0,0.0);
			glTranslatef(offsets[k].X,offsets[k].Y,offsets[k].Z);
			glRotatef(rot, 0.0,1.0,0.0);
			glBegin(GL_TRIANGLES);
			
			for(int i = 0 ; i < npolys ; i++){
				for(int j = 0 ; j < 3 ; j++){
					TmpNormal.X = polyMesh[ i ].Verts[ j ].Nor.X;
					TmpNormal.Y = polyMesh[ i ].Verts[ j ].Nor.Y;
					TmpNormal.Z = polyMesh[ i ].Verts[ j ].Nor.Z;
					
					[ Geometry normalize:&TmpNormal ];            // Normalize The New Normal
					[ Geometry rotateVectorAroundY:&TmpNormal radians:2* rot * PI * 2 / 360];
					TmpShade = [ Geometry dotProductOf:&TmpNormal with:&lightAngle ];
					if( TmpShade < 0.0f ){TmpShade = 0.0f;  }
					
					glTexCoord1f( TmpShade );		
					
					glVertex3f((float)polyMesh[i].Verts[j].Pos.X, 
							   (float)polyMesh[i].Verts[j].Pos.Y, 
							   (float)polyMesh[i].Verts[j].Pos.Z 
							   );     
				}
			}
			glEnd();   
			glPopMatrix();
		}
		glDisable(GL_MULTISAMPLE);

	}
	
	if( TRUE )              
	{
		// Draw Backfacing Polygons As Wireframes
		glPolygonMode( GL_BACK, GL_LINE);
	    glCullFace(GL_FRONT );             // Don't Draw Any Front-Facing Polygons
		glDepthFunc( GL_LEQUAL );           // Change The Depth Mode
		glDisable( GL_TEXTURE_1D );                   // Enable 1D Texturing	
		glDepthMask(GL_FALSE);
		glColor4f(.0,.0,.0,.7);   // Set The Outline Color
		glLineWidth(1);

		for(int k = 0 ; k < [meshes count]; k++){
			int npolys = [[meshes objectAtIndex:k] nFaces];
			POLYGON * polyMesh = [[meshes objectAtIndex:k] mesh];
			float rot =1000 * yRot / ( 5 + (pow( offsets[k].X ,2.0) + pow( offsets[k].Z ,2.0)));
			glPushMatrix();
			glRotatef(rot , 0.0,1.0,0.0);
			glTranslatef(offsets[k].X,offsets[k].Y,offsets[k].Z);
			glRotatef(rot, 0.0,1.0,0.0);
			glBegin(GL_TRIANGLES);
			for(int i = 0 ; i < npolys ; i++){
				for(int j = 0 ; j < 3 ; j++){
					glVertex3f((float)polyMesh[i].Verts[j].Pos.X, 
							   (float)polyMesh[i].Verts[j].Pos.Y, 
							   (float)polyMesh[i].Verts[j].Pos.Z 
							   );     
				}
			}
			 
			 
			glEnd();
			
			glPopMatrix();
		}
		glPolygonMode(GL_BACK, GL_FILL);
		glDepthMask(GL_TRUE);
		
		
	}
	
	
	
	
	[[NSOpenGLContext currentContext] flushBuffer];
	
}

-(void) dealloc {
	[super dealloc];
	[meshes release];
	free(offsets);
	free(shaderTexture);
}

@end

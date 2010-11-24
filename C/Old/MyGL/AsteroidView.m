//
//  AsteroidView.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "AsteroidView.h"

@interface AsteroidView (InternalMethods) 

- (void) buildFont;
@end

 
@implementation AsteroidView



-(void) initMeshes{
	//Asteroid * temp1, * temp2;
	for(int i = 0 ; i < 5 ; i++){

		[meshes addObject:[Asteroid alloc]];
		[[meshes objectAtIndex:i] initWithRandomMesh];
		[[meshes objectAtIndex:i] release];


	}

}

-(void) makeOffsets{
	offsets = malloc(sizeof(VECTOR) * [meshes count]);
	for (int i = 0 ; i < [meshes count] ; i++){
		offsets[i].X = ((float)(rand() % 1000))/50 -10;
		offsets[i].Y = ((float)(rand() % 1000))/50 -10;
		offsets[i].Z = ((float)(rand() % 1000))/50 -10;
		[Geometry normalize:&offsets[i]];
		[Geometry scaleVector:&offsets[i] byFactor:100];
		
	}
	
}
-(void) remakeOffsets{
	for (int i = 0 ; i < [meshes count] ; i++){
		offsets[i].X = ((float)(rand() % 1000))/50 -10;
		offsets[i].Y = ((float)(rand() % 1000))/50 -10;
		offsets[i].Z = ((float)(rand() % 1000))/50 -10;
		[Geometry normalize:&offsets[i]];
		[Geometry scaleVector:&offsets[i] byFactor:100];
		
	}
	
}

-(void) reinitializeGL 
{
	[self remakeOffsets];
}

-(void) initGL {
	meshes = [[NSMutableArray alloc] init];	
	[self initMeshes];
	[self makeOffsets];
	[self initCellShading];
	[self initLighting];
	[self buildFont];
	timer = 0;

}

-(void) initLighting
{
	GLfloat diffuse[] = {0,0,0,0};
	GLfloat ambience[] = {1,1,1,1};
	//glLightfv(GL_LIGHT0, GL_POSITION, light_position);
	glLightfv(GL_LIGHT0, GL_AMBIENT, ambience);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	//glEnable(GL_DEPTH_TEST);
}
- (void) buildFont
{
	fontManager = makeFreetypeManager("Courier New.ttf", 20);
	fontBaseList = makeDisplayLists(fontManager);		
}



- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport(0, 0, sceneBounds.size.width, sceneBounds.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,sceneBounds.size.width,0, sceneBounds.size.height,-200,200);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
}

/*
 * Called when the system thinks we need to draw.
 */

#include "MyCIDL.h"
#define circnum 5
#define PI 3.1415
void get_ellipse(float cx[circnum],float cy[circnum],float x,float y, float rx,float ry){
	static float cxs[circnum];
	static float cys[circnum];
		
	findgen(cxs, circnum);
		findgen(cys, circnum);
		scaleArrayf(cxs,2 * PI / circnum, circnum);
		scaleArrayf(cys, 2* PI / circnum, circnum);
		cosOfArrayf(cxs, circnum);
		sinOfArrayf(cys, circnum);	
	for (int i = 0 ; i < circnum ; i++){
		cx[i] = (cxs[i] * rx) + x;
		cy[i] = (cys[i] * ry) + y;
	}
}
extern void plots_ellipse(float x, float y, float rx, float ry){
	float xs[circnum];
	float ys[circnum];
	get_ellipse(xs, ys, x, y, rx,ry);
	glBegin(GL_LINE_LOOP);
	for(int i = 0 ; i < circnum ; i++){
		glVertex3f(xs[i],ys[i],0);
	}
	glEnd();	
	
}
void plots_ellipse_arc(float x, float y, float rx, float ry, float thetai, float thetaf,float thick){
	float xs[circnum];
	float ys[circnum];
	findgen(xs,circnum);
	findgen(ys,circnum);
	scaleArrayf(xs, (thetaf - thetai)/(circnum -1), circnum);
	scaleArrayf(ys, (thetaf - thetai)/(circnum -1), circnum);
	addConstantToArrayf(xs, thetai, circnum);
	addConstantToArrayf(ys, thetai, circnum);
	cosOfArrayf(xs, circnum);
	sinOfArrayf(ys, circnum);
	scaleArrayf(xs, rx, circnum);
	scaleArrayf(ys, ry, circnum);	
	
	float xouter[circnum];
	float youter[circnum];
	for(int i = 0 ; i < circnum ; i++){
		xouter[i] = xs[i]*thick;
		youter[i] = ys[i]*thick;
		xs[i]+=x;
		ys[i]+=y;
		xouter[i]+=x;
		youter[i]+=y;
	}
	GLfloat verts[circnum*2][3];
	for(int i = 0 ; i < circnum;i++){
		verts[(2*i)][0] = xs[i];
		verts[(2*i)][1] = ys[i];
		verts[(2*i)][2] = 0;
		verts[(2*i)+1][0]=xouter[i];
		verts[(2*i)+1][1]=youter[i];
		verts[(2*i)+1][2] = 0;
	}
	GLubyte indices[(circnum-1)*4];
	for(GLubyte i = 0 ; i < circnum-1 ; i++){
		indices[4*i] = 2*(i);
		indices[4*i +1] = 2*(i)+1;
		indices[4*i +2] = 2*(i+1)+1;
		indices[4*i +3] = 2*(i+1);
	}
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, verts);
	glDrawElements(GL_QUADS , (circnum -1)*4, GL_UNSIGNED_BYTE, indices);
	glDisableClientState(GL_VERTEX_ARRAY);	
	
}

- (void) drawView
{


	glClearColor(.2,.2,.2,1);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );	
	
	glLoadIdentity();
	glPushMatrix();

	glTranslatef(200,200,0);

	if(FALSE){
		VECTOR TmpNormal;
		float TmpShade;
		glBindTexture( GL_TEXTURE_1D, shaderTexture[ 0 ] );   // Bind Our Texture	
		
		glDepthFunc( GL_LESS );             // Reset The Depth-Testing Mode
		glCullFace( GL_BACK );              // Reset The Face To Be Culled
		glEnable( GL_TEXTURE_1D );                   // Enable 1D Texturing		
		glDisable(GL_LIGHTING);
		glColor4f(1,1,1,1);   
		
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
	}

	if( TRUE )              
	{
		GLfloat mAmbience[] = {.4,.4,.4,1};
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mAmbience);
		glEnable(GL_LIGHTING);
		// Draw Backfacing Polygons As Wireframes
		glPolygonMode( GL_BACK, GL_LINE);
	    glCullFace(GL_FRONT );             // Don't Draw Any Front-Facing Polygons
		glDepthFunc( GL_LEQUAL );           // Change The Depth Mode
		glDisable( GL_TEXTURE_1D );                   // Enable 1D Texturing	
		glDepthMask(GL_FALSE);
		glColor4f(1.0,1.0,1.0,.3);   // Set The Outline Color
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
	glPopMatrix();
	glLoadIdentity(); 

	
	GLfloat rasPos[4]  = {0.0,0.0,0.0,1.0};
	glRasterPos4fv(rasPos);
	printString(fontManager,"bad",fontBaseList);
	
	
	[ [ self openGLContext ] flushBuffer ];
}

-(void) timeStep{
	yRot+=4;
	
	timer += 1;
	GLfloat colorRot = (sin(((float)timer)/30) + 1)/2;
	//GLfloat colorRot2 = (sin(((float)timer)/200) + 1)/2;
	GLfloat ambience[] = {colorRot, 0, 1-colorRot,1};
	glLightfv(GL_LIGHT0, GL_AMBIENT, ambience);
	 
}

-(void) dealloc{
	[super dealloc];
}


@end

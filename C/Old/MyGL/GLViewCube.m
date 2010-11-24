//
//  GLViewCube.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLViewCube.h"


@implementation GLViewCube

// Ambient light values
static GLfloat lightAmbient[] = { .1f, .0f, .0f, 1.0f };
// Diffuse light values
static GLfloat lightDiffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
// Light position
static GLfloat lightPosition[] = { 0.0f, 0.0f, 2.0f, 1.0f };


-(void) timeStep{
	yRot++;
}

-(void) initGL{
	
	glEnable( GL_TEXTURE_2D );                // Enable texture mapping
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	// Setup ambient light
	glLightfv( GL_LIGHT1, GL_AMBIENT, lightAmbient );
	// Setup diffuse light
	glLightfv( GL_LIGHT1, GL_DIFFUSE, lightDiffuse );
	// Position the light
	glLightfv( GL_LIGHT1, GL_POSITION, lightPosition );
	
	glColor4f( 1.0f, 1.0f, 1.0f, 0.5f );   // Full brightness, 50% alpha
	// Blending function for translucency based on source alpha value
	glBlendFunc( GL_SRC_ALPHA, GL_ONE );
	
}

-(void) drawView{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	glLoadIdentity();   // Reset the current modelview matrix
	glRotated(yRot, 1, 0, 0);
	glTranslated(0, 0, 5);
	glEnable( GL_LIGHT1 );   // Enable light 1
	
	glLoadIdentity();
	glRotated(yRot, 0,1,0);
	glRotated(40, .5, .5, 1);
	glEnable(GL_LIGHTING);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glBegin( GL_QUADS ); 
	// Front Face
	glNormal3f( 0.0f, 0.0f, 1.0f );      // Normal Pointing Towards Viewer
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 1 (Front) 
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 2 (Front)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Front)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 4 (Front)
	// Back Face
	glNormal3f( 0.0f, 0.0f, -1.0f );     // Normal Pointing Away From Viewer
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Back)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 2 (Back)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 3 (Back)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 4 (Back)
	// Top Face
	glNormal3f( 0.0f, 1.0f, 0.0f );      // Normal Pointing Up
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 1 (Top)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 2 (Top)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Top)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 4 (Top)
	// Bottom Face
	glNormal3f( 0.0f, -1.0f, 0.0f );     // Normal Pointing Down
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Bottom)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 2 (Bottom)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 3 (Bottom)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 4 (Bottom)
	// Right face
	glNormal3f( 1.0f, 0.0f, 0.0f);       // Normal Pointing Right
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f, -1.0f );   // Point 1 (Right)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f, -1.0f );   // Point 2 (Right)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f(  1.0f,  1.0f,  1.0f );   // Point 3 (Right)
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f(  1.0f, -1.0f,  1.0f );   // Point 4 (Right)
	// Left Face
	glNormal3f( -1.0f, 0.0f, 0.0f );     // Normal Pointing Left
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f, -1.0f );   // Point 1 (Left)
	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f( -1.0f, -1.0f,  1.0f );   // Point 2 (Left)
	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f,  1.0f );   // Point 3 (Left)
	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( -1.0f,  1.0f, -1.0f );   // Point 4 (Left)
	glEnd();                             // Done Drawing Quads
	
	[[NSOpenGLContext currentContext] flushBuffer];
}


@end

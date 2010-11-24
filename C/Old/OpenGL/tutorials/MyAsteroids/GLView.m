//
//  GLView.m
//  MyAsteroids
//
//  Created by Benjamin Holmes on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLView.h"

@interface GLView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (void) switchToOriginalDisplayMode;
- (BOOL) initGL;
- (void) glPrintAtX:(GLint)x Y:(GLint)y set:(int)set
			 format:(char *)fmt, ...;
@end


@implementation GLView

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits 
{
	
	colorBits = numColorBits;
	depthBits = numDepthBits;
	anti = TRUE;


	//eliminated all the pixelformat stuff...	
	self = [ super initWithFrame:frame ];
		if( self )
		{
			[ [ self openGLContext ] makeCurrentContext ];

			if( ![ self initGL ] )
			{
				[ self clearGLContext ];
				self = nil;
			}
		}
	

	
	return self;
}


/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{

	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	// Set line antialiasing
	glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
	glEnable( GL_BLEND );                     // Enable blending
	// Type of blending to use
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	return TRUE;
}

/*
 * Resize ourself
 */
- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Create ortho view (0,0 at top left)
	glOrtho( 0.0f, sceneBounds.size.width, sceneBounds.size.height, 0.0f,
            -1.0f, 1.0f );
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}

/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{
	
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glColor3f( 1.0f, 0.5f, 1.0f );                  // Set color to purple
	glBegin(GL_LINES);
	glVertex2d(-5.0, -5.0);
	glVertex2d(5.0, 5.0);
	glEnd();
	glFlush();
	/*
	// Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glBindTexture( GL_TEXTURE_2D, texture[ 0 ] );   // Select font texture
	glColor3f( 1.0f, 0.5f, 1.0f );                  // Set color to purple
	// Write GRID CRAZY to the screen
	[ self glPrintAtX:207 Y:24 set:0 format:"GRID CRAZY" ];
	glColor3f( 1.0f, 1.0f, 0.0f );                  // Set color to yellow
	// Write actual level stats
	[ self glPrintAtX:20 Y:20 set:1 format:"Level:%2i", level2 ];
	// Write stage stats
	[ self glPrintAtX:20 Y:40 set:1 format:"Stage:%2i", stage ];
	
	if( gameover )
	{
		// Pick a random color
		glColor3ub( rand() % 255, rand() % 255, rand() % 255 );
		[ self glPrintAtX:472 Y:20 set:1 format:"GAME OVER" ];
		[ self glPrintAtX:456 Y:40 set:1 format:"PRESS SPACE" ];
	}
	
	for( loop1 = 0; loop1 < lives - 1; loop1++ )
	{
		glLoadIdentity();   // Reset the view
		// Move to the right of our title text
		glTranslatef( 490 + ( (float) loop1 ) * 40.0f, 40.0f, 0.0f );
		// Rotate counterclockwise
		glRotatef( -player.spin, 0.0f, 0.0f, 1.0f );
		glColor3f( 0.0f, 1.0f, 0.0f );   // Set player color to light green
		glBegin( GL_LINES );
		glVertex2d( -5, -5 );   // Top left of player
		glVertex2d(  5,  5 );   // Bottom right of player
		glVertex2d(  5, -5 );   // Top right of player
		glVertex2d( -5,  5 );   // Bottom left of player
		glEnd();
		// Rotate counterclockwise
		glRotatef( -player.spin * 0.5f, 0.0f, 0.0, 1.0f );
		glColor3f( 0.0f, 0.75f, 0.0f );   // Set player color to dark green
		glBegin( GL_LINES );
		glVertex2d( -7,  0 );   // Left center of player
		glVertex2d(  7,  0 );   // Right center of player
		glVertex2d(  0, -7 );   // Top center of player
		glVertex2d(  0,  7 );   // Bottom center of player
		glEnd();
	}
	
	filled = TRUE;                 // Set filled to tru before testing
	glLineWidth( 2.0f );           // Set line width for cells to 2.0
	glDisable( GL_LINE_SMOOTH );   // Disable antialiasing
	glLoadIdentity();              // Reset the modelview matrix
	for( loop1 = 0; loop1 < 11; loop1++ )   // Left to right
	{
		for( loop2 = 0; loop2 < 11; loop2++ )   // Top to bottom
		{
			glColor3f( 0.0f, 0.5f, 1.0f );   // Set line color to blue
			if( hline[ loop1 ][ loop2 ] )    // Has the horiz line been traced
				glColor3f( 1.0f, 1.0f, 1.0f );  // If so, use white
			if( loop1 < 10 )                 // Don't draw to far right
			{
				if( !hline[ loop1 ][ loop2 ] )   // If not filled
					filled = FALSE;
				glBegin( GL_LINES );
				// Left side of horizontal line
				glVertex2d( 20 + ( loop1 * 60 ), 70 + ( loop2 * 40 ) );
				// Right side of horizontal line
				glVertex2d( 80 + ( loop1 * 60 ), 70 + ( loop2 * 40 ) );
				glEnd();
			}
			glColor3f( 0.0f, 0.5f, 1.0f );   // Set color to blue
			if( vline[ loop1 ][ loop2 ] )    // Has the vert line been traced
				glColor3f( 1.0f, 1.0f, 1.0f );   // If so, use white
			if( loop2 < 10 )                 // Don't draw too far down
			{
				if( !vline[ loop1 ][ loop2 ] )   // If not filled
					filled = FALSE;
				glBegin( GL_LINES );
				// Top of vertical line
				glVertex2d( 20 + ( loop1 * 60 ), 70 + ( loop2 * 40 ) );
				// Bottom of vertical line
				glVertex2d( 20 + ( loop1 * 60 ), 110 + ( loop2 * 40 ) );
				glEnd();
			}
			
			glEnable( GL_TEXTURE_2D );
			glColor3f( 1.0f, 1.0f, 1.0f );   // Bright white
			// Select the tile image
			glBindTexture( GL_TEXTURE_2D, texture[ 1 ] );
			// If in bounds, fill in traced boxes
			if( ( loop1 < 10 ) && ( loop2 < 10 ) )
			{
				// Are all the sides of the box traced?
				if( hline[ loop1 ][ loop2 ] && hline[ loop1 ][ loop2 + 1 ] &&
				   vline[ loop1 ][ loop2 ] && vline[ loop1 + 1 ][ loop2 ] )
				{
					glBegin( GL_QUADS );
					glTexCoord2f( (float) loop1 / 10.0f + 0.1f,
								 1.0f - (float) loop2 / 10.0f );
					glVertex2d( 20 + ( loop1 * 60 ) + 59,
							   ( 70 + loop2 * 40 + 1 ) );    // Top Right
					glTexCoord2f( (float) loop1 / 10.0f,
								 1.0f - (float) loop2 / 10.0f );
					glVertex2d( 20 + ( loop1 * 60 ) + 1,
							   ( 70 + loop2 * 40 + 1 ) );    // Top Left
					glTexCoord2f( (float) loop1 / 10.0f,
								 1.0f - (float) loop2 / 10.0f + 0.1f );
					glVertex2d( 20 + ( loop1 * 60 ) + 1,
							   ( 70 + loop2 * 40 ) + 39 );   // Bottom Left
					glTexCoord2f( (float) loop1 / 10.0f + 0.1f,
								 1.0f - (float) loop2 / 10.0f + 0.1f );
					glVertex2d( 20 + ( loop1 * 60 ) + 59,
							   ( 70 + loop2 * 40 ) + 39 );   // Bottom Right
					glEnd();
				}
			}
			glDisable( GL_TEXTURE_2D );
		}
	}
	
	glLineWidth( 1.0f );   // Set line width to 1.0
	
	if( anti )
		glEnable( GL_LINE_SMOOTH );   // Enable antialiasing
	
	if( hourglass.fx == 1 )   // Draw hourglass when fx is 1
	{
		glLoadIdentity();
		// Position the hourglass
		glTranslatef( 20.0f + ( hourglass.x * 60 ),
					 70.0f + ( hourglass.y * 40 ), 0.0f );
		glRotatef( hourglass.spin, 0.0f, 0.0f, 1.0f );   // Rotate clockwise
		// Select a random color
		glColor3ub( rand() % 255, rand() % 255, rand() % 255 );
		glBegin( GL_LINES );
		glVertex2d( -5, -5 );   // Top left of hourglass
		glVertex2d(  5,  5 );   // Bottom right of hourglass
		glVertex2d(  5, -5 );   // Top right of hourglass
		glVertex2d( -5,  5 );   // Bottom left of hourglass
		glVertex2d( -5,  5 );   // Bottom left again
		glVertex2d(  5,  5 );   // Bottom right of hourglass
		glVertex2d( -5, -5 );   // Top left of hourglass
		glVertex2d(  5, -5 );   // Top right of hourglass
		glEnd();
	}
	
	glLoadIdentity();
	// Move to the fine player position
	glTranslatef( player.fx + 20.0f, player.fy + 70.0f, 0.0f );
	glRotatef( player.spin, 0.0f, 0.0f, 1.0f );   // Rotate clockwise
	glColor3f( 0.0f, 1.0f, 0.0f );          // Set player color to light green
	glBegin( GL_LINES );
	glVertex2d( -5, -5 );   // Top left of player
	glVertex2d(  5,  5 );   // Bottom right of player
	glVertex2d(  5, -5 );   // Top right of player
	glVertex2d( -5,  5 );   // Bottom left of player
	glEnd();
	
	glRotatef( player.spin * 0.5f, 0.0f, 0.0f, 1.0f );   // Rotate clockwise
	glColor3f( 0.0f, 0.75f, 0.0f );   // Set player color to dark green
	glBegin( GL_LINES );
	glVertex2d( -7,  0 );   // Left center of player
	glVertex2d(  7,  0 );   // Right center of player
	glVertex2d(  0, -7 );   // Top center of player
	glVertex2d(  0,  7 );   // Bottom center of player
	glEnd();
	
	for( loop1 = 0; loop1 < ( stage * level ); loop1++ )
	{
		glLoadIdentity();
		glTranslatef( enemy[ loop1 ].fx + 20.0f, enemy[ loop1 ].fy + 70.0f,
					 0.0f );
		glColor3f( 1.0f, 0.5f, 0.5f );   // Make enemy body pink
		glBegin( GL_LINES );
		glVertex2d(  0, -7 );   // Top point of body
		glVertex2d( -7,  0 );   // Left point of body
		glVertex2d( -7,  0 );   // Left point again
		glVertex2d(  0,  7 );   // Bottom point of body
		glVertex2d(  0,  7 );   // Bottom point
		glVertex2d(  7,  0 );   // Right point of body
		glVertex2d(  7,  0 );   // Right point
		glVertex2d(  0, -7 );   // Top point of body
		glEnd();
		// Rotate the enemy blade
		glRotatef( enemy[ loop1 ].spin, 0.0f, 0.0f, 1.0f );
		glColor3f( 1.0f, 0.0f, 0.0f );   // Make enemy blade red
		glBegin( GL_LINES );
		glVertex2d( -7, -7 );   // Top left of enemy
		glVertex2d(  7,  7 );   // Bottom right of enemy
		glVertex2d( -7,  7 );   // Bottom left of enemy
		glVertex2d(  7, -7 );   // Top right of enemy
		glEnd();
	} */
	
	//[ [ self openGLContext ] flushBuffer ];
}

- (void) toggleAntialiasing
{
	anti = !anti;
}

- (void) updateGame
{
	/*
	int loop1, loop2;
	
	if( !gameover )
	{
		for( loop1 = 0; loop1 < ( stage * level ); loop1++ )
		{
			if( ( enemy[ loop1 ].x < player.x ) &&
			   ( enemy[ loop1 ].fy == enemy[ loop1 ].y * 40 ) )
				enemy[ loop1 ].x++;   // Move enemy right
			
			if( ( enemy[ loop1 ].x > player.x ) &&
			   ( enemy[ loop1 ].fy == enemy[ loop1 ].y * 40 ) )
				enemy[ loop1 ].x--;   // Move enemy left
			
			if( ( enemy[ loop1 ].y < player.y ) &&
			   ( enemy[ loop1 ].fx == enemy[ loop1 ].x * 60 ) )
				enemy[ loop1 ].y++;   // Move enemy down
			
			if( ( enemy[ loop1 ].y > player.y ) &&
			   ( enemy[ loop1 ].fx == enemy[ loop1 ].x * 60 ) )
				enemy[ loop1 ].y--;   // Move enemy up
			
			// If our delay is done and player doesn't have hourglass
			if( delay > ( 3 - level ) && ( hourglass.fx != 2 ) )
			{
				delay = 0;   // Reset the delay counter
				for( loop2 = 0; loop2 < ( stage * level ); loop2++ )
				{
					// Is fine position on X axis lower than intended position?
					if( enemy[ loop2 ].fx < enemy[ loop2 ].x * 60 )
					{
						// Increase fine position on X axis
						enemy[ loop2 ].fx += steps[ adjust ];
						// Spin enemy clockwise
						enemy[ loop2 ].spin += steps[ adjust ];
					}
					// Is fine position on X axis higher than intended position?
					if( enemy[ loop2 ].fx > enemy[ loop2 ].x * 60 )
					{
						// Decrease fine position on X axis
						enemy[ loop2 ].fx -= steps[ adjust ];
						// Spin enemy counterclockwise
						enemy[ loop2 ].spin -= steps[ adjust ];
					}
					// Is fine position on Y axis lower than intended position?
					if( enemy[ loop2 ].fy < enemy[ loop2 ].y * 40 )
					{
						// Increase fine position on Y axis
						enemy[ loop2 ].fy += steps[ adjust ];
						// Spin enemy clockwise
						enemy[ loop2 ].spin += steps[ adjust ];
					}
					// Is fine position on Y axis higher than intended position?
					if( enemy[ loop2 ].fy > enemy[ loop2 ].y * 40 )
					{
						// Decrease fine position on Y axis
						enemy[ loop2 ].fy -= steps[ adjust ];
						// Spin enemy counterclockwise
						enemy[ loop2 ].spin -= steps[ adjust ];
					}
				}
			}
			// are any of the enemies on top of the player?
			if( ( enemy[ loop1 ].fx == player.fx ) &&
			   ( enemy[ loop1 ].fy == player.fy ) )
			{
				lives--;   // Player loses a life
				if( lives == 0 )
					gameover = TRUE;
				[ self resetObjects ];   // Reset player / enemy positions
				[ dieSound play ];
			}
		}
		
		// Is fine position on X axis lower than intended position?
		if( player.fx < player.x * 60 )
			player.fx += steps[ adjust ];   // Increase the fine X position
		// Is fine position on X axis greater than intended position?
		if( player.fx > player.x * 60 )
			player.fx -= steps[ adjust ];   // Decrease the fine X position
		// Is fine position on Y axis lower than intended position?
		if( player.fy < player.y * 40 )
			player.fy += steps[ adjust ];   // Increase the fine Y position
		// Is fine position on Y axis greater than intended position?
		if( player.fy > player.y * 40 )
			player.fy -= steps[ adjust ];   // Decrease the fine Y position
	}
	
	[ self checkFilled ];
	
	if( ( player.fx == hourglass.x * 60 ) &&
       ( player.fy == hourglass.y * 40 ) && ( hourglass.fx == 1 ) )
	{
		[ freezeSound play ];
		hourglass.fx = 2;   // Flag that player hit the hourglass
		hourglass.fy = 0;   // Set timer for display hourglass to 0
	}
	
	player.spin += 0.5f * steps[ adjust ];   // Spin the player clockwise
	if( player.spin > 360.0f )
		player.spin -= 360.0f;
	
	// Spin the hourglass counterclockwise
	hourglass.spin -= 0.25f * steps[ adjust ];
	if( hourglass.spin < 0.0f )
		hourglass.spin += 360.0f;
	
	hourglass.fy += steps[ adjust ];   // Increase hourglass timer
	if( ( hourglass.fx == 0 ) && ( hourglass.fy > 6000 / level ) )
	{
		[ hourglassSound play ];
		hourglass.x = rand() % 10 + 1;   // A random X value
		hourglass.y = rand() % 11;       // A random Y value
		hourglass.fx = 1;                // Hourglass is now visible
		hourglass.fy = 0;                // Reset hourglass timer
	}
	
	if( ( hourglass.fx == 1 ) && ( hourglass.fy > 6000 / level ) )
	{
		hourglass.fx = 0;   // Hourglass no longer visible
		hourglass.fy = 0;   // Reset hourglass timer
	}
	
	if( ( hourglass.fx == 2 ) && ( hourglass.fy > 500 + ( 500 * level ) ) )
	{
		hourglass.fx = 0;   // Hourglass no longer visible
		hourglass.fy = 0;   // Reset hourglass timer
	}
	
	delay++;   // Increase the enemy delay counter
	 */
}

-(void) movePlayerUp
{
	
}
-(void) movePlayerDown
{
	
}
-(void) movePlayerLeft
{
	
}
-(void) movePlayerRight
{
	
}


@end

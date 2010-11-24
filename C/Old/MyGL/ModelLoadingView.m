//
//  ModelLoadingView.m
//  MyGL
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ModelLoadingView.h"
#import <math.h>
#import <OpenGL/glu.h>


@implementation ModelLoadingView





-(void) initGL{
	
}


-(void) reshape{
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height);
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	/*gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
	 -50.0f, 100.0f );	*/
	glOrtho(-50,50,-50,50,-50,50);
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}
-(void) makeModel{
	/*
	FILE * pFile;
	char cwd[100];
	getcwd(cwd, 99);
	chdir("/Users/bh0085/Programming/Cocoa/MyGL/output");
	
	POLYGON * polys;
	//polys = calloc(npolys,sizeof(POLYGON));
	for(int i = 0 ; i < npolys ; i++){
		//float theta = ((float)i)/ 4 /npolys * 2 * PI;
		for(int j = 0 ; j < 3 ;j++){
			polys[i].Verts[j];
			VECTOR * pos = &(polys[i].Verts[j].Pos);
			(*pos).X = (float)(5.0f*i/npolys);
			switch (j){
				case 0:
					(*pos).Y=0.0;
					(*pos).Z=0.0;
					break;
				case 2:
					(*pos).Y=.5;
					(*pos).Z=0.0;
					break;
				case 1:
					(*pos).Y=0.0;
					(*pos).Z=.5 - (.5 * (float)i/npolys);
					(*pos).X=(*pos).X + (.5 - (float)i / npolys);
					break;
			}

		}
		VECTOR tmpV1;
		VECTOR tmpV2;
		[Geometry subtractVector:&(polys[i].Verts[0].Pos) from:&(polys[i].Verts[1].Pos) into:&tmpV1];
		[Geometry subtractVector:&(polys[i].Verts[0].Pos) from:&(polys[i].Verts[2].Pos) into:&tmpV2]	;
	
		[Geometry normalize:(&tmpV1)];
		[Geometry normalize:(&tmpV2)];
		
		for(int j = 0; j<3; j++){
			[Geometry crossProductOf:&tmpV1 with:&tmpV2 into:&(polys[i].Verts[j].Nor)];
		}
	}
	
	
	//char buffer[] = { 'x' , 'y' , 'z' };
	pFile = fopen ( "myfile.bin" , "wb" );
	fwrite(&(npolys), 1, sizeof(int),pFile);
	fwrite(polys , 1 , sizeof(polys) , pFile );
	free(polys);
	fclose (pFile);	
	 */
	
}
/*
-(POLYGON *) readModel{
	
	FILE * pFile;
	POLYGON * polys;
	pFile=fopen("myfile.bin","rb");
	fread(&(nread),1,sizeof(int),pFile);
	polys = malloc(nread*sizeof(POLYGON));
	fread (polys,1,nread*sizeof(POLYGON),pFile);	
	
	for(int i = 0; i <nread ;i++){
	//	printf("%f , ",polys[i].Verts[1].Pos.X);
	}
	fclose(pFile);
	return polys;
	 
}*/

-(void) drawView{
}



-(void) dealloc{
	[super dealloc];
}

@end

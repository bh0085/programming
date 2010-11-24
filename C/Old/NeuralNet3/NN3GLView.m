
#import "NN3GLView.h"

@interface NN3GLView (InternalMethods)
-(void) makeWithFrame:(NSRect)frame;
-(void) initGL;
-(NSOpenGLPixelFormat *) createMultisamplePixelFormat;

@end
@implementation NN3GLView


-(void) initNowWithFrame:(NSRect)frame{
	[self makeWithFrame:frame];
	[self initGL];

}

-(void) makeWithFrame:(NSRect)frame{
	NSOpenGLPixelFormat * pixelFormat = [self createMultisamplePixelFormat];
	self = [ super initWithFrame:[[self superview]frame] pixelFormat:pixelFormat ];
	[pixelFormat release];
	[ [ self openGLContext ] makeCurrentContext ];	
	[self reshape];
}

- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	glViewport(0, 0, sceneBounds.size.width, sceneBounds.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-.1,1.2,-4,4,-200,200);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
}

-(void) initGL{
	
}

-(NSOpenGLPixelFormat *) createMultisamplePixelFormat{
	NSOpenGLPixelFormat * pixelFormat;
	
	NSOpenGLPixelFormatAttribute pixelAttribs[] = { // 1		
		
		NSOpenGLPFAColorSize, 8,  // 2		
		NSOpenGLPFADepthSize, 8,		
		NSOpenGLPFADoubleBuffer,		
		NSOpenGLPFAAccelerated,	
		NSOpenGLPFASampleBuffers, 1,
		NSOpenGLPFASamples, 3,
		NSOpenGLPFANoRecovery,		
		0		
	};	
	
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
				   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;	
}


-(void) drawView{
	glClearColor(0.0,0.0,0.0,0.0);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	[[NSOpenGLContext currentContext] flushBuffer];
}

-(void) setRange:(float * )params{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-.1,1.2,params[2],params[3],params[4],params[5]);
	glMatrixMode(GL_MODELVIEW);	
}



@end

extern void NNGLFlush(){


	//now search plot each nonempty array.
	for(int i = 0 ; i < 256 ; i++){

		glColor3f(NNGLPlotArrayColors[i][0],NNGLPlotArrayColors[i][1],NNGLPlotArrayColors[i][2]);
		glBegin(GL_POINTS);
		for(int j = 0 ; (j + 2) < (NNGLPlotArrayIndices[i]) ; j+=3){
			glVertex3f(	
					NNGLPlotArrayPointers[i][j],
					NNGLPlotArrayPointers[i][j+1],
					NNGLPlotArrayPointers[i][j+2]
					   );
			
			
		}	
		glEnd();
		NNGLPlotArrayIndices[i] = 0;
		NNGLPlotArraySizes[i] = 0;
		if( NNGLPlotArraySizes[i] !=0){free(NNGLPlotArrayPointers[i]);}
	}
	


	[[NSOpenGLContext currentContext] flushBuffer];		
}

extern void NNGLAxis2f(float x, float y){
	
	glColor4f(1,1,1,.1);
	glBegin(GL_LINES);
	glVertex2f(x - 100, y);
	glVertex2f(x + 100, y);
	//glVertex2f(x,y-100);
	//glVertex2f(x,y+100);
	glEnd();
	}

//plot a point to one of 256 arrays...
extern void NNGLPlot3f(unsigned int whichArray ,float x, float y, float z){
	//first, if no points have been added to the current plot generate an array pointer.
	if(NNGLPlotArrayIndices[whichArray] == 0){
		NNGLPlotArrayPointers[whichArray] = malloc(sizeof(float) * 30000);
		NNGLPlotArraySizes[whichArray] = 30000;
	}
	//next, if points have been added but the array is at capacity, resize by creating a larger copy.
	if(NNGLPlotArrayIndices[whichArray] + 2 >= NNGLPlotArraySizes[whichArray]){
		unsigned int newSize = NNGLPlotArraySizes[whichArray] + 30000;
		float * newArray = malloc(sizeof(float) * newSize);
		memcpy(newArray, NNGLPlotArrayPointers[whichArray], sizeof(float) * NNGLPlotArraySizes[whichArray]);
		free(NNGLPlotArrayPointers[whichArray]);
		NNGLPlotArrayPointers[whichArray] = newArray;
		NNGLPlotArraySizes[whichArray] = newSize;
	}
	//finally, place the new point in the appropriately sized array
	NNGLPlotArrayPointers[whichArray][NNGLPlotArrayIndices[whichArray]] = x;
	NNGLPlotArrayPointers[whichArray][NNGLPlotArrayIndices[whichArray]+1] = y;
	NNGLPlotArrayPointers[whichArray][NNGLPlotArrayIndices[whichArray]+2] = z;
	//and increment the index by three - the number of floats added.
	NNGLPlotArrayIndices[whichArray]+=3;

};
extern void NNGLColorRed(unsigned int whichArray){
	NNGLColor3f(whichArray,1,0,0);
};
extern void NNGLColorBlue(unsigned int whichArray){
	NNGLColor3f(whichArray,0,0,1);
};
extern void NNGLColorGreen(unsigned int whichArray){
	NNGLColor3f(whichArray,0,1,0);
};
extern void NNGLColorOrange(unsigned int whichArray){
	NNGLColor3f(whichArray,1,.5,0);
};
extern void NNGLColorPurple(unsigned int whichArray){
	NNGLColor3f(whichArray,.5,0,.5);
};

extern void NNGLColor3f(unsigned int whichArray, float r, float g, float b){
	NNGLPlotArrayColors[whichArray][0]=r;
	NNGLPlotArrayColors[whichArray][1]=g;
	NNGLPlotArrayColors[whichArray][2]=b;
};



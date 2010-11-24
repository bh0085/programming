#import "GLIController.h"
//#import "GLIDL.h"
@implementation GLIController

static GLIController *activeController = nil;

- (void) buildFont
{
	fontManager = makeFreetypeManager("Courier New.ttf", 20);
	fontBaseList = makeDisplayLists(fontManager);		
}


-(id)		init{
	freetypeHasLoaded = false;
	self = [super init];
	activeController = self;
	for(int i = 0 ; i <MAX_WINDOWS ; i++){
		windows[i] = [[GLIWindow alloc] init];
	}
	
	return self;
}

-(void)		window:(int)index AtXY:(int [2])xy WithSize:(int [2])size{
	if(![windows[index] getVisible]){
		[windows[index] setPos:xy];
		[windows[index] setSize:size];
		[windows[index] displayNow];
	} else {
		[windows[index] setCurrent];
	}
}
-(void)		window:(int) index AtXY:(int [2])xy{
	if(![windows[index] getVisible]){
		[windows[index] setPos:xy];
		[windows[index] displayNow];
	} else {
		[windows[index] setCurrent];		
	}
}
-(void)		window:(int) index{
	if(![windows[index] getVisible]){
		[windows[index] displayNow];
	} else {
		[windows[index] setCurrent];
	}
}

-(void)		keyDown:(NSEvent *)theEvent{
	unichar unicodeKey;
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];	
}
-(void)		applicationWillTerminate:(NSNotification *)not{
	[self release];
}
-(void)		dealloc{
	for(int i = 0 ; i <MAX_WINDOWS ; i++){
		[windows[i] release];
	}
	free(fontManager);
	[super dealloc];
}
+(GLIController *) getActiveController{
	return activeController;
}

void window_pos( GLfloat x, GLfloat y, GLfloat z, GLfloat w )
{
	GLfloat fx, fy;
	
	/* Push current matrix mode and viewport attributes */
	glPushAttrib( GL_TRANSFORM_BIT | GL_VIEWPORT_BIT );
	
	/* Setup projection parameters */
	glMatrixMode( GL_PROJECTION );
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode( GL_MODELVIEW );
	glPushMatrix();
	glLoadIdentity();
	
	glDepthRange( z, z );
	glViewport( (int) x - 1, (int) y - 1, 2, 2 );
	
	/* set the raster (window) position */
	fx = x - (int) x;
	fy = y - (int) y;
	glRasterPos4f( fx, fy, 0.0, w );
	
	/* restore matrices, viewport and matrix mode */
	glPopMatrix();
	glMatrixMode( GL_PROJECTION );
	glPopMatrix();
	
	glPopAttrib();
}


-(void) ftPrint:(const char *)str  atViewXY:(float *)viewXY{
	if(!freetypeHasLoaded){
		[self buildFont];
		freetypeHasLoaded = true;
	}
	viewXY[1]-=18;
	GLfloat rasPos[4] = {viewXY[0],viewXY[1],0,1};
	glWindowPos3f(rasPos[0], rasPos[1], rasPos[2]);
	printString(fontManager,str,fontBaseList);		
}
-(void) ftPrint:(const char *)str  atOrthoXY:(float *)orthoXY{
	if(!freetypeHasLoaded){
		[self buildFont];
		freetypeHasLoaded = true;
	}
	float viewXY[2];
	GLIDLviewportXYOfOrtho(orthoXY, viewXY) ;
	viewXY[1] -= 18;
	GLfloat rasPos[4] = {viewXY[0],viewXY[1] ,0,1};
	glWindowPos3f(rasPos[0], rasPos[1], rasPos[2]);
	printString(fontManager,str,fontBaseList);		
}


@end

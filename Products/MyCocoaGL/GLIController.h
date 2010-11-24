#ifndef GLICONTROLLER_H
#define GLICONTROLLER_H
#include	<Cocoa/Cocoa.h>
#include	"GLIWindow.h"
#define MAX_WINDOWS 10

@interface GLIController : NSResponder {
	GLIWindow * windows[MAX_WINDOWS];
	FreetypeManager * fontManager;
	unsigned int fontBaseList;
	bool freetypeHasLoaded;
	NSTimer * renderTimer;
}
-(id)		init;
-(void)		window:(int)idx;
-(void)		window:(int)index AtXY:(int [2])xy WithSize:(int[2])size;
-(void)		window:(int) index AtXY:(int [2])xy;
-(void)		dealloc;
+(GLIController *) getActiveController;
-(void) ftPrint:(const char *)str atViewXY:(float *)viewXY;
-(void) ftPrint:(const char *)str  atOrthoXY:(float *)orthoXY;

@end
#endif
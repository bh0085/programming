//
//  glView.h
//  FullscreenTest
//
//  Created by Benjamin Holmes on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface glView : NSOpenGLView {
	BOOL runningFullScreen;
	NSDictionary *originalDisplayMode;
	NSOpenGLContext * originalContext;

}

-(void) initNowWithFrame:(NSRect)frame;
-(NSOpenGLPixelFormat *) createFullScreenPixelFormat;
-(NSOpenGLPixelFormat *) createWindowedPixelFormat;
-(void) drawView;
-(BOOL) isFullScreen;
-(void) makeWithFrame:(NSRect)frame;
-(void) makeFullScreen;
-(void) unMakeFullScreen;
-(void) toggleFullScreen;
-(void) reshape;
-(void) timeStep;
@end

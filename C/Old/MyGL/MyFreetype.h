#include <stdio.h>
#include <string.h>
#include <math.h>
#import <OpenGL/OpenGL.h>
#include <ft2build.h>

#include FT_FREETYPE_H
unsigned char * createBMP( FT_Bitmap*  bitmap,int bmpTop, int bmpLeft);
unsigned char * getFontPixels( unsigned char whichChar);
//unsigned char * initFTAndCreateImage();
int ftHeight();
int ftWidth();
unsigned int checkWidth(unsigned char whichChar);


#ifdef __cplusplus

#ifndef FREETYPE_H
#define FREETYPE_H
#include <ft2build.h>
#endif

#include FT_FREETYPE_H

#ifndef STRING_H
#define STRING_H
//#include <string.h>
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif
	
#ifdef __cplusplus
class FreetypeManager;
#else
typedef
	struct FreetypeManager FreetypeManager;
#endif
	
FreetypeManager * makeFreetypeManager(const char fontName[], int size);
unsigned char * getFontPixels( FreetypeManager * manager, unsigned char whichChar);
unsigned char * getFontAlphaLuminance( FreetypeManager * manager, unsigned char whichChar);
unsigned char * getFontRGBA( FreetypeManager * manager, unsigned char whichChar, float RGBA[4]);

unsigned int widthOfCharacter( FreetypeManager * manager, unsigned char whichChar);
void killFreetypeManager(FreetypeManager * manager);
unsigned int getFTHeight( FreetypeManager * manager);
unsigned int getFTWidth( FreetypeManager * manager);
	

#ifdef __cplusplus
}
#endif

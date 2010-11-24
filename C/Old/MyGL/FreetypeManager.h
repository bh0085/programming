// insert openGl if it is not yet opened...
#ifndef OPENGL_H
#define OPENGL_H
#include <OpenGL/OpenGL.h>
#endif

//and open up freetype!
#ifndef FREETYPE_H
#define FREETYPE_H
#include <ft2build.h>
#endif

#include FT_FREETYPE_H



#ifdef __cplusplus
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
unsigned int widthOfCharacter( FreetypeManager * manager, unsigned char whichChar);
void killFreetypeManager(FreetypeManager * manager);
unsigned int getFTHeight( FreetypeManager * manager);
unsigned int getFTWidth( FreetypeManager * manager);
	

#ifdef __cplusplus
}
#endif

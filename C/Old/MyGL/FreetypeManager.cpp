/*
 *  FreeTypeManager.cpp
 *  MyGL
 *
 *  Created by Benjamin Holmes on 6/28/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "FreetypeManager.h"
#include <string>
using namespace std;

class FreetypeManager  {
private:
	FT_Library    library;	
	FT_Face       face;
	FT_GlyphSlot  slot;
	FT_Error      error;
	unsigned int fontSize;
	unsigned int  WIDTH;
	unsigned int  HEIGHT;
	unsigned int widths[128];

	
public:
	FreetypeManager(string font_name="Arial.ttf", int size=10){
		WIDTH = 80;
		HEIGHT = 120;
		string filename = "/Library/fonts/";
		filename+=font_name;
		fontSize = size;

		error = FT_Init_FreeType( &library );              /* initialize library */	
		error = FT_New_Face( library, filename.c_str(), 0, &face ); /* create face object */
		error = FT_Set_Char_Size( face, fontSize * 64, 0,100, 0 ); 	

		slot = face->glyph;
		
		for(unsigned char i = 32 ; i < 128 ; i++){
			error = FT_Load_Char( face, i, FT_LOAD_RENDER );
			if(i == ' '){
				widths[i]= fontSize*4/5;
				continue;
			} else {
				widths[i] = slot->bitmap.width +slot->bitmap_left;	
				continue;
			}
		}
	}
	
	//make and destroy methods meant to be called in C...

	unsigned int height(){
		return HEIGHT;
	}
	unsigned int width(){
		return WIDTH;
	}
	
	unsigned char * getFontPixels( unsigned char whichChar)
	{
		slot = face->glyph;
		
		/* load glyph image into the slot (erase previous one) */
		error = FT_Load_Char( face, whichChar, FT_LOAD_RENDER );
		unsigned char * bitmap = createBMP( &slot->bitmap, slot->bitmap_top,slot->bitmap_left);
		return bitmap;
	}

	unsigned char * createBMP( FT_Bitmap*  bitmap, int bmpTop, int bmpLeft)
	{
		FT_Int  i, j;
		unsigned char * image;
		image = (unsigned char *)calloc(sizeof(char),HEIGHT * WIDTH);

		for( i = 0 ; i < bitmap->width ; i++){
			for( j = 0 ; j < bitmap->rows ; j++){
				if((j*WIDTH + i) > WIDTH *HEIGHT){continue;}
				image[(20+ bmpTop - bitmap->rows -1 + j) *WIDTH + (i +bmpLeft ) ] |= bitmap->buffer[(bitmap->rows-1 - j)*bitmap->width + i];
			}
		}
		return image;
	}
	
	unsigned int widthOfCharacter(  unsigned char whichChar){
		return widths[whichChar];
	}
	
	
	~FreetypeManager(){
		FT_Done_Face    ( face );
		FT_Done_FreeType( library );
	}
	

};

extern "C" unsigned int widthOfCharacter( FreetypeManager * manager, unsigned char whichChar){
	return manager->widthOfCharacter(whichChar);
}
 
extern "C" unsigned int getFTHeight( FreetypeManager * manager){
	return manager->height();
}
extern "C" unsigned int getFTWidth( FreetypeManager * manager){
	return manager->width();
}
extern "C" FreetypeManager * makeFreetypeManager(const char fontName[], int size){
	string fontString= fontName;
	return new FreetypeManager(fontString, size);
}
extern "C" unsigned char * getFontPixels( FreetypeManager * manager, unsigned char whichChar){
	return manager->getFontPixels(whichChar);
}
extern "C" void killFreetypeManager(FreetypeManager * manager){
	delete manager;
}


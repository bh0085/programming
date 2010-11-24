#ifndef FREE_NEHE_H
#define FREE_NEHE_H

//FreeType Headers
#include <ft2build.h>
#include <freetype/freetype.h>
#include <freetype/ftglyph.h>
#include <freetype/ftoutln.h>
#include <freetype/fttrigon.h>

//OpenGL Headers 
#include <OpenGL/OpenGL.h>
#include <OpenGL/glu.h>

//Some STL headers
#include <vector>
#include <string>

//Using the STL exception library increases the
//chances that someone else using our code will corretly
//catch any exceptions that we throw.
#include <stdexcept>


//MSVC will spit out all sorts of useless warnings if
//you create vectors of strings, this pragma gets rid of them.
#pragma warning(disable: 4786) 


///Wrap everything in a namespace, that we can use common
///function names like "print" without worrying about
///overlapping with anyone else's code.
namespace freetype_mod {

//Inside of this namespace, give ourselves the ability
//to write just "vector" instead of "std::vector"
using std::vector;

//Ditto for string.
using std::string;

///This is the datastructure that I'm using to store everything I need
///to render a character glyph in opengl.  
struct char_data {
	int w,h;
	int advance;
	int left;
	int move_up;
	unsigned char * data;

	char_data(char ch, FT_Face face) {
	
		// Load The Glyph For Our Character.
		if(FT_Load_Glyph( face, FT_Get_Char_Index( face, ch ), FT_LOAD_DEFAULT ))
			throw std::runtime_error("FT_Load_Glyph failed");

		// Move The Face's Glyph Into A Glyph Object.
		FT_Glyph glyph;
		if(FT_Get_Glyph( face->glyph, &glyph ))
			throw std::runtime_error("FT_Get_Glyph failed");

		// Convert The Glyph To A Bitmap.
		FT_Glyph_To_Bitmap( &glyph, ft_render_mode_normal, 0, 1 );
		FT_BitmapGlyph bitmap_glyph = (FT_BitmapGlyph)glyph;

		// This Reference Will Make Accessing The Bitmap Easier.
		FT_Bitmap& bitmap=bitmap_glyph->bitmap;

		advance=face->glyph->advance.x >> 6;
		left=bitmap_glyph->left;
		w=bitmap.width;
		h=bitmap.rows;
		move_up=bitmap_glyph->top-bitmap.rows;

		
		data = new unsigned char[2*w*h];
		for(int x=0;x<w;x++) for(int y=0;y<h;y++) {
			const int my=h-1-y;
			data[2*(x+w*my)]=255;
			data[2*(x+w*my)+1]=bitmap.buffer[x+w*y];
		}
	}

	~char_data() { delete [] data; }
};

//This holds all of the information related to any
//freetype font that we want to create.  
struct font_data {
	char_data * chars[128];

	float h;
	
	//The init function will create a font of
	//of the height h from the file fname.
	void init(const char * fname, unsigned int h);

	//Free all the resources assosiated with the font.
	void clean();
};

//The flagship function of the library - this thing will print
//out text at the current raster position using the font ft_font.
//The current modelview matrix will also be applied to the text. 
void print(const font_data &ft_font, const char *fmt, ...) ;

}

#endif
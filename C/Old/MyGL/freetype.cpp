/*
	A quick and simple opengl font library that uses GNU freetype2, written
	and distributed as part of a tutorial for nehe.gamedev.net.
	Sven Olsen, 2003

	Update (02/04) - I've hacked this version of the tutorial code to use 
	glDrawPixels instead of textured polygons.  
	
	Rotating and scaling text is now harder (you might be 
	able to do some scaling with glPixelZoom, but you'd need to actually alter the glyph
	bitmaps directly to achieve a rotation).

	It's also worth noting that in this implementation your text is not going to respond
	nicely with gl's picking functions.

	On the plus side, the new print function behaves just like the old lesson13 glPrintf,
	which could be a real benifit for people trying to convert oldler code.
	The library's implementation has also been simplified by the fact that we are no longer
	messing around with display lists or matrices.  I've also gotten a report that
	the displaylist's texture's can get messed up by the use of multitexturing, and
	this implentation should dodge those sorts of problems.
*/


//Include our header file.
#include "freetype.h"

namespace freetype_mod {


void font_data::init(const char * fname, unsigned int h) {
	this->h=h;

	FT_Library library;

	if (FT_Init_FreeType( &library )) 
		throw std::runtime_error("FT_Init_FreeType failed");

	FT_Face face;

	//This is where we load in the font information from the file.
	//Of all the places where the code might die, this is the most likely,
	//as FT_New_Face will die if the font file does not exist or is somehow broken.
	if (FT_New_Face( library, fname, 0, &face )) 
		throw std::runtime_error("FT_New_Face failed (there is probably a problem with your font file)");

	//For some twisted reason, Freetype measures font size
	//in terms of 1/64ths of pixels.  Thus, to make a font
	//h pixels high, we need to request a size of h*64.
	//(h << 6 is just a prettier way of writting h*64)
	FT_Set_Char_Size( face, h << 6, h << 6, 96, 96);

	for(int i=0;i<128;i++) chars[i]=new char_data(i,face);

	//We don't need the face information now that the display
	//lists have been created, so we free the assosiated resources.
	FT_Done_Face(face);

	FT_Done_FreeType(library);

}

void font_data::clean() {
	for(int i=0;i<128;i++) delete chars[i];
}

///So while glRasterPos won't let us set the raster position using
///window coordinates, these hacky functions will let us move the current raster
///position a given delta x or y.
inline void move_raster_x(int x) {
	glBitmap(0,0,0,0,x,0,NULL); }
inline void move_raster_y(int y) {
	glBitmap(0,0,0,0,0,y,NULL); }


///Much like Nehe's glPrint function, but modified to work
///with freetype fonts.
///For this hack, I've taken out the newline processing, though it's easy to
///see how you could use the move_raster() functions to put newline processing back
///in.
void print(const font_data &ft_font, const char *fmt, ...)  {
	
//	float h=ft_font.h/.63f;						//We make the height about 1.5* that of


	char		text[256];								// Holds Our String
	va_list		ap;										// Pointer To List Of Arguments

	if (fmt == NULL)									// If There's No Text
		*text=0;											// Do Nothing

	else {
	va_start(ap, fmt);									// Parses The String For Variables
	    vsprintf(text, fmt, ap);						// And Converts Symbols To Actual Numbers
	va_end(ap);											// Results Are Stored In Text
	}

	glPushAttrib(GL_CURRENT_BIT | GL_PIXEL_MODE_BIT | GL_ENABLE_BIT);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glDisable(GL_LIGHTING);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	

	//we'll be nice people and save the old pixel unpack alignment-
	//while setting the unpack allignment to one couldn't possibly
	//hurt anyone else's pixel drawing, it might slow it down.
	GLint old_unpack;
	glGetIntegerv(GL_UNPACK_ALIGNMENT,&old_unpack); 
	glPixelStorei(GL_UNPACK_ALIGNMENT ,1);

	float color[4];
	glGetFloatv(GL_CURRENT_COLOR,color);

	glPixelTransferf(GL_RED_SCALE,color[0]);
	glPixelTransferf(GL_GREEN_SCALE,color[1]);
	glPixelTransferf(GL_BLUE_SCALE,color[2]);
	glPixelTransferf(GL_ALPHA_SCALE,color[3]);

	for(int i=0;text[i];i++) {
		const char_data &cdata=*ft_font.chars[text[i]];

		move_raster_x(cdata.left);
		move_raster_y(cdata.move_up);

		glDrawPixels(cdata.w,cdata.h,GL_LUMINANCE_ALPHA,GL_UNSIGNED_BYTE,cdata.data);

		move_raster_y(-cdata.move_up);
		move_raster_x(cdata.advance- cdata.left);

	}

	glPixelStorei(GL_UNPACK_ALIGNMENT ,old_unpack);
	glPopAttrib();
}

}

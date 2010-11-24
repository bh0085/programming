


#include <ft2build.h>  
#include FT_FREETYPE_H 


FT_ERROR error;
FT_Library library; /* handle to library */  
FT_Face face; /* handle to face object */  
error = FT_Init_FreeType( &library ); 
if ( error != 0 ) { printf("..."); } 
error = FT_New_Face( library, "/usr/share/fonts/truetype/arial.ttf", 0, &face ); 
if ( error == FT_Err_Unknown_File_Format ) { 
	printf("... the font file could be opened and read, but it appears ... that its font format is unsupported"); 
} else if ( error ) { 
	printf("... another error code means that the font file could not ... be opened or read, or simply that it is broken...";	
		   } 
		   
		   error = FT_Set_Char_Size( 
									face, /* handle to face object */  
									0, /* char_width in 1/64th of points */  
									16*64, /* char_height in 1/64th of points */  
									300, /* horizontal device resolution */  
									300 ); /* vertical device resolution */ 
		   FT_GlyphSlot slot = face->glyph;
	/* a small shortcut */  
		   int pen_x, pen_y, n;
		   
		    pen_x = 300;
		    pen_y = 200;
		   for (  n = 0; n < num_chars; n++ ) {
		   FT_UInt glyph_index;
	/* retrieve glyph index from character code */  
		   glyph_index = FT_Get_Char_Index( face, text[n] );
	/* load glyph image into the slot (erase previous one) */  
		   error = FT_Load_Glyph( face, glyph_index, FT_LOAD_DEFAULT );
		   if ( error ) printf("error at load glyph");
	/* ignore errors */  /* convert to an anti-aliased bitmap */  
		   error = FT_Render_Glyph( face->glyph, FT_RENDER_MODE_NORMAL );
		   if ( error ) printf("error at render glyph");
	/* now, draw to our target surface */ 
		   //my_draw_bitmap( &slot->bitmap, pen_x + slot->bitmap_left, pen_y - slot->bitmap_top ); 
	/* increment pen position */  
		   pen_x += slot->advance.x >> 6;
		   pen_y += slot->advance.y >> 6;
	/* not useful for now */  
		   } 
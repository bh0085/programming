/* example1.c                                                      */
/*                                                                 */
/* This small program shows how to print a rotated string with the */
/* FreeType 2 library.                                             */


#include "MyFreetype.h"


#define WIDTH   80
#define HEIGHT  120


/* origin is the upper left corner */


/* Replace this function with something useful. */

int ftHeight(){
	return HEIGHT;
}
int ftWidth(){
	return WIDTH;
}



unsigned int checkWidth(unsigned char whichChar)
{
	FT_Library    library;
	FT_Face       face;
	
	FT_GlyphSlot  slot;
	FT_Error      error;
	
	
	int fontPtSize = 50;
	
	char * filename = "/Library/fonts/Courier New.ttf";
	
	error = FT_Init_FreeType( &library );              /* initialize library */	
	error = FT_New_Face( library, filename, 0, &face ); /* create face object */
	
	/* use 50pt at 100dpi */
	error = FT_Set_Char_Size( face, fontPtSize * 64, 0,
							 100, 0 );                /* set character size */
	
	slot = face->glyph;
	
	error = FT_Load_Char( face, whichChar, FT_LOAD_RENDER );
	
	if(whichChar == ' '){return fontPtSize*4/5;}
	
	return slot->bitmap.width +slot->bitmap_left;
	
}


unsigned char * createBMP( FT_Bitmap*  bitmap, int bmpTop, int bmpLeft)
{
	FT_Int  i, j;
	//FT_Int  x_max = x + bitmap->width;
	//FT_Int  y_max = y + bitmap->rows;
	unsigned char * image;//[HEIGHT][WIDTH];
		
	image = calloc(sizeof(unsigned char), HEIGHT *WIDTH);
	/* original method for writing bitmap to a new matrix...
	for ( i = x, p = 0; i < x_max; i++, p++ )
	{
		for ( j = y, q = 0; j < y_max; j++, q++ )
		{
			if ( i >= WIDTH || j >= HEIGHT )
				continue;
			
			image[j *WIDTH + i] |= bitmap->buffer[q * bitmap->width + p];
		}
	}
	*/
	
	//assumes that the bitmap is smaller than the image
	for( i = 0 ; i < bitmap->width ; i++){
		for( j = 0 ; j < bitmap->rows ; j++){
			if((j*WIDTH + i) > WIDTH *HEIGHT){continue;}
			image[(20+ bmpTop - bitmap->rows -1 + j) *WIDTH + (i + bmpLeft) ] |= bitmap->buffer[(bitmap->rows-1 - j)*bitmap->width + i];
		}
	}
	return image;
}

/*
void
show_image( void )
{
	int  i, j;
	
	
	for ( i = 0; i < HEIGHT; i++ )
	{
		for ( j = 0; j < WIDTH; j++ )
			putchar( image[i][j] == 0 ? ' '
					: image[i][j] < 128 ? '+'
					: '*' );
		putchar( '\n' );
	}
}
*/

unsigned char * getFontPixels( unsigned char whichChar)
{
	FT_Library    library;
	FT_Face       face;
	
	FT_GlyphSlot  slot;
	FT_Error      error;
	

	char * filename = "/Library/fonts/Courier New.ttf";

	error = FT_Init_FreeType( &library );              /* initialize library */	
	error = FT_New_Face( library, filename, 0, &face ); /* create face object */
	
	/* use 50pt at 100dpi */
	error = FT_Set_Char_Size( face, 50 * 64, 0,
							 100, 0 );                /* set character size */
	
	slot = face->glyph;

	/* load glyph image into the slot (erase previous one) */
	error = FT_Load_Char( face, whichChar, FT_LOAD_RENDER );

		
	//slot->bitmap_
	unsigned char * bitmap = createBMP( &slot->bitmap, slot->bitmap_top,slot->bitmap_left);
	
	
	FT_Done_Face    ( face );
	FT_Done_FreeType( library );
	
	
	return bitmap;
	
}

unsigned char * initFTAndCreateImage()
{
	FT_Library    library;
	FT_Face       face;
	
	FT_GlyphSlot  slot;
	FT_Matrix     matrix;                 /* transformation matrix */
	//FT_UInt       glyph_index;
	FT_Vector     pen;                    /* untransformed origin  */
	FT_Error      error;
	
	char*         filename;
	char*         text;
	
	double        angle;
	int           target_height;
	int           n, num_chars;
	
	
	filename = "/Library/fonts/Arial.ttf";
	text = "W";
	
	//filename      = argv[1];                           /* first argument     */
	//text          = argv[2];                           /* second argument    */
	num_chars     = strlen( text );
	angle         = 0*( 25.0 / 360 ) * 3.14159 * 2;      /* use 25 degrees     */
	target_height = HEIGHT;
	
	error = FT_Init_FreeType( &library );              /* initialize library */
	/* error handling omitted */
	
	error = FT_New_Face( library, filename, 0, &face ); /* create face object */
	/* error handling omitted */
	
	/* use 50pt at 100dpi */
	error = FT_Set_Char_Size( face, 50 * 64, 0,
							 100, 0 );                /* set character size */
	/* error handling omitted */
	
	slot = face->glyph;
	
	/* set up matrix */
	matrix.xx = (FT_Fixed)( cos( angle ) * 0x10000L );
	matrix.xy = (FT_Fixed)(-sin( angle ) * 0x10000L );
	matrix.yx = (FT_Fixed)( sin( angle ) * 0x10000L );
	matrix.yy = (FT_Fixed)( cos( angle ) * 0x10000L );
	
	/* the pen position in 26.6 cartesian space coordinates; */
	/* start at (300,200) relative to the upper left corner  */
	pen.x = 5 * 64;
	pen.y = ( target_height - 250 ) * 64;
	
	for ( n = 0; n < num_chars; n++ )
	{
		/* set transformation */
		FT_Set_Transform( face, &matrix, &pen );
		
		/* load glyph image into the slot (erase previous one) */
		error = FT_Load_Char( face, 32+93, FT_LOAD_RENDER );
		if ( error )
			continue;                 /* ignore errors */
		
		/* now, draw to our target surface (convert position) */
		//createBMP( &slot->bitmap,
		//			slot->bitmap_left,
		//			target_height - slot->bitmap_top );
		
	
		
		/* increment pen position */
		pen.x += slot->advance.x;
		pen.y += slot->advance.y;
	}
	
	//show_image();
	
	FT_Done_Face    ( face );
	FT_Done_FreeType( library );
	
	return NULL;
}

/* EOF */

/*
 *  audiovis.h
 *  Shared_Memory
 *
 *  Created by Benjamin Holmes on 10/26/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define AUDIO_BUF_MAX_UNIT_SIZE (1024)
#define AUDIO_BUF_N_UNITS (10)
struct audiowindow {        /* Defines "structure" of shared memory */
	int last_read;
	int last_write;
	int buffer_unit_size;
	float buffers[AUDIO_BUF_N_UNITS * AUDIO_BUF_MAX_UNIT_SIZE];
};
typedef struct audiowindow AudioWin;
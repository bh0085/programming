#include <unistd.h>
#include <sys/mman.h>
#include <semaphore.h>
#include <stdio.h>

#include "audiovis.h"
int main (int argc, char * const argv[]) {
	AudioWin * rptr;
	
	/* Create shared memory object and set its size */
	int fd = shm_open("/memoryregion", O_CREAT | O_RDWR, S_IRUSR | S_IWUSR);
	if (fd == -1){printf("could not open memory...\n");}
	printf("size of struct: %i\n", sizeof(AudioWin));
	printf("file pointer: %i\n",fd);
	if (ftruncate(fd, sizeof( AudioWin)) == -1){printf("truncation error\n");}
	
	/* Map shared memory object */	
	rptr = mmap(NULL, sizeof(AudioWin),
				PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (rptr == MAP_FAILED){printf("failed");}
	
	rptr->last_read=-1;
	rptr->last_write=-1;
	rptr->buffer_unit_size = 10;
	printf("%i",rptr->buffer_unit_size);
	shm_unlink("/memoryregion");
	
	/* Now we can refer to mapped region using fields of rptr;
	 for example, rptr->len */
	return 0;
}
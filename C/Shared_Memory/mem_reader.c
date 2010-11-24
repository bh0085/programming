#include <unistd.h>
#include <sys/mman.h>
#include <semaphore.h>
#include <stdio.h>
#include <math.h>

#include "audiovis.h"
int main (int argc, char * const argv[]) {
	AudioWin * rptr;
	int fd;
	
	/* Create shared memory object and set its size */	
	fd = shm_open("/memoryregion", O_RDWR, S_IRUSR | S_IWUSR);
	if (fd == -1){
		printf("could not open memory...");
	}

	
	printf("Running Reader\n");
	printf("%i\n",sizeof(struct audiowindow));
	
	rptr = mmap(NULL, sizeof(struct audiowindow),
				PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (rptr == MAP_FAILED){
		printf("failed");
	}

	printf("%f",rptr->buffers[0]);
	for (int i = 0; i < 100 ; i++){
		usleep(10000);
		int next_read = ( (rptr->last_read) + 1 ) % rptr->buffer_n_units;
		printf("%f\n",rptr->buffers[next_read]);
		rptr->buffers[next_read] = 5.0;
		rptr->last_read = next_read;
		
	}
	

	return 0;
}
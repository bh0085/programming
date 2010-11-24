#include <iostream>
#include <fstream>
#include <boost/any.hpp>
#include <boost/regex.hpp>  

using namespace std;

// Small usage of the regex library
int main (int argc, char * const argv[]) {


	
	chdir("/Users/bh0085/Programming/Cocoa/NeuralNet3/out");
	FILE *fp;
	float floatValue[100] ;
	for(int i = 0 ; i < 100; i ++){
		floatValue[i]=(((float)rand())/RAND_MAX - .5)* 2 * 100;
	}
	
	char fn2[] = "test2"; 
	if((fp=fopen(fn2, "wb"))==NULL) {
		printf("Cannot open file.\n");
	}
	
	if(fwrite(floatValue, sizeof(float), 100, fp) != 100)
		printf("File read error.");
	fclose(fp);
	

	for(int i=0; i<100; i++)
		printf("%f ", floatValue[i]);
	return 0;
} 
#include <iostream>
#include "CA.h"
int main (int argc, char * const argv[]) {
    // insert code here...
	CA * ca = new CA(10,10);
	srand ( (unsigned)time ( NULL ) );
	ca->initRandom();
	ca->Display();
    std::cout << "Displaying, Hello, World!\n";
    return 0;
}

#include <iostream>


#ifndef HEADERS_LOADED
#define HEADERS_LOADED
#include "Shared_Headers.h"
#endif

#ifndef ENVIRONMENT
#define ENVIRONMENT
#include "Environment.h"
#endif

#ifndef VACUUM
#define VACUUM
#include "Vacuum.h"
#endif



#define SIMULATION_STEPS 100;

int main (int argc, char * const argv[]) {
	srand ( (unsigned)time ( NULL ) );
	
	Environment * e = new Environment;
	
	//Accepts user input and initializes the environment
	cout<<"Shall we initialize an entirely dirty world? \n(y/n):";
	char allDirty;
	cin >> allDirty;
	
	Vacuum * v = new Vacuum(e);	
	char vacuumIsDirty;
	cout<<"\nIs our vacuum dirty? (Dirty vacuums try their best but dirty squares as they leave) \n(y/n):";
	cin>>vacuumIsDirty;
	if(vacuumIsDirty == 'y'){
		v->setDirty();
	}
	char vacuumIsLazy;
	cout<<"\nIs our vacuum lazy? (Lazy vacuums only travel to squares that they think are clean) \n(y/n):";
	cin>>vacuumIsLazy;
	if(vacuumIsLazy == 'y'){
		v->setLazy();
	}	
	unsigned int n;
	cout<<"\nHow many steps will we allow the vacuum? \n(Enter a positive Integer):";
	cin >>n;
	cout<<"Your choice: "<<n<<" steps.\n";
	
	char log;
	cout<<"\nShall we log our vacuum's position?\n(y/n)";
	cin>>log;
	bool logOutput;
	if(log == 'y') logOutput = true; else logOutput = false;
	
	if(allDirty == 'y'){
		e->init_Dirty_Square_World_Of_Size(5, 5);
	} else {
		e->init_Mixed_Square_World_Of_Size(5, 5);
	}
	
	//Now makes a vacuum with a simple program -- if the square is clean, clean
	//otherwise, get a list of squares that are adjacent to its position
	
	//And tell it to take "n" steps.
	for(int i = 0 ; i < n ; i++){
		v->act();
		if(logOutput) v->print_XY();
	}
	
	//Now print out the performance measure.
	cout<<"\nThe percentage of dirty squares cleaned in "<< n <<" time steps was:\n";
	printf("%f",e->getPercentCleaned());
	
	cout<<"\n\n"<<e->getNumberCleaned()<<" squares were cleaned in "<<n<<" iterations\n"
		<<"giving a per iteration efficiency of "<<(((float)(e->getNumberCleaned()))/n)<<"sq/itr.\n\n";
	
    return 0;
}

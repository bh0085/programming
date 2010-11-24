#include "NeuralNet.h"
#include "NeuralUnits.h"
#include <iostream>
#include <vector>
#include <math.h>
#include <string>
#include <sstream>
#include <OpenGL/OpenGL.h> 
#import "NN3GLView.h"
#include <sys/time.h>


using namespace std;



extern "C" void findIdentity(){
	float squaredErrors[8];
	
	timeval t1;
	gettimeofday(&t1, NULL);
	long millis = (t1.tv_sec * 1000) + (t1.tv_usec / 1000);
	
	
	NNGLColor3f(0, 1, 1, 1);
	NNGLColor3f(1, 1, 0,0);
	NNGLColorRed(1);
	NNGLColorPurple(2);
	NNGLColorOrange(3);
	srand(time(NULL));
	//create a dummy set of neurons
	int nHidden = 3;
	int nIn = 8;
	int nOut = 8;
	vector <SigmoidUnit*> hiddens;
	vector <InputUnit*> inputs;
	vector <SigmoidUnit*> outputs;
	
	for(int j = 0 ; j < nIn ; j++){
		inputs.push_back(new InputUnit);
	};
	for(int j = 0 ; j < nHidden ; j++){
		hiddens.push_back(new SigmoidUnit);
		for(int i = 0 ; i < nIn ; i++ ){
			inputs[i]->connectForward(hiddens[j]);
		};
		hiddens[j]->randomWeights(.2);
		hiddens[j]->setAlpha(.01);
	};
	for(int j = 0 ; j < nOut ; j++){
		outputs.push_back(new SigmoidUnit);
		for(int i = 0 ; i < nHidden ; i++){
			hiddens[i]->connectForward(outputs[j]);
		}
		outputs[j]->randomWeights(.2);
		outputs[j]->setAlpha(0);

	};
	int lastItr = 1000
	;
	for(int itr=0 ; itr<lastItr ; itr++){
		for(int i = 0 ; i < 8; i++){
			squaredErrors[i] = 0.0;
		}
		for(int i = 0 ; i < 8 ; i ++){
			
			for(int j = 0 ; j < 8 ; j ++){
				if( j != i ){
					inputs[j]->setValue(.1);
				} else {
					inputs[j]->setValue(.9);
				};
			};
			for(int j = 0; j < nHidden ; j++){
				hiddens[j]->compute();
				//if(i == 0 || i == 1 || i == 2){NNGLPlot3f(i+1, ((float)itr)/lastItr,hiddens[j]->query(),0);}	
			}
			for(int j = 0; j < nOut ; j++){
				outputs[j]->compute();
				float e = inputs[j]->query();
				outputs[j]->trainingDelta(e);
				

			};
			for(int j = 0 ; j < nOut ; j++){
				squaredErrors[j]+= pow(outputs[j]->getDelta(),2);
			}
			for(int j = 0 ; j < nHidden ; j++){
				hiddens[j]->computeDelta();
			};
			for(int j = 0 ; j < nHidden ; j++){
				hiddens[j]->computeWeights();	
			}
			for(int j = 0 ; j < nOut; j++){
				if(j == 0){
				for(int m = 0 ; m < nHidden ; m++){
					//NNGLPlot3f(0, ((float)itr)/lastItr,outputs[j]->getWeight(m), 0);
				}
				}
				//NNGLPlot3f(0, ((float)itr*8 +i)/lastItr/8,outputs[j]->getDelta(), 0);
				
				outputs[j]->computeWeights();
				
				NNGLPlot3f(0, ((float)itr*8 + i )/8/lastItr,outputs[j]->getWeight(0), 0);
				
			}
			if(true
				){
			if(itr == lastItr -1){	
				printf("\n");
				for(int j = 0 ; j < nOut ; j++){
					printf("%i: %.2f .. " ,j,outputs[j]->query());

				};
			}
			}
		};
		for(int i = 0 ;i < 8 ; i++){
		NNGLPlot3f(1, ((float)itr )/lastItr,squaredErrors[i]* 10, 0);
		}

			
		
	};
	//printf("\n\n");

	NNGLAxis2f(0.0,0.0);
	NNGLFlush();
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	
	
	timeval t2;
	gettimeofday(&t2, NULL);
	long millis2 = (t2.tv_sec * 1000) + (t2.tv_usec / 1000);
	long mElapsed = millis2 - millis;
	printf("TIME   \n \n %i",mElapsed);
	

	
};
		
	



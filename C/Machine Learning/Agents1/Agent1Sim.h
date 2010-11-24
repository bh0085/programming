#ifndef AGENT1SIM_H
#define AGENT1SIM_H


#ifdef __cplusplus
#include "Box2d.h"
#include "GLISim.h"
#include "bgSkeleton.h"
#include "bgActor.h"
#include "GeneBrain.h"

class Agent1Sim: public GLISim{
private:
	b2World * world;
	vector <bgActor *> actors;
	vector <GeneBrain *> brains;
	bgSkeleton * skeleton;
	int simSteps;
	int nSkels;
public:
	Agent1Sim();
	virtual ~Agent1Sim();
	virtual void initialize();	
	virtual void step();
	virtual void reset();
	virtual void draw();
};
#else
typedef struct Agent1Sim Agent1Sim;
#endif

#ifdef __cplusplus
extern "C" {
#endif
	//The only C method that GLISim subclasses require is the "make" method...
	//The rest is taken care of in the virtualized class methods.
	Agent1Sim * A1MakeSimulation();
#ifdef __cplusplus
}
#endif
#endif
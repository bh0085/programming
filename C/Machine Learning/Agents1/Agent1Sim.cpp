#include "Agent1Sim.h"
#include "OpenGL/OpenGL.h"
#include "GLIDL.h"
#include "Gene.h"
#include "bgSkeleton.h"
#include "Box2D.h"
#include "bgBone.h"
#include "Algorithms/SIM_GA.h"
#include "skelSpec.h"
#include "iostream"
#include "GeneBrain.h"
#include "BrainScript.h"

Agent1Sim::Agent1Sim(){}
Agent1Sim::~Agent1Sim(){
	
}


skelSpec * makeSkelSpec(Gene * skeloProto){
	
	float max_bone_length = 20;
	unsigned nbits_bones = 4;
	unsigned nbits_cxns = 1;
	unsigned nbits_motors = 1;
	unsigned nbits_length = 4;
	
	proto->reset_ptr();
	unsigned nBones = proto->nBitIntAtPtr(nbits_bones);
	skelSpec * skel = new skelSpec(nBones);
	for (int i = 0 ; i < nBones ; i++){
		skel->setCxn(i, proto->nBitIntAtPtr(nbits_cxns));
		skel->setMotor(i,proto->nBitIntAtPtr(nbits_motors));
		float length = proto->nBitIntAtPtr(nbits_length) + 1;
		length = max_bone_length * length/proto->nBitIntMax(nbits_length);
		skel->setLength(i,length);
	}
	return skel;
}
brainSpec * makeBrainSpec(Gene * brainProto){
	float 
}

void readSkelSpec(skelSpec * spec, bgSkeleton * skeleton,GeneBrain * brain){
	for(int i = 0 ; i < spec->getNumBones() ; i++){
		unsigned cxn = spec->getCxn(i);
		unsigned motor = spec->getMotor(i);
		float length = spec->getLength(i);
		
		skeleton->addBone(cxn,length);
		
		switch (motor){
			case 0:
				brain->addScript(newFreezeScript());
				break;
			default:
				break;
		}

		//skeleton->setJointProgram(i, motor);
	}	
}

void Agent1Sim::initialize(){
	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(100.0f,100.0f);	
	b2Vec2 gravity(0.0f, -100.0f);
	bool doSleep = true;
	world = new b2World(worldAABB, gravity, doSleep);	
	
	Gene * gene;
	simSteps = 0;
	nSkels = 2;
	int popSize = nSkels;
	//run a random genetic algorithm to get body types
	int m = 0;
	SIM_GA * simga = new SIM_GA();
	int geneLength = 1000;
	simga->init(popSize, geneLength);
	for(int itr = 0 ; itr < 20 ; itr++){
		for (int i = 0 ; i < popSize ; i++){
			gene = simga->getGene(i);
			unsigned intatbit = gene->nBitIntAtBit(4,0);
			simga->setFitness(i, intatbit);
		}
		gene = simga->getGene(0);
		simga->select(0);
	}	
	
	for ( int i = 0 ; i < popSize ; i++){
		skeleton = new bgSkeleton(world);
		GeneBrain * brain = new GeneBrain(skeleton);
		skeleton->setOrigin(rand() % 100 -50, 20.0); 
		gene = simga->getGene(i);
		skelSpec * spec = makeSkelSpec(gene);
		readSkelSpec(spec, skeleton, brain);
		delete spec;
		actors.push_back(skeleton);
		brain->addScript(newFreezeScript());
		brains.push_back(brain);
		
	}

	
	bgActor * ground = new bgActor(world);
	ground->makeStaticGroundInWorld(100,5);
	ground->setAngle(.1);

	actors.push_back(ground);
}
void Agent1Sim::step(){
	simSteps++;
	// Prepare for simulation. Typically we use a time step of 1/60 of a
	// second (60Hz) and 10 iterations. This provides a high quality simulation
	// in most game scenarios.
	float32 timeStep = 1.0f / 60.0f;
	int32 iterations = 10;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	for(int i = 0 ; i < nSkels ; i++){
		
		brains[i]->timeStep();
		((bgSkeleton *)actors[i])->timeStep();
	}
	world->Step(timeStep, iterations);
}
void Agent1Sim::reset(){
	
}
void Agent1Sim::draw(){
	window(0);
	glClearColor(0,0,0,0);
	glColor3d(1, 1, 1);
	float xBounds[2] = {-50,50};
	float yBounds[2] = {-50,50};
	float bounds[6] = {xBounds[0],xBounds[1],yBounds[0],yBounds[1],-100,100};
	GLIDLSetViewBoundsWithMargin(bounds,0.0);	
	GLIDLClear();
	
	GLIDLLabelAxes();
	for (int i = 0 ; i < actors.size() ; i++){
		actors[i]->draw();
	}
	GLIDLFlushBuffer();
	
	
}
extern Agent1Sim * A1MakeSimulation(){
	return new Agent1Sim();

}

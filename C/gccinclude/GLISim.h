#ifndef GLISIM_H
#define GLISIM_H

#ifdef __cplusplus
//Define implementable C++ class.
class GLISim{
public:
	
	GLISim();
	//Be sure to override this destructor...
	virtual ~GLISim();
	
	//Override all of these...
	 virtual void initialize();
	 virtual void step();
	 virtual void reset();
	 virtual void draw();
	
};
#else
//Define a struct for Obj-C interfacing.
typedef struct GLISim GLISim;
#endif

#ifdef __cplusplus
extern "C" {
#endif
	//Allocates a new GLISim
	 GLISim * GLISimMakeSimulation();
	//Initializes a GLISim pointed to by sim.
	 void GLISimInitSimulation(GLISim * sim);
	
	//Destroys the GLISim pointed to by sim.
		//Note that I'm not sure if this is inheritance safe right now...
		//Do i need to cast to the correct class before deleting?
		//Instead, I can define the destructor to be virtual.
	 void GLISimDestroy(GLISim * sim);
	//Commands the GLISim pointed to by sim to step!.
	void GLISimStep(GLISim * sim);
	void GLISimDraw(GLISim * sim);
#ifdef __cplusplus
}
#endif

#endif
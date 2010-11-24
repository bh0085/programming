/***************************************************************

  Particles.h

  Philipp Crocoll from www.codecolony.de

  Defines the classes used for the CodeColony Particle Engine:

   - CCCParticle: Class to store/update a particle
   - CCCParticleSystem: Class to store/update/render a complete particle system 
						(including an emitter)

****************************************************************/

//Include files needed:
#include "camera.h"
#include "textures.h"


class CCCParticleSystem;


/*******************
CONSTANTS
*******************/
#define BILLBOARDING_NONE							0
#define BILLBOARDING_PERPTOVIEWDIR					1  //align particles perpendicular to view direction
#define BILLBOARDING_PERPTOVIEWDIR_BUTVERTICAL		2  //like PERPToViewDir, but Particles are vertically aligned

/*******************
CCCParticle
*******************/

class CCCParticle
{
private:
  //Position of the particle:  NOTE: This might be the global position or the local position (depending on the system's translating behavior)
	SF3dVector m_Position;
  //Moving the particle:
	//Particle's velocity:
	SF3dVector m_Velocity;
	//Particle's acceleration (per Sec):
	SF3dVector m_Acceleration;
  //Spinning the particle
	float	   m_fSpinAngle; //radian measure
	//Particle's spin speed:
	float	   m_fSpinSpeed;
  //Particle's spin acceleration:
	float      m_fSpinAcceleration;
  //Particle's alpha value (=transparency)
	float      m_fAlpha;
	float	   m_fAlphaChange;  //how much is the alpha value changed per sec?
  //Particle's color:
	SF3dVector m_Color;   //x=r, y=g, z=b
	SF3dVector m_ColorChange;  //how to change to color per sec
  //Particle's size:  (the use of this value is dependent of m_bUseTexture in the parent!)
	float	   m_fSize;
	float	   m_fSizeChange;	
  //Handling the lifetime:
	float	   m_fDieAge;	//At what "age" will the particle die?
	float	   m_fAge;		//Age of the particle (is updated 	
  //Needed to access the system's values:
	CCCParticleSystem * m_ParentSystem;
	
public:
	bool	   m_bIsAlive;  //Is the particle active or not? Must be visible for the System
	void Initialize(CCCParticleSystem * ParentSystem);
	void Update(float timePassed);	//called by UpdateSystem if particle is active
	void Render();  

};


/*******************
CCCParticleSystem
*******************/

class CCCParticleSystem
{
public:  //The values how to emit a particle must be public because the particle	
		 //must be able to access them in the creation function.
//*************************************
// EMISSION VALUES
//*************************************

	//Position of the emitter:
	SF3dVector		m_EmitterPosition;
	//How far may the particles be created from the emitter?
	SF3dVector		m_MaxCreationDeviation;  //3 positive values. Declares the possible distance from the emitter
											 // Distance can be between -m_MaxCreationDeviation.? and +m_MaxCreationDeviation.?
	//Which direction are the particles emitted to?
	SF3dVector		m_StandardEmitDirection;
	SF3dVector		m_MaxEmitDirectionDeviation; //Works like m_MaxCreationDeviation

	//Which speed do they have when they are emitted?
	//->Somewhere between these speeds:
	float			m_fMinEmitSpeed;
	float			m_fMaxEmitSpeed;

	//How fast do they spin when being emitted? Speed here is angle speed (radian measure) per sec
	float			m_fMinEmitSpinSpeed;
	float			m_fMaxEmitSpinSpeed;
	//Spinning acceleration:
	float			m_fMinSpinAcceleration;
	float			m_fMaxSpinAcceleration;

	//The acceleration vector always has the same direction (normally (0/-1/0) for gravity):
	SF3dVector		m_AccelerationDirection;
	//...but not the same amount:
	float			m_fMinAcceleration;
	float			m_fMaxAcceleration;
	
	//How translucent are the particles when they are created?
	float			m_fMinEmitAlpha;
	float			m_fMaxEmitAlpha;
	//How translucent are the particles when they have reached their dying age?
	float			m_fMinDieAlpha;
	float			m_fMaxDieAlpha;

	//How big are the particles when they are created / when they die
	float			m_fMinEmitSize;
	float			m_fMaxEmitSize;
	float			m_fMinDieSize;
	float			m_fMaxDieSize;


	//The same with the color:
	SF3dVector		m_MinEmitColor;
	SF3dVector		m_MaxEmitColor;
	SF3dVector		m_MinDieColor;
	SF3dVector		m_MaxDieColor;

//*************************************
// OTHER PARTICLE INFORMATION
//*************************************

	//How long shall the particles live? Somewhere (randomly) between:
	float			m_fMinDieAge;
	float			m_fMaxDieAge;

	bool			m_bRecreateWhenDied;  //Set it true so a particle will be recreate itsself as soon
										  //as it died

//*************************************
// RENDERING PROPERTIES
//*************************************	

	int				m_iBillboarding;    //See the constants above
	
	COGLTexture *	m_Texture;		    //Pointer to the texture (which is only an "alpha texture")	
	bool			m_bUseTexture;		//Set it false if you want to use GL_POINTS as particles!

	bool			m_bParticlesLeaveSystem;  //Switch it off if the particle's positions 
											 //shall be relative to the system's position (emitter position)
		
//*************************************
// STORING THE PARTICLES
//*************************************	
	//Particle array:
	CCCParticle    *m_pParticles;
	//Maximum number of particles (assigned when reserving mem for the particle array)
	int				m_iMaxParticles;
	//How many particles are currently in use?
	int				m_iParticlesInUse;
	//How many particles are created per second?
	//Note that this is an average value and if you set it too high, there won't be
	//dead particles that can be created unless the lifetime is very short and/or 
	//the array of particles (m_pParticles) is big 
	int				m_iParticlesCreatedPerSec;  //if bRecreateWhenDied is true, this is the ADDITIONAL number of created particles!
	float			m_fCreationVariance; //Set it 0 if the number of particles created per sec 
										 //should be the same each second. Otherwise use a positive value:
										 //Example: 1.0 affects that the NumParticlesCreatedPerSec varies 
										 //between m_iParticlesCreatedPerSec/2 and 1.5*m_iParticlesCreatedPerSec
//Do not set these values:
	float			m_fCurrentPointSize;  //required when rendering without particles
	//If Billboarding is set to NONE, the following vectors are (1,0,0) and (0,1,0).
	//If it is switched on, they are modified according to the viewdir/camera position (in Render of the System)
	SF3dVector		m_BillboardedX;
	SF3dVector		m_BillboardedY;			


//*************************************
// FUNCTIONS TO ASSIGN THESE MANY VECTORS MORE EASILY
//*************************************

	//Set the emitter position (you can pass a vector or x,y and z)
	void			SetEmitter(float x, float y, float z, float EmitterDeviationX,float EmitterDeviationY,float EmitterDeviationZ);
	void			SetEmitter(SF3dVector pos,SF3dVector dev);
	
	//Set the emission direction:
	void			SetEmissionDirection(float x, float y, float z,         //direction
										 float MaxDeviationX, float MaxDeviationY, float MaxDeviationZ);  //max deviation
	void			SetEmissionDirection(SF3dVector direction, SF3dVector Deviation);

	//Spin Speed
	void			SetSpinSpeed(float min, float max);
	
	//Acceleration
	void			SetAcceleration(float x, float y, float z, float Min, float Max);
	void			SetAcceleration(SF3dVector acc, float Min, float Max);

	//Color (at creation and dying age):
	void			SetCreationColor(float minr, float ming, float minb,
						   			 float maxr, float maxg, float maxb);
	void			SetCreationColor(SF3dVector min, SF3dVector max);

	void			SetDieColor		(float minr, float ming, float minb,
						   			 float maxr, float maxg, float maxb);
	void			SetDieColor		(SF3dVector min, SF3dVector max);
	//alpha:
	void			SetAlphaValues (float MinEmit, float MaxEmit, float MinDie, float MaxDie);
	//size:
	void			SetSizeValues (float EmitMin, float EmitMax, float DieMin, float DieMax);
		
//*************************************
// FUNCTIONS TO INITIALIZE THE SYSTEM
//*************************************

	CCCParticleSystem();								//constructor: sets default values

	bool			Initialize(int iNumParticles);		//reserves space for the particles

	bool			LoadTextureFromFile(char * Filename);

//*************************************
// FUNCTIONS TO UPDATE/RENDER THE SYSTEM
//*************************************

	void			UpdateSystem(float timePassed);	//updates all particles alive
	void			Render();							//renders all particles alive

};
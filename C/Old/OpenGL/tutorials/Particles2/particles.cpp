#include "particles.h"
#include "math.h"

//Generates a random float in the range [0;1]
#define RANDOM_FLOAT (((float)rand())/RAND_MAX)
/*************************************

METHODS OF CCCParticle class

**************************************/

void CCCParticle::Initialize(CCCParticleSystem *ParentSystem)
{

  //Calculate the age, the particle will live:
	m_fDieAge = ParentSystem->m_fMinDieAge + 
			     ((ParentSystem->m_fMaxDieAge - ParentSystem->m_fMinDieAge)*RANDOM_FLOAT);
	if (m_fDieAge == 0.0f) return;  //make sure there is no div 0
	m_fAge = 0.0f;

  //set the position:
	if (ParentSystem->m_bParticlesLeaveSystem)
	{
		//start with "global" coordinates (the current coordinates of the emitter position)
		m_Position = ParentSystem->m_EmitterPosition;
	}
	else
	{
		//In this case we assume a local coordinate system:
		m_Position = NULL_VECTOR;
	}
	//Add the deviation from the emitter position:
	m_Position.x += ParentSystem->m_MaxCreationDeviation.x*(RANDOM_FLOAT*2.0f-1.0f);
	m_Position.y += ParentSystem->m_MaxCreationDeviation.y*(RANDOM_FLOAT*2.0f-1.0f);
	m_Position.z += ParentSystem->m_MaxCreationDeviation.z*(RANDOM_FLOAT*2.0f-1.0f);
  //set the emission velocity
	m_Velocity.x = ParentSystem->m_StandardEmitDirection.x + ParentSystem->m_MaxEmitDirectionDeviation.x*(RANDOM_FLOAT*2.0f-1.0f);
	m_Velocity.y = ParentSystem->m_StandardEmitDirection.y + ParentSystem->m_MaxEmitDirectionDeviation.y*(RANDOM_FLOAT*2.0f-1.0f);
	m_Velocity.z = ParentSystem->m_StandardEmitDirection.z + ParentSystem->m_MaxEmitDirectionDeviation.z*(RANDOM_FLOAT*2.0f-1.0f);
	m_Velocity = m_Velocity * ((ParentSystem->m_fMinEmitSpeed + 
		                         (ParentSystem->m_fMaxEmitSpeed - ParentSystem->m_fMinEmitSpeed)*RANDOM_FLOAT));
  //set the acceleration vector:
	m_Acceleration = ParentSystem->m_AccelerationDirection* 
		              (ParentSystem->m_fMinAcceleration + (ParentSystem->m_fMaxAcceleration-ParentSystem->m_fMinAcceleration)*RANDOM_FLOAT);
  //set the alpha / color values:
	m_Color = ParentSystem->m_MinEmitColor + 
		   ((ParentSystem->m_MaxEmitColor-ParentSystem->m_MinEmitColor) * RANDOM_FLOAT);
	//calculate the "end color" (in order to get the ColorChange):
	SF3dVector EndColor = ParentSystem->m_MinDieColor + 
		   ((ParentSystem->m_MaxDieColor-ParentSystem->m_MinDieColor) * RANDOM_FLOAT);
	m_ColorChange = (EndColor-m_Color) / m_fDieAge;

	m_fAlpha = ParentSystem->m_fMinEmitAlpha 
		       + ((ParentSystem->m_fMaxEmitAlpha - ParentSystem->m_fMinEmitAlpha) * RANDOM_FLOAT);
	float fEndAlpha = ParentSystem->m_fMinDieAlpha 
		       + ((ParentSystem->m_fMaxDieAlpha - ParentSystem->m_fMinDieAlpha) * RANDOM_FLOAT);
	m_fAlphaChange = (fEndAlpha - m_fAlpha) / m_fDieAge;

  //set the size values:
	m_fSize = ParentSystem->m_fMinEmitSize +
			 ((ParentSystem->m_fMaxEmitSize - ParentSystem->m_fMinEmitSize) * RANDOM_FLOAT);
	float fEndSize = ParentSystem->m_fMinDieSize +
			 ((ParentSystem->m_fMaxDieSize - ParentSystem->m_fMinDieSize) * RANDOM_FLOAT);
	m_fSizeChange = (fEndSize - m_fSize) / m_fDieAge;

  //spin values:
	m_fSpinAngle = 0.0f;
	m_fSpinSpeed = ParentSystem->m_fMinEmitSpinSpeed +
			((ParentSystem->m_fMaxEmitSpinSpeed - ParentSystem->m_fMinEmitSpinSpeed) * RANDOM_FLOAT);
	m_fSpinAcceleration = ParentSystem->m_fMinSpinAcceleration +
			((ParentSystem->m_fMaxSpinAcceleration - ParentSystem->m_fMinSpinAcceleration) * RANDOM_FLOAT);



  //Ok, we're done:
	m_bIsAlive = true;
	m_ParentSystem = ParentSystem;


}

void CCCParticle::Update(float timePassed)
{
	//Update all time-dependent values:
	m_fAge += timePassed;
	if (m_fAge >= m_fDieAge) 
	{
		if (m_ParentSystem->m_bRecreateWhenDied) 
		{
			Initialize(m_ParentSystem);
			Update(RANDOM_FLOAT * timePassed);  //see comment in UpdateSystem
		}
		else
		{
			m_fAge = 0.0f;
			m_bIsAlive = false;
			m_ParentSystem->m_iParticlesInUse--;
		}

		return;
	}

	m_fSize  += m_fSizeChange *timePassed;
	m_fAlpha += m_fAlphaChange*timePassed;
	m_Color = m_Color + m_ColorChange*timePassed;
	m_Velocity = m_Velocity + m_Acceleration*timePassed;
	//Note: exact would be: m_Position = 1/2*m_Acceleration*timePassed² + m_VelocityOLD*timePassed;
	//But this approach is ok, I think!
	m_Position = m_Position + (m_Velocity*timePassed);

	m_fSpinSpeed += m_fSpinAcceleration*timePassed;
	m_fSpinAngle += m_fSpinSpeed*timePassed;

	//That's all!
}

void CCCParticle::Render()
{
	if (!m_ParentSystem->m_bUseTexture) 
	{
		glPointSize(m_fSize*m_ParentSystem->m_fCurrentPointSize);
		float color[4];
		color[0] = m_Color.x;
		color[1] = m_Color.y;
		color[2] = m_Color.z;
		color[3] = m_fAlpha;

		glColor4fv(&color[0]);

		glBegin(GL_POINTS);
			glVertex3fv(&m_Position.x);
		glEnd();
	}
	else
	{
		//render using texture: (texture was already set active by the Render method of the particle system)
		
		float color[4];
		color[0] = m_Color.x;
		color[1] = m_Color.y;
		color[2] = m_Color.z;
		color[3] = m_fAlpha;
		glColor4fv(&color[0]);

		SF3dVector RotatedX = m_ParentSystem->m_BillboardedX;
		SF3dVector RotatedY = m_ParentSystem->m_BillboardedY;


	   //If spinning is switched on, rotate the particle now:
		if (m_fSpinAngle > 0.0f)
		{
			RotatedX = m_ParentSystem->m_BillboardedX * cos(m_fSpinAngle) 
				       + m_ParentSystem->m_BillboardedY * sin(m_fSpinAngle);
			RotatedY = m_ParentSystem->m_BillboardedY * cos(m_fSpinAngle) 
				       - m_ParentSystem->m_BillboardedX * sin(m_fSpinAngle);
		}
	
		
		//Render a quadrangle with the size m_fSize
		SF3dVector coords = m_Position - (RotatedX*(0.5f*m_fSize))
									   - (RotatedY*(0.5f*m_fSize));
		glBegin(GL_POLYGON);
		  glVertex3fv(&coords.x);
		  glTexCoord2f(0.0f,1.0f);
		  coords = coords + RotatedY * m_fSize;
		  glVertex3fv(&coords.x);
		  glTexCoord2f(1.0f,1.0f);
		  coords = coords + RotatedX * m_fSize;		  
		  glVertex3fv(&coords.x);
		  glTexCoord2f(1.0f,0.0f);
		  coords = coords - RotatedY * m_fSize;
		  glVertex3fv(&coords.x);
		  glTexCoord2f(0.0f,0.0f);
		glEnd();


	}

}

/*************************************

METHODS OF CCCParticleSytem class

**************************************/


CCCParticleSystem::CCCParticleSystem()
{
	//Set default values:
	
	//motion:
	this->m_EmitterPosition = NULL_VECTOR;
	this->m_MaxCreationDeviation = NULL_VECTOR;

	this->m_StandardEmitDirection = NULL_VECTOR;
	this->m_MaxEmitDirectionDeviation = NULL_VECTOR;
	this->m_fMaxEmitSpeed = 0.0f;
	this->m_fMinEmitSpeed = 0.0f;

	this->m_AccelerationDirection = NULL_VECTOR;
	this->m_fMaxAcceleration = 0.0f;
	this->m_fMinAcceleration = 0.0f;

	this->m_fMinEmitSpinSpeed = 0.0f;
	this->m_fMaxEmitSpinSpeed = 0.0f;
	
	this->m_fMaxSpinAcceleration = 0.0f;
	this->m_fMinSpinAcceleration = 0.0f;


	//look:
	this->m_fMaxEmitAlpha = 0.0f;
	this->m_fMinEmitAlpha = 0.0f;
	this->m_fMaxDieAlpha = 1.0f;
	this->m_fMinDieAlpha = 1.0f;

	this->m_MaxEmitColor = NULL_VECTOR;
	this->m_MinEmitColor = NULL_VECTOR;
	this->m_MaxDieColor = NULL_VECTOR;
	this->m_MinDieColor = NULL_VECTOR;

	this->m_Texture = NULL;
	this->m_bUseTexture = false;
	this->m_iBillboarding = BILLBOARDING_NONE;

	//size:
	this->m_fMaxEmitSize = 0.0f;
	this->m_fMinEmitSize = 0.0f;
	this->m_fMaxDieSize = 0.0f;
	this->m_fMinDieSize = 0.0f;


	//behavior:
	this->m_bRecreateWhenDied = false;
	
	this->m_fMaxDieAge = 1.0f;
	this->m_fMinDieAge = 1.0f;

	this->m_iMaxParticles = 0;  //array is not yet created
	this->m_iParticlesInUse = 0;

	this->m_iParticlesCreatedPerSec = 0;
	this->m_fCreationVariance = 0.0f;
	this->m_bParticlesLeaveSystem = false;
	this->m_pParticles = NULL;

}
//*********************************************************
void CCCParticleSystem::SetEmitter(float x, float y, float z, float EmitterDeviationX,float EmitterDeviationY,float EmitterDeviationZ)
{
	SetEmitter(F3dVector(x,y,z),F3dVector(EmitterDeviationX,EmitterDeviationY,EmitterDeviationZ));
}

void CCCParticleSystem::SetEmitter(SF3dVector pos, SF3dVector dev)
{
	m_EmitterPosition = pos;
	m_MaxCreationDeviation = dev;
}

void CCCParticleSystem::SetEmissionDirection(float x, float y, float z,
											 float MaxDeviationX, float MaxDeviationY, float MaxDeviationZ)
{
	SetEmissionDirection(F3dVector(x,y,z),F3dVector(MaxDeviationX,MaxDeviationY,MaxDeviationZ));
}


void CCCParticleSystem::SetEmissionDirection(SF3dVector direction, SF3dVector Deviation)
{
	m_StandardEmitDirection = direction;
	m_MaxEmitDirectionDeviation = Deviation;
}




void CCCParticleSystem::SetSpinSpeed(float min, float max)
{
	m_fMinEmitSpinSpeed = min;
	m_fMaxEmitSpinSpeed = max;
}


void CCCParticleSystem::SetAcceleration(float x, float y, float z, float Min, float Max)
{
	SetAcceleration(F3dVector(x,y,z),Min,Max);
}

void CCCParticleSystem::SetAcceleration(SF3dVector acc, float Min, float Max)
{
	m_AccelerationDirection = acc;
	m_fMaxAcceleration = Max;
	m_fMinAcceleration = Min;
}

void CCCParticleSystem::SetCreationColor(float minr, float ming, float minb,
						   				 float maxr, float maxg, float maxb)
{
	SetCreationColor(F3dVector(minr,ming,minb),F3dVector(maxr,maxg,maxb));
}

void CCCParticleSystem::SetCreationColor(SF3dVector min, SF3dVector max)
{
	m_MinEmitColor = min;
	m_MaxEmitColor = max;
}


void CCCParticleSystem::SetDieColor	(float minr, float ming, float minb,
						   		     float maxr, float maxg, float maxb)
{
	SetDieColor(F3dVector(minr,ming,minb),F3dVector(maxr,maxg,maxb));
}

void CCCParticleSystem::SetDieColor		(SF3dVector min, SF3dVector max)
{
	m_MinDieColor = min;
	m_MaxDieColor = max;
}

void CCCParticleSystem::SetAlphaValues (float MinEmit, float MaxEmit, float MinDie, float MaxDie)
{
	m_fMinEmitAlpha = MinEmit;
	m_fMaxEmitAlpha = MaxEmit;
	m_fMinDieAlpha = MinDie;
	m_fMaxDieAlpha = MaxDie;
}

void CCCParticleSystem::SetSizeValues (float EmitMin, float EmitMax, float DieMin, float DieMax)
{
	m_fMinEmitSize = EmitMin;
	m_fMaxEmitSize = EmitMax;
	m_fMinDieSize = DieMin;
	m_fMaxDieSize = DieMax;
}
//*********************************************************

bool CCCParticleSystem::Initialize(int iNumParticles)
{
	this->m_pParticles = new CCCParticle[iNumParticles];
	if (m_pParticles == NULL) 
	{
		return false;
		this->m_iMaxParticles = 0;
		this->m_iParticlesInUse = 0;
	}

	this->m_iMaxParticles = iNumParticles;
	this->m_iParticlesInUse = 0;

	//Set the status of each particle to DEAD
	for (int i = 0; i < iNumParticles; i++)
	{
		m_pParticles[i].m_bIsAlive = false;
	}

	return true;


	
}


void CCCParticleSystem::UpdateSystem(float timePassed)
{
	//We have to 
	//  -update the particles (= move the particles, change their alpha, color, speed values)
	//  -create new particles, if desired and there are "free" particles

	//First get the number of particles we want to create (randomly in a certain dimension (dependent of m_CreationVariance)
	
	int iParticlesToCreate = (int) ((float)m_iParticlesCreatedPerSec
										   *timePassed
		                                   *(1.0f+m_fCreationVariance*(RANDOM_FLOAT-0.5f)));
	

	//loop through the particles and update / create them
	for (int i = 0; i < m_iMaxParticles; i++)
	{
		if (m_pParticles[i].m_bIsAlive)
		{
			m_pParticles[i].Update(timePassed);
		}

		//Should we create the particle?
		if (iParticlesToCreate > 0)
		{
			if (!m_pParticles[i].m_bIsAlive)
			{
				m_pParticles[i].Initialize(this);
				//Update the particle: This has an effect, as if the particle would have
				//been emitted some milliseconds ago. This is very useful on slow PCs:
				//Especially if you simulate something like rain, then you could see that 
				//many particles are emitted at the same time (same "UpdateSystem" call),
				//if you would not call this function:				
				m_pParticles[i].Update(RANDOM_FLOAT*timePassed);  
				iParticlesToCreate--;
			}
		}

	}
	
}

bool CCCParticleSystem::LoadTextureFromFile(char * Filename)
{
	//Create the texture pointer:
	m_Texture = new COGLTexture;

	if (m_Texture == NULL) return false;

	if (!m_Texture->LoadFromTGA(Filename,NULL,true)) return false;  //pass NULL as 2. param (only required if you want to combine rgb and alpha maps)

	m_Texture->SetActive();
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	
	m_bUseTexture = true;


	return true;

}


void CCCParticleSystem::Render()
{
	//the calling method must switch on texturing!

	if (m_bUseTexture)
	{
		m_Texture->SetActive();
		//Calculate the "billboarding vectors" (the particles only store their positions, but we need quadrangles!)
		switch (m_iBillboarding)
		{
		case BILLBOARDING_NONE:
			{
				//independent from camera / view direction
				m_BillboardedX = F3dVector(1.0f,0.0f,0.0f);
				m_BillboardedY = F3dVector(0.0f,1.0f,0.0f);
				break;
			}
		case BILLBOARDING_PERPTOVIEWDIR:
			{
				//Retrieve the up and right vector from the modelview matrix:
				float fModelviewMatrix[16];
				glGetFloatv(GL_MODELVIEW_MATRIX, fModelviewMatrix);

				//Assign the x-Vector for billboarding:
				m_BillboardedX = F3dVector(fModelviewMatrix[0], fModelviewMatrix[4], fModelviewMatrix[8]);

				//Assign the y-Vector for billboarding:
				m_BillboardedY = F3dVector(fModelviewMatrix[1], fModelviewMatrix[5], fModelviewMatrix[9]);
				break;
			}
		case BILLBOARDING_PERPTOVIEWDIR_BUTVERTICAL:
			{
				//Retrieve the right vector from the modelview matrix:
				float fModelviewMatrix[16];
				glGetFloatv(GL_MODELVIEW_MATRIX, fModelviewMatrix);

				//Assign the x-Vector for billboarding:
				m_BillboardedX = F3dVector(fModelviewMatrix[0], fModelviewMatrix[4], fModelviewMatrix[8]);

				//Assign the y-Vector:
				m_BillboardedY = F3dVector(0.0f,1.0f,0.0f);				
				break;
			}
		}
	}
	else
	{
		glGetFloatv(GL_POINT_SIZE,&m_fCurrentPointSize);
	}
	for (int i = 0; i < m_iMaxParticles; i++)
	{
		if (m_pParticles[i].m_bIsAlive)
			m_pParticles[i].Render();
	}
}
/**********************************************************************

  Particle Engine / Billboarding

  October, 21st, 2002

  This tutorial was written by Philipp Crocoll
  Contact: 
	philipp.crocoll@web.de
	www.codecolony.de

  Every comment would be appreciated.

  If you want to use parts of any code of mine:
	let me know and
	use it!

  If you get cool effects with this particle engine,
  I would be happy if you could send me the code. If you want to,
  I can upload it. This code is only a part of what you can do with 
  this engine.

***********************************************************************


  ESC					: Exit
  w,a,s,d,r,f,x,y,c,v	: move / turn



**********************************************************************/
   
#include <GL\glut.h>		//includes gl.h and glu.h
#include <GL\glaux.h>		//load the texture
#include <stdlib.h>			//random function
#include <math.h>			//sine and cosine functions

#include "Camera.h"
#include "particles.h"

//Particle variables:
CCCParticleSystem g_ParticleSystem1;
CCCParticleSystem g_ParticleSystem2;
CCCParticleSystem g_ParticleSystem3;
CCCParticleSystem g_ParticleSystem4;
CCCParticleSystem g_ParticleSystem5;
CCCParticleSystem g_ParticleSystem6;

//g_Camera:
CCamera g_Camera;

//Time handling (note: use QueryPerformanceCounter in "real" projects!)
long unsigned int g_iLastRenderTime = 0;


//code from the camera tutorial:
void DrawNet(GLfloat size, GLint LinesX, GLint LinesZ)
{
	glBegin(GL_LINES);
	for (int xc = 0; xc < LinesX; xc++)
	{
		glVertex3f(	-size / 2.0 + xc / (GLfloat)(LinesX-1)*size,
					0.0,
					size / 2.0);
		glVertex3f(	-size / 2.0 + xc / (GLfloat)(LinesX-1)*size,
					0.0,
					size / -2.0);
	}
	for (int zc = 0; zc < LinesX; zc++)
	{
		glVertex3f(	size / 2.0,
					0.0,
					-size / 2.0 + zc / (GLfloat)(LinesZ-1)*size);
		glVertex3f(	size / -2.0,
					0.0,
					-size / 2.0 + zc / (GLfloat)(LinesZ-1)*size);
	}
	glEnd();
}


void Display(void)
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();	//Load a new modelview matrix -> we can apply new transformations

	//Update the scene:
	long unsigned int iNowTime = timeGetTime();
	float timePassed = float(iNowTime-g_iLastRenderTime)/1000.0f;  //divide by 1000
	g_ParticleSystem1.UpdateSystem(timePassed);
	g_ParticleSystem2.UpdateSystem(timePassed);
	g_ParticleSystem3.UpdateSystem(timePassed);
	g_ParticleSystem4.UpdateSystem(timePassed);
	g_ParticleSystem5.UpdateSystem(timePassed);
	g_ParticleSystem6.UpdateSystem(timePassed);
	
	g_iLastRenderTime = iNowTime;
	
	//render everything:
	g_Camera.Render();

	
	
	//render an opaque quadrangle:	(if you want to see how to do this...)
/*	glEnable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);
	glColor3f(1.0f,0.0,1.0f);

	glBegin(GL_POLYGON);
	glVertex3f(0.0f,0.0f,0.0f);
	glVertex3f(1.0f,0.0f,0.0f);
	glVertex3f(1.0f,1.0f,0.0f);
	glVertex3f(0.0f,1.0f,0.0f);
	glEnd();
*/

	//render the nets, so switch off blending and texturing:
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	//enable depth testing (and z-buffer-writing)
	glEnable(GL_DEPTH_TEST);
	glDepthMask(GL_TRUE);
	
	GLfloat size = 2.0;
	GLint LinesX = 30;
	GLint LinesZ = 30;
	
	glColor3f(1.0,0.0,0.0);
	glPushMatrix();
		glTranslatef(0.0,0.0 ,0.0);
		DrawNet(size,LinesX,LinesZ);
		glTranslatef(0.0,size,0.0);
		DrawNet(size,LinesX,LinesZ);
	glPopMatrix();
	
	
	//Render system 2 first, it's not textured:

	glEnable(GL_BLEND);
	glDepthMask(GL_FALSE);
	glEnable(GL_DEPTH_TEST);

	//Calculate the point size depending from the camera's distance to the emitter:
	//(in order to be 100% exact we would have to pass the camera position to the
	//particles' render function. This method would then have to calculate the point size for each particle!)
	float zDist = g_Camera.GetPosition().z - g_ParticleSystem2.m_EmitterPosition.z;
	float xDist = g_Camera.GetPosition().x - g_ParticleSystem2.m_EmitterPosition.x;
	float CamDistToEmitter = sqrt(SQR(zDist)+SQR(xDist));
	if (CamDistToEmitter < 0.2f) //avoid too big particles
		CamDistToEmitter = 0.2f;
	glPointSize(1.0f/CamDistToEmitter);
	g_ParticleSystem2.Render();

	//Now enable texturing and render the other particle systems:
	glEnable(GL_TEXTURE_2D);
	g_ParticleSystem1.Render();
	g_ParticleSystem3.Render();
	g_ParticleSystem4.Render();
	g_ParticleSystem5.Render();
	g_ParticleSystem6.Render();
	glDepthMask(GL_TRUE);


	glFlush();			//Finish rendering
	glutSwapBuffers();	//Swap the buffers ->make the result of rendering visible
}
void Reshape(int x, int y)
{
	if (y == 0 || x == 0) return;  //Nothing is visible then, so return
	//Set a new projection matrix
	glMatrixMode(GL_PROJECTION);  
	glLoadIdentity();
	//Angle of view:40 degrees
	//Near clipping plane distance: 0.5
	//Far clipping plane distance: 20.0
	gluPerspective(40.0,(GLdouble)x/(GLdouble)y,0.05,10.0);
	glMatrixMode(GL_MODELVIEW);
	glViewport(0,0,x,y);  //Use the whole window for rendering

}
void KeyDown(unsigned char key, int x, int y)
{	
	switch(key)
	{
	case 27:	//ESC
		exit(0);
		break;
	case 'a':		
		g_Camera.RotateY(5.0);
		Display();
		break;
	case 'd':		
		g_Camera.RotateY(-5.0);
		Display();
		break;
	case 'w':		
		g_Camera.MoveForwards( -0.1 ) ;
		Display();
		break;
	case 's':		
		g_Camera.MoveForwards( 0.1 ) ;
		Display();
		break;
	case 'x':		
		g_Camera.RotateX(5.0);
		Display();
		break;
	case 'y':		
		g_Camera.RotateX(-5.0);
		Display();
		break;
	case 'c':		
		g_Camera.StrafeRight(-0.1);
		Display();
		break;
	case 'v':		
		g_Camera.StrafeRight(0.1);
		Display();
		break;
	case 'f':
		g_Camera.Move(F3dVector(0.0,-0.3,0.0));
		Display();
		break;
	case 'r':
		g_Camera.Move(F3dVector(0.0,0.3,0.0));
		Display();
		break;

	}
}

void InitParticles()
{
//INIT SYSTEM 1 (FIRE1)
	g_ParticleSystem1.Initialize(300);
	g_ParticleSystem1.m_iParticlesCreatedPerSec = 300;
	g_ParticleSystem1.m_fCreationVariance = 0.0f;
	g_ParticleSystem1.m_bRecreateWhenDied = false;
	g_ParticleSystem1.m_fMinDieAge = 0.5f;
	g_ParticleSystem1.m_fMaxDieAge = 1.5f;
	g_ParticleSystem1.SetCreationColor(1.0f,0.0f,0.0f,
									1.0f,0.5f,0.0f);
	g_ParticleSystem1.SetDieColor(1.0f,1.0f,1.0f,
							      1.0f,0.5f,0.0f);

	g_ParticleSystem1.SetAlphaValues(1.0f,1.0f,0.0f,0.0f);
	g_ParticleSystem1.SetEmitter(0.0f,0.0f,0.5f,
								0.1f,0.0f,0.1f);
	g_ParticleSystem1.SetAcceleration(F3dVector(0.0f,1.0f,0.0f),0.3f,0.4f);
	g_ParticleSystem1.SetSizeValues(0.04f,0.08f,0.06f,0.12f);
	g_ParticleSystem1.m_fMaxEmitSpeed = 0.2f;
	g_ParticleSystem1.m_fMinEmitSpeed = 0.3f;
	g_ParticleSystem1.SetEmissionDirection(0.0f,1.0f,0.0f,
										0.08f,0.5f,0.08f);
	g_ParticleSystem1.m_bParticlesLeaveSystem = true;
	g_ParticleSystem1.SetSpinSpeed(-0.82*PI,0.82*PI);
	g_ParticleSystem1.m_iBillboarding = BILLBOARDING_PERPTOVIEWDIR;
	g_ParticleSystem1.LoadTextureFromFile("particle1.tga");

//INIT SYSTEM 2 (POINTS, FIREWORK)
	g_ParticleSystem2.Initialize(800);  //particle system must not have more than 800 particles
	g_ParticleSystem2.m_iParticlesCreatedPerSec = 800;  //we create all particles in the first second of the system's life
	g_ParticleSystem2.m_fMinDieAge = 2.5f;			//but the particles live longer than one second
	g_ParticleSystem2.m_fMaxDieAge = 2.5f;			//-> this causes the system to "shoot" periodically
		
	g_ParticleSystem2.m_fCreationVariance = 1.0f;
	g_ParticleSystem2.m_bRecreateWhenDied = true;
	g_ParticleSystem2.SetCreationColor(1.0f,1.0f,1.0f,
								0.5f,0.5f,0.5f);
	g_ParticleSystem2.SetDieColor(0.0f,1.0f,0.0f,
							   0.0f,0.3f,0.0f);
	g_ParticleSystem2.SetAlphaValues(1.0f,1.0f,0.0f,0.0f);
	g_ParticleSystem2.SetEmitter(0.8f,0.0f,0.0f,
								0.02f,0.0f,0.02f);
	g_ParticleSystem2.SetAcceleration(F3dVector(0.0f,-1.0f,0.0f),0.83f,1.4f);
	g_ParticleSystem2.SetSizeValues(3.0f,3.0f,4.0f,4.0f);
	g_ParticleSystem2.m_fMaxEmitSpeed = 0.82f;
	g_ParticleSystem2.m_fMinEmitSpeed = 1.3f;
	g_ParticleSystem2.SetEmissionDirection(-1.0f,2.0f,0.0f,
										0.5f,0.5f,0.5f);

	g_ParticleSystem2.m_bParticlesLeaveSystem = true;
	
//INIT SYSTEM 3 (RAIN)
	g_ParticleSystem3.Initialize(10000);
	g_ParticleSystem3.m_iParticlesCreatedPerSec = 4950;
	g_ParticleSystem3.m_fCreationVariance = 0.0f;
	g_ParticleSystem3.m_bRecreateWhenDied = false;
	g_ParticleSystem3.m_fMinDieAge = 2.0f;
	g_ParticleSystem3.m_fMaxDieAge = 2.0f;
	g_ParticleSystem3.SetCreationColor(0.0f,0.0f,1.0f,
									0.3f,0.3f,1.0f);
	g_ParticleSystem3.SetDieColor(0.4f,0.4f,1.0f,
							   0.0f,0.0f,1.0f);

	g_ParticleSystem3.SetAlphaValues(1.0f,1.0f,1.0f,1.0f);  
	g_ParticleSystem3.SetEmitter(0.0f,2.0f,0.0f,
								 1.0f,0.0f,1.0f);
	g_ParticleSystem3.SetAcceleration(NULL_VECTOR,0.0f,0.0f);
	g_ParticleSystem3.SetSizeValues(0.01f,0.01f,0.01f,0.01f);
	g_ParticleSystem3.m_fMaxEmitSpeed = 1.0f;
	g_ParticleSystem3.m_fMinEmitSpeed = 1.0f;
	g_ParticleSystem3.SetEmissionDirection(0.0f,-1.0f,0.0f,
										0.00f,0.0f,0.00f);
	g_ParticleSystem3.m_bParticlesLeaveSystem = true;
	g_ParticleSystem3.m_iBillboarding = BILLBOARDING_PERPTOVIEWDIR_BUTVERTICAL;
	g_ParticleSystem3.LoadTextureFromFile("particle2.tga");

//INIT SYSTEM 4 (SMOKE)
	g_ParticleSystem4.Initialize(150);
	g_ParticleSystem4.m_iParticlesCreatedPerSec = 50;
	g_ParticleSystem4.m_fCreationVariance = 0.0f;
	g_ParticleSystem4.m_bRecreateWhenDied = false;
	g_ParticleSystem4.m_fMinDieAge = 2.5f;
	g_ParticleSystem4.m_fMaxDieAge = 3.5f;
	g_ParticleSystem4.SetCreationColor(0.1f,0.1f,0.1f,
									0.2f,0.2f,0.2f);
	g_ParticleSystem4.SetDieColor(0.0f,0.0f,0.0f,
							   0.0f,0.0f,0.0f);

	g_ParticleSystem4.SetAlphaValues(1.0f,1.0f,0.0f,0.0f);
	g_ParticleSystem4.SetEmitter(-0.8f,0.0f,0.0f,
								0.0f,0.0f,0.0f);
	g_ParticleSystem4.SetAcceleration(F3dVector(0.0f,1.0f,0.0f),0.3f,0.4f);
	g_ParticleSystem4.SetSizeValues(0.0f,0.0f,1.12f,1.22f);
	g_ParticleSystem4.m_fMaxEmitSpeed = 0.01f;
	g_ParticleSystem4.m_fMinEmitSpeed = 0.04f;
	g_ParticleSystem4.SetEmissionDirection(0.0f,1.0f,0.0f,
										   0.08f,0.5f,0.08f);
	g_ParticleSystem4.m_bParticlesLeaveSystem = true;
	g_ParticleSystem4.m_iBillboarding = BILLBOARDING_PERPTOVIEWDIR;
	g_ParticleSystem4.LoadTextureFromFile("particle3.tga");

//INIT SYSTEM 5 ("ENGINE")
	g_ParticleSystem5.Initialize(300);
	g_ParticleSystem5.m_iParticlesCreatedPerSec = 200;
	g_ParticleSystem5.m_fCreationVariance = 0.0f;
	g_ParticleSystem5.m_bRecreateWhenDied = false;
	g_ParticleSystem5.m_fMinDieAge = 1.0f;
	g_ParticleSystem5.m_fMaxDieAge = 1.3f;
	g_ParticleSystem5.SetCreationColor(0.5f,0.0f,0.0f,
									0.5f,0.1f,0.1f);
	g_ParticleSystem5.SetDieColor(0.2f,0.2f,0.0f,
							   0.8f,0.8f,0.0f);

	g_ParticleSystem5.SetAlphaValues(1.0f,1.0f,0.3f,0.3f);
	g_ParticleSystem5.SetEmitter(0.0f,0.0f,-1.0f,
								0.02f,0.02f,0.0f);
	g_ParticleSystem5.SetAcceleration(F3dVector(0.0f,1.0f,0.0f),0.0f,0.0f);
	g_ParticleSystem5.SetSizeValues(0.12f,0.12f,0.06f,0.06f);
	g_ParticleSystem5.m_fMaxEmitSpeed = 0.12f;
	g_ParticleSystem5.m_fMinEmitSpeed = 0.14f;
	g_ParticleSystem5.SetEmissionDirection(0.0f,0.0f,1.0f,
										   0.00f,0.0f,0.00f);
	g_ParticleSystem5.m_bParticlesLeaveSystem = true;
	g_ParticleSystem5.m_iBillboarding = BILLBOARDING_PERPTOVIEWDIR;
	g_ParticleSystem5.LoadTextureFromFile("particle3.tga");

//INIT SYSTEM 6 (FIRE2)
	g_ParticleSystem6.Initialize(300);
	g_ParticleSystem6.m_iParticlesCreatedPerSec = 300;

	g_ParticleSystem6.m_bRecreateWhenDied = false;
	g_ParticleSystem6.m_fMinDieAge = 0.5f;
	g_ParticleSystem6.m_fMaxDieAge = 1.0f;
	g_ParticleSystem6.SetCreationColor(1.0f,0.0f,0.0f,
									1.0f,0.5f,0.0f);
	g_ParticleSystem6.SetDieColor(1.0f,1.0f,1.0f,
							      1.0f,0.5f,0.0f);

	g_ParticleSystem6.SetAlphaValues(1.0f,1.0f,0.0f,0.0f);
	g_ParticleSystem6.SetEmitter(0.0f,0.0f,0.5f,
								0.18f,0.0f,0.18f);
	g_ParticleSystem6.SetAcceleration(F3dVector(0.0f,1.0f,0.0f),0.3f,0.4f);
	g_ParticleSystem6.SetSizeValues(0.04f,0.08f,0.06f,0.12f);
	g_ParticleSystem6.m_fMaxEmitSpeed = 0.12f;
	g_ParticleSystem6.m_fMinEmitSpeed = 0.23f;
	g_ParticleSystem6.SetEmissionDirection(0.0f,1.0f,0.0f,
										0.08f,0.5f,0.08f);
	g_ParticleSystem6.m_bParticlesLeaveSystem = true;
	g_ParticleSystem6.SetSpinSpeed(-0.82*PI,0.82*PI);
	g_ParticleSystem6.m_iBillboarding = BILLBOARDING_PERPTOVIEWDIR;
	g_ParticleSystem6.LoadTextureFromFile("particle1.tga");

}

int main(int argc, char **argv)
{	
	//Initialize GLUT
	glutInit(&argc, argv);
	//Lets use doublebuffering, RGB(A)-mode and a depth buffer
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(800,600);
	//Create a window with rendering context and everything else we need
	glutCreateWindow("Particle Engine and Billboarding");
	//Init some state variables:
	glDisable(GL_DEPTH_TEST);
	glClearColor(0.1,0.1,0.1,1.0);
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);	//also try GL_LINE
	
	g_Camera.Move(F3dVector(0.0f,0.3f,3.0f));
	

	//INITIALIZE THE PARTICLE SYSTEM:
	InitParticles();
	
	//Assign the event-handling routines
	glutDisplayFunc(Display);
	glutReshapeFunc(Reshape);
	glutKeyboardFunc(KeyDown);
	glutIdleFunc(Display);  //If there is no msg, we have to repaint

	g_iLastRenderTime = timeGetTime();
	//Let GLUT get the msgs and tell us the ones we need
	glutMainLoop();
	return 0;
}
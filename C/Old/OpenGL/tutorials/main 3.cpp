/**********************************************************************

  Solar System - Transformations Part 2

  June, 10th, 2000

  This tutorial was written by Philipp Crocoll
  Contact: 
	philipp.crocoll@web.de
	www.codecolony.de

  Every comment would be appreciated.

  If you want to use parts of any code of mine:
	let me know and
	use it!

***********************************************************************/

#include "windows.h"
#include <gl\glut.h>

#define SunSize 0.4
#define EarthSize 0.06
#define MoonSize 0.016

GLfloat SpeedMultiplicator = 1.0;
GLfloat DaysPerYear = 50.0; //OK, ok... but it is soo slow with 360!
GLfloat year = 0.0; //degrees
GLfloat day = 0.0;
GLfloat moonAroundEarth = 0.0;
GLfloat moonItsSelf = 0.0;
GLfloat EarthOrbitRadius = 1.0;
GLfloat MoonOrbitRadius = 0.1;
GLfloat daySpeed = 5.0 * SpeedMultiplicator;
GLfloat yearSpeed = DaysPerYear / 360.0 * daySpeed * SpeedMultiplicator;
GLfloat moonAroundEarthSpeed = 10 * SpeedMultiplicator;
GLfloat moonItsSelfSpeed = 5 * SpeedMultiplicator;
void RenderScene(void)
{
	glPushMatrix();
		gluLookAt(	0.0,0.0,-4.0,
					0.0,0.0,1.0,
					0.0,-3.0,0.0);
		glColor3f(1.0,1.0,0.6);
		glutWireSphere(SunSize,50,50);
		glPushMatrix();
			glRotatef(year,0.0,1.0,0.0);
			glTranslatef(EarthOrbitRadius,0.0,0.0);
			glRotatef(-year,0.0,1.0,0.0);
			glPushMatrix();
				glRotatef(day,0.25,1.0,0.0);
				glColor3f(0.0,0.5,0.8);
				glutWireSphere(EarthSize,10,10);  //Draw earth
				//Draw earth rotation axis
				glBegin(GL_LINES);
					glVertex3f(-0.0625,-0.25,0.0);
					glVertex3f(0.0625,0.25,0.0);
				glEnd();
			glPopMatrix();
			glRotatef(moonAroundEarth,0.0,1.0,0.0);
			glTranslatef(MoonOrbitRadius,0.0,0.0);
			//The following 2 lines should be combined, but it is better to understand this way
			glRotatef(-moonAroundEarth,0.0,1.0,0.0);
			glRotatef(moonItsSelf,0.0,1.0,0.0);
			glColor3f(0.8,0.8,0.75);
			glutWireSphere(MoonSize,8,8);
		glPopMatrix();
				
	glPopMatrix();
}

void Init(void)
{
	glClearColor(0.0,0.0,0.0,0.0);
	glClearDepth(10.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

void Display(void)
{
	glClear(GL_COLOR_BUFFER_BIT);
	RenderScene();
	glFlush();
	glutSwapBuffers();
}

void Reshape(int x, int y)
{
	if (y == 0) return;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(40.0,(GLdouble)x/(GLdouble)y,0.5,20.0);
	glMatrixMode(GL_MODELVIEW);
	glViewport(0,0,x,y);
	Display();
}

void Idle(void)
{
	day += daySpeed;
	year += yearSpeed;
	moonItsSelf += moonItsSelfSpeed;
	moonAroundEarth += moonAroundEarthSpeed;
	Display();
}


int main(int argc, char* argv[])
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
	glutInitWindowSize(600,600);
	glutCreateWindow(argv[0]);
	Init();
	glutReshapeFunc(Reshape);
	glutDisplayFunc(Display);
	glutIdleFunc(Idle);
	glutMainLoop();
	return 0;
}

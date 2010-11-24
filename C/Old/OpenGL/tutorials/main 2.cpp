/**********************************************************************

  Cube example - transformations and animations

  June, 8th, 2000

  This tutorial was written by Philipp Crocoll
  Contact: 
	philipp.crocoll@web.de
	www.codecolony.de

  Every comment would be appreciated.

  If you want to use parts of any code of mine:
	let me know and
	use it!

***********************************************************************/

#include <GL\glut.h>

GLfloat xRotated, yRotated, zRotated;


void Display(void)
{
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();
	glTranslatef(0.0,0.0,-4.0);
	glRotatef(xRotated,1.0,0.0,0.0);
	glRotatef(yRotated,0.0,1.0,0.0);
	glRotatef(zRotated,0.0,0.0,1.0);
	glScalef(2.0,1.0,1.0);
	glutWireCube(1.0);
	glFlush();			//Finish rendering
	glutSwapBuffers();
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
	gluPerspective(40.0,(GLdouble)x/(GLdouble)y,0.5,20.0);
	glMatrixMode(GL_MODELVIEW);
	glViewport(0,0,x,y);  //Use the whole window for rendering
}

void Idle(void)
{
	xRotated += 0.3;
	yRotated += 0.1;
	zRotated += -0.4;
	Display();
}


int main (int argc, char **argv)
{
	//Initialize GLUT
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);  //For animations you should use double buffering
	glutInitWindowSize(300,300);
	//Create a window with rendering context and everything else we need
	glutCreateWindow("Cube example");
	glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
	xRotated = yRotated = zRotated = 0.0;
	glClearColor(0.0,0.0,0.0,0.0);
	//Assign the two used Msg-routines
	glutDisplayFunc(Display);
	glutReshapeFunc(Reshape);
	glutIdleFunc(Idle);
	//Let GLUT get the msgs
	glutMainLoop();
	return 0;
}

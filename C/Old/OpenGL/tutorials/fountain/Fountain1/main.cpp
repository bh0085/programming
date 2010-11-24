/**********************************************************************

  Fountain

  June, 7th, 2000

  This tutorial was written by Philipp Crocoll
  Contact: 
	philipp.crocoll@web.de
	www.codecolony.de

  Every comment would be appreciated.

  If you want to use parts of any code of mine:
	let me know and
	use it!

  The used texture water.bmp is from www.freetextures.com

***********************************************************************


  ESC	: Exit
  m		: turn the movement up/down on/off
  t		: turn the turning around the fountain on/off
  u		: turn the updating of the scene on/off

**********************************************************************/
   
#include <GL\glut.h>		//includes gl.h and glu.h
#include <GL\glaux.h>		//load the texture
#include <stdlib.h>			//random function
#include <math.h>			//sine and cosine functions

#define PI 3.1415265359
#define RandomFactor 2.0	//cannot be variable, because it is only use in InitFountain(),
							//zero for perfect physical

GLint ListNum;  //The number of the diplay list

GLfloat OuterRadius = 1.2;
GLfloat InnerRadius = 1.0;
GLint NumOfVerticesStone = 32;    //only a quarter of the finally used vertices
GLfloat StoneHeight = 0.5;
GLfloat WaterHeight = 0.45;

GLint Turned = 0;
bool DoTurn = true;
bool DoMoveUp = true;
bool DoUpdateScene = true;
GLfloat MoveUp = 0.8;
GLfloat ChangeMoveUp = 0.01;

//The variables for the fountain are below



////////////////////////////////////////////////////////////////////////////////


struct SVertex
{
	GLfloat x,y,z;
};

//It's not the best style to put classes into the main file, 
//but here it is easier for you and me!
class CDrop
{
private:
	GLfloat time;  //How many steps the drop was "outside", when it falls into the water, time is set back to 0
	SVertex ConstantSpeed;  //See the doc for explanation of the physics
	GLfloat AccFactor;
public:
	void SetConstantSpeed (SVertex NewSpeed);
	void SetAccFactor(GLfloat NewAccFactor);
	void SetTime(GLfloat NewTime);
	void GetNewPosition(SVertex * PositionVertex);  //increments time, gets the new position
};

void CDrop::SetConstantSpeed(SVertex NewSpeed)
{
	ConstantSpeed = NewSpeed;
}

void CDrop::SetAccFactor (GLfloat NewAccFactor)
{
	AccFactor = NewAccFactor;
}

void CDrop::SetTime(GLfloat NewTime)
{
	time = NewTime;
}

void CDrop::GetNewPosition(SVertex * PositionVertex)
{
	SVertex Position;
	time += 1.0;
	Position.x = ConstantSpeed.x * time;
	Position.y = ConstantSpeed.y * time - AccFactor * time * time;
	Position.z = ConstantSpeed.z * time;
	PositionVertex->x = Position.x;
	PositionVertex->y = Position.y + WaterHeight;
	PositionVertex->z = Position.z;
	if (Position.y < 0.0) 
	{
		/*the drop has fallen into the water. The problem is now, that we cannot
		set time to 0.0, because if there are more "DropsPerRay" than "TimeNeeded" (See InitFountain())
		several drops would be seen as one. Check it out.
		*/
		time = time - int(time);
		if (time > 0.0) time -= 1.0;
	}
		
}

////////////////////////////////////////////////////////////////////////////////

CDrop * FountainDrops;
SVertex * FountainVertices;
GLint Steps = 3;   //a fountain has several steps, each with its own height
GLint RaysPerStep = 8;  
GLint DropsPerRay = 50;
GLfloat DropsComplete = Steps * RaysPerStep * DropsPerRay;
GLfloat AngleOfDeepestStep = 80;
GLfloat AccFactor = 0.011;

////////////////////////////////////////////////////////////////////////////////

void CreateList(void)
{	
	GLuint ID;
	_AUX_RGBImageRec *Image;
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1,&ID); 
	glBindTexture( GL_TEXTURE_2D, ID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_NEAREST);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	Image = auxDIBImageLoadA( "water.bmp" );
	gluBuild2DMipmaps(	GL_TEXTURE_2D, 3, 
						Image->sizeX,
						Image->sizeY,
						GL_RGB,
						GL_UNSIGNED_BYTE,
						Image->data);
	delete Image;
	SVertex * Vertices = new SVertex[NumOfVerticesStone*4];  //allocate mem for the required vertices
	ListNum = glGenLists(1);
	for (GLint i = 0; i<NumOfVerticesStone; i++)
	{
		Vertices[i].x = cos(2.0 * PI / NumOfVerticesStone * i) * OuterRadius;
		Vertices[i].y = StoneHeight;  //Top
		Vertices[i].z = sin(2.0 * PI / NumOfVerticesStone * i) * OuterRadius;
	}
	for (i = 0; i<NumOfVerticesStone; i++)
	{
		Vertices[i + NumOfVerticesStone*1].x = cos(2.0 * PI / NumOfVerticesStone * i) * InnerRadius;
		Vertices[i + NumOfVerticesStone*1].y = StoneHeight;  //Top
		Vertices[i + NumOfVerticesStone*1].z = sin(2.0 * PI / NumOfVerticesStone * i) * InnerRadius;
	}	
	for (i = 0; i<NumOfVerticesStone; i++)
	{
		Vertices[i + NumOfVerticesStone*2].x = cos(2.0 * PI / NumOfVerticesStone * i) * OuterRadius;
		Vertices[i + NumOfVerticesStone*2].y = 0.0;  //Bottom
		Vertices[i + NumOfVerticesStone*2].z = sin(2.0 * PI / NumOfVerticesStone * i) * OuterRadius;
	}
	for (i = 0; i<NumOfVerticesStone; i++)
	{
		Vertices[i + NumOfVerticesStone*3].x = cos(2.0 * PI / NumOfVerticesStone * i) * InnerRadius;
		Vertices[i + NumOfVerticesStone*3].y = 0.0;  //Bottom
		Vertices[i + NumOfVerticesStone*3].z = sin(2.0 * PI / NumOfVerticesStone * i) * InnerRadius;
	}
	glNewList(ListNum, GL_COMPILE);
	
		glBegin(GL_QUADS);
		//ground quad:
		glColor3f(0.6,0.6,0.6);
		glVertex3f(-OuterRadius*1.3,0.0,OuterRadius*1.3);
		glVertex3f(-OuterRadius*1.3,0.0,-OuterRadius*1.3);
		glVertex3f(OuterRadius*1.3,0.0,-OuterRadius*1.3);
		glVertex3f(OuterRadius*1.3,0.0,OuterRadius*1.3);
		//stone:
		for (int j = 1; j < 3; j++)
		{
			if (j == 1) glColor3f(0.8,0.4,0.4);
			if (j == 2) glColor3f(0.4,0.2,0.2);
			for (i = 0; i<NumOfVerticesStone-1; i++)
			{
				glVertex3fv(&Vertices[i+NumOfVerticesStone*j].x);
				glVertex3fv(&Vertices[i].x);
				glVertex3fv(&Vertices[i+1].x);
				glVertex3fv(&Vertices[i+NumOfVerticesStone*j+1].x);
			}
			glVertex3fv(&Vertices[i+NumOfVerticesStone*j].x);
			glVertex3fv(&Vertices[i].x);
			glVertex3fv(&Vertices[0].x);
			glVertex3fv(&Vertices[NumOfVerticesStone*j].x);
		}
		glColor3f(0.4,0.2,0.2);
		for (i = 0; i<NumOfVerticesStone-1; i++)
		{
			glVertex3fv(&Vertices[i+NumOfVerticesStone*3].x);
			glVertex3fv(&Vertices[i+NumOfVerticesStone].x);
			glVertex3fv(&Vertices[i+NumOfVerticesStone+1].x);
			glVertex3fv(&Vertices[i+NumOfVerticesStone*3+1].x);
		}
		glVertex3fv(&Vertices[i+NumOfVerticesStone*3].x);
		glVertex3fv(&Vertices[i+NumOfVerticesStone].x);
		glVertex3fv(&Vertices[NumOfVerticesStone].x);
		glVertex3fv(&Vertices[NumOfVerticesStone*3].x);

		glEnd();
		//The "water":
		glTranslatef(0.0,WaterHeight - StoneHeight, 0.0);
		glBindTexture(GL_TEXTURE_2D, ID);
		glEnable(GL_TEXTURE_2D);
		glBegin(GL_POLYGON);
		for (i = 0; i<NumOfVerticesStone; i++)
		{
			glTexCoord2f(	0.5+cos(i/GLfloat(NumOfVerticesStone)*360.0*PI/180.0)/2.0,
							0.5-sin(i/GLfloat(NumOfVerticesStone)*360.0*PI/180.0)/2.0);

			glVertex3fv(&Vertices[i+NumOfVerticesStone].x);
		}
		
		glEnd();
		glDisable(GL_TEXTURE_2D);
		
	glEndList();
}

GLfloat GetRandomFloat(GLfloat range)
{
	return (GLfloat)rand() / (GLfloat)RAND_MAX * range * RandomFactor;
}

void InitFountain(void)
{
	//This function needn't be and isn't speed optimized
	FountainDrops = new CDrop [ DropsComplete ];
	FountainVertices = new SVertex [ DropsComplete ];
	SVertex NewSpeed;
	GLfloat DropAccFactor; //different from AccFactor because of the random change
	GLfloat TimeNeeded;
	GLfloat StepAngle; //Angle, which the ray gets out of the fountain with
	GLfloat RayAngle;	//Angle you see when you look down on the fountain
	GLint i,j,k;
	for (k = 0; k <Steps; k++)
	{
		for (j = 0; j < RaysPerStep; j++)
		{
			for (i = 0; i < DropsPerRay; i++)
			{
				DropAccFactor = AccFactor + GetRandomFloat(0.0005);
				StepAngle = AngleOfDeepestStep + (90.0-AngleOfDeepestStep) 
						* GLfloat(k) / (Steps-1) + GetRandomFloat(0.2+0.8*(Steps-k-1)/(Steps-1));
				//This is the speed caused by the step:
				NewSpeed.x = cos ( StepAngle * PI / 180.0) * (0.2+0.04*k);
				NewSpeed.y = sin ( StepAngle * PI / 180.0) * (0.2+0.04*k);
				//This is the speed caused by the ray:
	
				RayAngle = (GLfloat)j / (GLfloat)RaysPerStep * 360.0;
				//for the next computations "NewSpeed.x" is the radius. Care! Dont swap the two
				//lines, because the second one changes NewSpeed.x!
				NewSpeed.z = NewSpeed.x * sin ( RayAngle * PI /180.0);
				NewSpeed.x = NewSpeed.x * cos ( RayAngle * PI /180.0);
				
				//Calculate how many steps are required, that a drop comes out and falls down again
				TimeNeeded = NewSpeed.y/ DropAccFactor;
				FountainDrops[i+j*DropsPerRay+k*DropsPerRay*RaysPerStep].SetConstantSpeed ( NewSpeed );
				FountainDrops[i+j*DropsPerRay+k*DropsPerRay*RaysPerStep].SetAccFactor (DropAccFactor);
				FountainDrops[i+j*DropsPerRay+k*DropsPerRay*RaysPerStep].SetTime(TimeNeeded * i / DropsPerRay);
			}
		}
	}


	//Tell OGL that we'll use the vertex array function
	glEnableClientState(GL_VERTEX_ARRAY);
	//Pass the date position
	glVertexPointer(	3,			//x,y,z-components
						GL_FLOAT,	//data type of SVertex
						0,			//the vertices are tightly packed
						FountainVertices);
						
}


void DrawFountain(void)
{
	glColor4f(0.8,0.8,0.8,0.8);
	if (DoUpdateScene)
	for (int i = 0; i < DropsComplete; i++)
	{
		FountainDrops[i].GetNewPosition(&FountainVertices[i]);
	}
	glDrawArrays(	GL_POINTS,
					0,
					DropsComplete);
}


void Display(void)
{
	if (DoTurn) Turned += 2;
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();	//Load a new modelview matrix -> we can apply new transformations
	glTranslatef(0.0,0.0,-5.0);	
	//glRotatef(90.0,1.0,0.0,0.0);	//Enable this line to look down on the fountain
	glRotatef((GLfloat)Turned,0.0,1.0,0.0);
	if (DoMoveUp)
	{
		MoveUp += ChangeMoveUp;
		if (MoveUp>= 1.5 || MoveUp<=0.8) ChangeMoveUp = -ChangeMoveUp;
	}
	glTranslatef(0.0,-MoveUp,0.0);	
	glPushMatrix();
		glCallList(ListNum);
	glPopMatrix();
	DrawFountain();
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
	gluPerspective(40.0,(GLdouble)x/(GLdouble)y,0.5,20.0);
	glMatrixMode(GL_MODELVIEW);
	glViewport(0,0,x,y);  //Use the whole window for rendering
	//Adjust point size to window size
	glPointSize(GLfloat(x)/200.0);
}
void KeyDown(unsigned char key, int x, int y)
{	
	switch(key)
	{
	case 27:	//ESC
		exit(0);
		break;
	case 't':
		DoTurn = !DoTurn;
		break;
	case 'm':
		DoMoveUp = !DoMoveUp;
		break;
	case 'u':
		DoUpdateScene = !DoUpdateScene;
		break;
	}
}

int main(int argc, char **argv)
{	
	//Initialize GLUT
	glutInit(&argc, argv);
	//Lets use doublebuffering, RGB(A)-mode and a depth buffer
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(300,300);
	//Create a window with rendering context and everything else we need
	glutCreateWindow("Fountain");
	//Init some state variables:
	glEnable(GL_DEPTH_TEST);
	glClearColor(0.1,0.1,0.1,0.0);
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);	//also try GL_LINE
	//Init the foundtain
	InitFountain();
	//Create the display list
	CreateList();
	
	//Assign the event-handling routines
	glutDisplayFunc(Display);
	glutReshapeFunc(Reshape);
	glutKeyboardFunc(KeyDown);
	glutIdleFunc(Display);  //If there is no msg, we have to repaint
	//Let GLUT get the msgs and tell us the ones we need
	glutMainLoop();
	return 0;
}
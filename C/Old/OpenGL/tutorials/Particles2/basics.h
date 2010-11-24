#ifndef _CC_BASICS_INCLUDED
#define _CC_BASICS_INCLUDED

#include <GL\glut.h>



#define PI 3.14159265359

#define SQR(a) (a*a)


struct SF3dVector  //Float 3d-vect, normally used
{
	GLfloat x,y,z;
};
struct SF2dVector
{
	GLfloat x,y;
};

#define NULL_VECTOR F3dVector(0.0f,0.0f,0.0f)

SF3dVector operator* (SF3dVector v, float r);
SF3dVector operator/ (SF3dVector v, float r);
float operator* (SF3dVector v, SF3dVector u);	//Scalar product
SF3dVector operator+ (SF3dVector v, SF3dVector u);
SF3dVector operator- (SF3dVector v, SF3dVector u);
bool operator== (SF3dVector v, SF3dVector u);
bool operator!= (SF3dVector v, SF3dVector u);


#endif
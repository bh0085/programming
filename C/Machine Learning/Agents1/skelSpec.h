/*
 *  skelSpec.h
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

class skelSpec {
public:
	skelSpec(unsigned numBones);
	~skelSpec();
	void setCxn(unsigned bone, unsigned val);
	void setMotor(unsigned bone,unsigned val);
	void setLength(unsigned bone, float len);
	
	unsigned getCxn(unsigned bone);
	unsigned getMotor(unsigned bone);
	float getLength(unsigned bone);
	unsigned getNumBones();

private:
	unsigned nBones;
	unsigned * cxns;
	unsigned * motors;
	float * lengths;
};
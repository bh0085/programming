/*
 *  BrainScript.h
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef BRAIN_SCRIPT_H
#define BRAIN_SCRIPT_H

#include "bgSkeleton.h"
class BrainScript{
	//A Brainscript may be executed on a given skeleton
public:
	BrainScript(unsigned init_type, unsigned init_lifetime);
	BrainScript::~BrainScript();
	void execute(bgSkeleton * skel);
	bool getDone();
private:
	unsigned type;
	unsigned lifetime;
	unsigned steps;
	bool isdone;
};

extern "C"{
	BrainScript * newFreezeScript();
}
#endif
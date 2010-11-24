/*
 *  BrainScript.cpp
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "BrainScript.h"
#include "stdlib.h"

//BrainScript functions
BrainScript::BrainScript(unsigned init_type, unsigned init_lifetime){
	lifetime = init_lifetime;
	type = init_type;
	steps = 0;
	isdone = false;
};
BrainScript::~BrainScript(){
}
void BrainScript::execute(bgSkeleton * skel){
	steps++;
	switch (type) {
		case 0:
			
			break;
		default:
			break;
	}
	if (steps >= lifetime){
		isdone = true;
	}
};
bool BrainScript::getDone(){
	return isdone;
}

extern "C" BrainScript * newFreezeScript(){
	BrainScript * script = new BrainScript(0,1);
	return script;
}

/*
 *  brain.h
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef GENE_BRAIN_H
#define GENE_BRAIN_H

#include "bgSkeleton.h"
#include "BrainScript.h"
typedef struct rs{
	unsigned max_tally;
	unsigned type;
} recurring_script;
typedef struct bs{
	unsigned step;
} BrainState;

class GeneBrain{
// A genebrain keeps track of scripts and controls skeleton.
public:
	GeneBrain(bgSkeleton * skel);
	~GeneBrain();
	void timeStep();
	void addScript(BrainScript * script);
	
private:
	vector <recurring_script> recurring_scripts;
	unsigned current_recurrence;
	unsigned recurrence_tally;
	
	vector <BrainScript *> scripts;
	bgSkeleton * body;
	BrainState state;
};

#endif
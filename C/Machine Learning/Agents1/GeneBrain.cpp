/*
 *  brain.cpp
 *  Agents1
 *
 *  Created by Benjamin Holmes on 11/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "stdlib.h"
#include "GeneBrain.h"
#include "iostream"
using namespace std;

GeneBrain::GeneBrain(bgSkeleton * skel){
	state.step = 0;
	current_recurrence  = 0;
	recurrence_tally =0;
};
GeneBrain::~GeneBrain(){
	//delete all scripts that remain in activity.
	while (scripts.size() > 0) {
		BrainScript * script = scripts[0];
		scripts.erase(scripts.begin());
		delete script;
	}	
};
void GeneBrain::timeStep(){
	
	if(recurring_scripts.size() > 0){
		recurrence_tally++;
		if(recurrence_tally > recurring_scripts[current_recurrence].max_tally){
			current_recurrence ++;
			if(current_recurrence >= recurring_scripts.size()){current_recurrence = 0;}
			recurring_script rs = recurring_scripts[current_recurrence];
			addScript(new BrainScript(rs.type,rs.max_tally));
		}
	}
	
	state.step++;
	for(int i = 0 ; i < scripts.size() ; i++){
		scripts[i]->execute(body);
		if(scripts[i]->getDone()){
			BrainScript * script = scripts[i];
			scripts.erase(scripts.begin() + i);
			i--;
			delete script;
		}
	}
};

//Add a heap allocated BrainScript.
//Will be deleted when finished.
void GeneBrain::addScript(BrainScript * script){
	scripts.push_back(script);
}



/*
 *  candidate1.cpp
 *  ai_specific
 *
 *  Created by Benjamin Holmes on 6/4/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <iostream>
#include <vector>
#include "TtoStr.h"

using namespace std;

class sailinstance{
	
public:
	
	vector <int> params;
	vector <int> nums;
	int sky;        //[0=sunny,1=cloudy,2=rainy]
	int airtemp;	//[0=warm,1=cold]
	int humidity;	//[0=dry,1=wet]
	int wind;		//[0=weak,1=strong]
	int water;		//[0=warm,1=cold]
	int forecast;	//[0=same,1=change]
	bool enjoysport;
	
	sailinstance(int s=0, int a=0, int h=0, int wi=0, int wa=0, int f=0, bool e=false){
		nums.push_back(3);
		nums.push_back(2);
		nums.push_back(2);
		nums.push_back(2);
		nums.push_back(2);
		nums.push_back(2);
		params.push_back(s);
		params.push_back(a);
		params.push_back(h);
		params.push_back(wi);
		params.push_back(wa);
		params.push_back(f);
		enjoysport=e;
	}
};

class sailhypothesis{
public:
    vector <int> params;
	
	/*	sailhypothesis(){
	 for(int i = 0; i < 6; i++){
	 params.push_back(-1);
	 }
	 };	*/
	sailhypothesis(int s=0, int  a=0, int h=0, int wi=0, int wa=0, int f=0){
		params.push_back(s);
		params.push_back(a);
		params.push_back(h);
		params.push_back(wi);
		params.push_back(wa);
		params.push_back(f);		
	};
	bool evaluate(sailinstance i){
		for(int j = 0; j < 6 ; j++){
			if(  (params[j] != i.params[j]) && (params[j] != -2) ){return false;};
		};
		return true;
	};
	void generalize(sailinstance i){
		for(int j = 0; j < 6 ; j++){
			if(  (params[j] != i.params[j]) && (params[j] != -2) ){
				if(params[j] == -1){params[j]=i.params[j];}else{params[j]=-2;}
			};
		};
	};
	string print(){
		string str = "";
		str.append(TtoStr(params[0]));
		str.append(TtoStr(params[1]));
		str.append(TtoStr(params[2]));
		str.append(TtoStr(params[3]));
		str.append(TtoStr(params[4]));
		str.append(TtoStr(params[5]));
		return str; 
	};
	//Methods for comparing hypothesis to one another...
	bool operator>(sailhypothesis sh){
		bool foundGreater = false;
		bool foundLess = false;
		bool foundIncomparable = false;
		for(int i = 0; i < params.size() ; i++){
			if(sh.params[i]==params[i]){continue;};
			if(sh.params[i]==-1){
				foundGreater = true;
				continue;
			};
			if(sh.params[i]==-2){
				foundLess=true;
				continue;
			};
			if(params[i] == -2){
				foundGreater=true;
				continue;
			};
			foundIncomparable=true;			
		};
		if(foundLess || foundIncomparable){return false;};
		if(foundGreater){return true;}
		return false;
	};
	bool operator<(sailhypothesis sh){
		bool foundGreater = false;
		bool foundLess = false;
		bool foundIncomparable = false;
		for(int i = 0; i < params.size() ; i++){
			if(sh.params[i]==params[i]){continue;};
			if(sh.params[i]==-1){
				foundGreater = true;
				continue;
			};
			if(sh.params[i]==-2){
				foundLess=true;
				continue;
			};
			if(params[i] == -2){
				foundGreater=true;
				continue;
			};
			foundIncomparable=true;			
		};
		if(foundGreater || foundIncomparable){return false;};
		if(foundLess){return true;}
		return false;
	};
	bool operator>=(sailhypothesis sh){
		cout<<params.size();
		bool foundGreater = false;
		bool foundLess = false;
		bool foundIncomparable = false;
		for(int i = 0; i < params.size() ; i++){
			if(sh.params[i]==params[i]){continue;};
			if(sh.params[i]==-1){
				foundGreater = true;
				continue;
			};
			if(sh.params[i]==-2){
				foundLess=true;
				continue;
			};
			if(params[i] == -2){
				foundGreater=true;
				continue;
			};
			foundIncomparable=true;			
		};
		if(foundLess || foundIncomparable){return false;};
		return true;
	};
	bool operator<=(sailhypothesis sh){
		cout<<params.size();
		bool foundGreater = false;
		bool foundLess = false;
		bool foundIncomparable = false;
		for(int i = 0; i < params.size() ; i++){
			if(sh.params[i]==params[i]){continue;};
			if(sh.params[i]==-1){
				foundGreater = true;
				continue;
			};
			if(sh.params[i]==-2){
				foundLess=true;
				continue;
			};
			if(params[i] == -2){
				foundGreater=true;
				continue;
			};
			foundIncomparable=true;			
		};
		if(foundGreater || foundIncomparable){return false;};
		return true;
	};
	
	vector <sailhypothesis*> minimalSpecializations(sailinstance ins){
		vector <sailhypothesis*> hs;
		sailhypothesis * h;
		for(int i = 0 ; i < params.size() ; i++){
			if(params[i] == -2){
				for(int j = 0 ; j<ins.nums[j] ; j++){
					if(ins.params[i]!=j){
						h = new sailhypothesis();
						(*h)=*this;
						h->params[i]=j;
						hs.push_back(h);
					};
				};
			};
		};
		return hs;
	};
	
	
};


void runCandidate() {
	
	sailinstance * sailpointer[4];
	sailpointer[0] = new sailinstance(0,0,0,1,0,0,true);
	sailpointer[1] = new sailinstance(0,0,1,1,0,0,true);
	sailpointer[2] = new sailinstance(1,1,1,1,0,1,false);
	sailpointer[3] = new sailinstance(0,0,1,1,1,1,true);
	vector  <sailhypothesis*> g;
	vector  <sailhypothesis*> s;
	g.push_back( new sailhypothesis(-2,-2,-2,-2,-2,-2));
	s.push_back( new sailhypothesis(-1,-1,-1,-1,-1,-1));
	
	for(int i = 0 ; i < 4 ; i++){
		
		sailinstance * ins = sailpointer[i];
		if(ins->enjoysport){
			//if the instance is a postive one, first delete all elements of G inconsistent with it
			for(int j = 0 ; j < g.size(); j++){
				if(!g[j] -> evaluate(*ins)){
					g.erase(g.begin() + j);
					j--;
				};
			}
			//if the instance is a positive one, test each element of the specific boundary
			for(int j = 0 ; j < s.size() ; j++){
				//first find elements that disagree
				if( !(s[j]->evaluate(*ins) )){
					//then generalize them
				    s[j]->generalize(*ins);
					//testing to make sure that their generalized versions are specifications of G
					bool foundGeneralization = false;
					for(int k = 0; k < g.size() ; k++){
						if((*(g[k]))>(*(s[j]))){foundGeneralization=true;}
					};
					if(!foundGeneralization){
						s.erase(s.begin()+j);
					};
					//and now, make sure that the new specialization does not generalize other specializations
					bool foundSpecialization = false;
					for(int k = 0; k < s.size() ; k++){
						if((*(s[k]))<(*(s[j]))){foundSpecialization=true;}
					};
					if(foundSpecialization){
						s.erase(s.begin() + j);
					};
				};
			};
		} else {
			//first eliminate any elements of the specific boundary that are inconsistent
			for(int j = 0 ; j < s.size() ; j++){
				if(s[j]->evaluate(*ins)){
					s.erase(s.begin()+j);
					j--;
				}
			}
			
			//in the case of a negative instance we check to see if specialization of the most general boundary is required
			for(int j = 0 ; j < g.size(); j++){
				//by evaluating each hypothesis in G
				if(g[j]->evaluate(*ins)){
					//getting a vector of specializations if the hypothesis fails to evaluate the instance
					vector <sailhypothesis*> gs = g[j]->minimalSpecializations(*ins);
					g.erase(g.begin() + j);
					j--;
					//test each of the specializations to make sure that it is greater than an S boundary element
					for(int k = 0 ; k < gs.size() ; k++){
						bool foundSpecialization = false;
						for( int l = 0 ; l < s.size() ; l++ ){
							if((*gs[k])>(*s[l])){
								foundSpecialization=true;
							};
							//if it is not greater than any S-elements erase it from the specialization list
							if(!foundSpecialization){
								gs.erase(gs.begin() + k);
								k--;
								continue;
							};
						};
					};
					//now, for each element of gs, check to make sure that it is not a specialization of a G-element
					for( int k = 0 ; k< gs.size() ; k++){
						bool foundGeneralization=false;
						for(int l = 0 ; l < g.size() ; l++){
							if((*(g[l]))>(*(gs[k]))){
								foundGeneralization=true;
							};
						};
						if(!foundGeneralization){
							//and if it is not a specialization, add it to the G-Boundary...
							g.push_back(gs[k]);
						};
					};
				};
			};
			
		};
		
	};
	
	cout<<"G boundary elements: "<<g.size()<<"\n";
	for(int i = 0 ; i < g.size() ; i++){
		cout<<g[i]->print()<<"\n";
		
	};
	cout<<"S boundary elements: "<<s.size()<<"\n";
	cin.get();
}


/*
 *  bitArray.cpp
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <climits> // FOR CHAR_BIT
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include "BitArray.h"
#include "math.h"

static const unsigned ARRAY_DEFAULT_LENGTH = 32;
static const char BIT_MASK=1;
static const unsigned bits_per_word = CHAR_BIT * sizeof(char);

BitArray::BitArray(){
	max_bits = ARRAY_DEFAULT_LENGTH;
	init();
}
BitArray::BitArray(unsigned max_length){
	max_bits = max_length;
	init();
}
BitArray::BitArray(const BitArray& b){
	max_bits = b.length();
	init();
	memcpy(data, b.data, max_words());
}
void BitArray::initWithLength(unsigned const max_length){
	max_bits = max_length;
	init();
};
void BitArray::init(){
	//if (data != NULL){delete [] data;} 
	data = new unsigned char[max_words()];
}

BitArray& BitArray::operator=(const BitArray& rhs){
	delete data;
	data = new unsigned char[max_words()];
	max_bits = rhs.length();
	memcpy(data, rhs.data, max_words());
	return *this;
}
BitArray::~BitArray(){
	delete [] data;
};


void BitArray::randomize(){
	for(int i = 0 ; i < max_words(); i++){
		data[i] = (unsigned char)(rand() % 256);
	}
}
void BitArray::randomizeBit(unsigned pos){
	for(int i = 0 ; i < max_words(); i++){
		if((rand() % 2) > 0) toggle(pos);
	}
}
void BitArray::set(unsigned position){
	unsigned word = position / bits_per_word;
	unsigned bit = position % bits_per_word;
	data[word] |= (BIT_MASK << bit);
}
void BitArray::toggle(unsigned position){
	unsigned word = position / bits_per_word;
	unsigned bit = position % bits_per_word;
	if(data[word] & (BIT_MASK << bit)){
		data[word] &= ~(BIT_MASK <<bit);
	} else {
		data[word] |= (BIT_MASK <<bit);
	}
}
void BitArray::clear(unsigned position){
	unsigned word = position / bits_per_word;
	unsigned bit = position % bits_per_word;
	data[word] &= ~(BIT_MASK<<bit);
}
void BitArray::display(){
	//cout<<"\n";
	for(int i = 0 ; i < length() ; i ++){
		if(i % CHAR_BIT == 0){printf(" ");}
		printf("%i",getBit(i));
	}
	printf("\n");
}
void BitArray::set(){
	memset(data,~0, max_bytes());
}
void BitArray::clear(){
	memset(data,0,max_bytes());
}

unsigned BitArray::getBit(unsigned position) const{
	unsigned word = position/ bits_per_word;
	unsigned bit = position % bits_per_word;
	if(data[word]  & (BIT_MASK << bit))
		return 1;
	else
		return 0;
}
bool BitArray::operator[](unsigned position){
	unsigned word = position/ bits_per_word;
	unsigned bit = position % bits_per_word;
	if(data[word]  & (BIT_MASK << bit))
		return true;
	else
		return false;
}
unsigned BitArray::max_words() const{
	unsigned result = max_bits/bits_per_word;
	if (max_bits % bits_per_word)
		++result;
	return result;
}

unsigned BitArray::length() const {return max_bits;};
const unsigned char * BitArray::getData() const{
	return data;
};
unsigned BitArray::unsignedAtWord(unsigned word){
	unsigned out;
	unsigned count = sizeof(unsigned);
	memcpy(&out,data + word, count);
return out;}
int BitArray::intAtWord(unsigned word){
	int out;
	unsigned count = sizeof(int);
	memcpy(&out,data + word, count);
return out;}

float BitArray::floatAtWord(unsigned word){
	float out;
	unsigned count = sizeof(float);
	memcpy(&out,data + word, count);
	return out;
}
unsigned int BitArray::nBitIntMax(unsigned nBits){
	return pow(2, nBits + 1) -1;
}
unsigned int BitArray::nBitIntAtBit(unsigned nBits, unsigned position){
	//assumes that the bits are ordered with the least significant
	//digit on the right
	unsigned intOut = 0;
	for (int i = 0 ; i < nBits ; i++){
		//enforce right-left ordering
		unsigned pos = position + nBits - 1 - i;
		unsigned bit = getBit(pos);
		
		intOut += pow(2,i)*bit;
	}
	return intOut;
								
}
unsigned int BitArray::nBitIntAtPtr(unsigned nBits){
	unsigned intOut = 0;
	for (int i = 0 ; i < nBits ; i++){
		//enforce right-left ordering
		unsigned pos = current_ptr++;
		unsigned bit = getBit(pos);
		intOut += pow(2,(nBits - i -1))*bit;
	}
	return intOut;		
}

void BitArray::bytesAtByte(unsigned byte, unsigned char * bytes, unsigned count) const{
	char * dtemp = (char *) data;
	memcpy(bytes,dtemp+byte,count);
}
void BitArray::displayWord(unsigned word){
	unsigned idx = word * bits_per_word;
	for(int i = 0 ; i < bits_per_word ; i ++){
		printf("%i",getBit(idx +i));
	}
	printf("\n");		
}
unsigned BitArray::bitsPerFloat(){
	return CHAR_BIT * sizeof(float);
}
unsigned BitArray::bitsPerUnsigned(){
	return CHAR_BIT * sizeof(unsigned);
}
void BitArray::reset_ptr(){
	current_ptr = 0;
}


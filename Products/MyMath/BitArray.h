/*
 *  bitArray.h
 *  Cart and Pole
 *
 *  Created by Benjamin Holmes on 8/30/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef BITARRAY_H
#define BITARRAY_H
class BitArray{
public:
	BitArray::BitArray();
	BitArray(unsigned max_length);
	BitArray::BitArray(const BitArray& b);
	~BitArray();
	BitArray& BitArray::operator=(const BitArray& rhs);		
	
	void initWithLength(const unsigned max_length);
	void init();
	void setLength(unsigned max_length);
	unsigned length() const;
	void reset_ptr();
	
	//Various Methods for modifying BitArray
	void set(unsigned position);
	void clear(unsigned position);
	void toggle(unsigned position);
	void display();
	void displayWord(unsigned word);
	void set();
	void clear();
	void randomize();
	void randomizeBit(unsigned pos);
	
	//Various Methods for extracting the data contained in a bitarray
	bool operator[](unsigned position);
	unsigned getBit(unsigned position) const;
	const unsigned char *getData() const;
	unsigned unsignedAtWord(unsigned word);
	float floatAtWord(unsigned word);
	int BitArray::intAtWord(unsigned word);
	unsigned int nBitIntMax(unsigned nBits);
	unsigned int nBitIntAtBit(unsigned nBits, unsigned position);	
	unsigned int nBitIntAtPtr(unsigned nBits);

	
	void bytesAtByte(unsigned byte, unsigned char * bytes, unsigned count) const;
	static unsigned bitsPerFloat();
	static unsigned bitsPerUnsigned();
protected:
	unsigned current_ptr;
	unsigned max_words() const;
	unsigned max_bytes() const;
	unsigned char * data;
	unsigned max_bits;


private:


	
};
inline unsigned BitArray::max_bytes() const{
	return sizeof(*data) * max_words();
}

#endif
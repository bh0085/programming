BOOST_ROOT=/Users/bh0085/boost/boost_1_39_0
PRODUCT_NAME=NN3CPP
BOOST_INCLUDE_DIR=/Users/bh0085/boost/boost_1_39_0
BOOST_LIB_DIR=/Users/bh0085/boost/boost_1_39_0/stage/lib
LIB=boost_regex-xgcc40-mt-1_39
SHELL = /bin/bash
main: main.cpp
	c++ main.cpp -I$(BOOST_INCLUDE_DIR)  -o $(PRODUCT_NAME)  -L$(BOOST_LIB_DIR) -l$(LIB)
clean:
	rm -f main
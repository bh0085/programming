// TtoStr.h
#include <string>
#include <sstream>

template<class T> std::string TtoStr(const T& r_t)
{
	std::ostringstream ossbuffer;
	ossbuffer << r_t;
	return ossbuffer.str();
}
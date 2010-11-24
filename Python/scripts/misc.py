#!/usr/bin/env python
#a module containing some random useful procedures

def stringAfterRegEx(str0="",regEx=None,strIns=""):
    
    end=regEx.search(str0).end()
    temp=str0[:end]+strIns+str0[end:]
    return temp

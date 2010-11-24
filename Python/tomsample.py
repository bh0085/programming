#!/opt/local/bin/python

def usage():
    print "Usage: ./tomsample.py k###"

import sys
try:
    name = sys.argv[1]
except:
    usage()
    exit(1)

ltr = name[0]
num = int(name[1:])
base_dir = '~/Programming/Python/save'

import os
import math

ltr_path = ltr + '_numbers'
num_path = str(int(math.floor(num/50)*50))
path = os.path.join(base_dir,ltr_path,num_path)
print path
exit(0)


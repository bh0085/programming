#! /usr/bin/env python


# THIS SCRIPT DOESN'T WORK!


import os
import re
import sys
from mutagen.flac import FLAC, Picture
from mutagen.id3 import APIC

if len(sys.argv) < 2:
    print "Usage: add_pictures_to_dir.sh directory"
    exit(1)

dir = sys.argv[1]
if not os.path.isdir:
    print "Enter a valid directory"
    exit(1)

os.chdir(dir)

picpath = 'cover.jpg'
if not os.path.isfile(picpath):
    print ["Sorry, i need piece of covert art labeled: ",picpath]

p_data = open(picpath).read()
#pic =   Picture(
#        encoding=3, # 3 is for utf-8
#        mime='image/jpeg', # image/jpeg or image/png
#        type=3, # 3 is for the cover image
#        desc=u'Cover',
#        data=p_data
#    )
#apic =   APIC(
#        encoding=3, # 3 is for utf-8
#        mime='image/jpeg', # image/jpeg or image/png
#        type=3, # 3 is for the cover image
#        desc=u'Cover',
#        data=p_data
#    )
pic = Picture()
pic.load(open(picpath))
flaccount=0
flext = re.compile(".*\.flac")
for f in files:
    if re.search(flext,f) != None:
        flaccount = flaccount +1
        ftag = FLAC(f)
        ftag.clear_pictures()
        ftag.add_picture(pic)
        ftag.save

exit(0)
        

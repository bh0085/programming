import os
#print os.listdir('.')
import subprocess
import pdb
import shutil
import re
import string
from mutagen.easyid3 import EasyID3

newline_re = re.compile('^.*',re.M)
ext_re = re.compile("\.[^\./]{2,4}$",re.I)
name_re = re.compile('([^/]*$)')

from extensions import list_ext
extensions = list_ext()


print 'seeking mp3s in the current directory'
execstring = 'find . -name "*.mp3"'
mp3ls = subprocess.Popen(execstring,shell = True, stdout = subprocess.PIPE)
out = mp3ls.communicate()[0]

#first we split the found files at newlines to get an array list of filenames
files = re.findall(newline_re, out)


sdir = '/Volumes/Media/Music/Sorted'
if not (os.path.exists(sdir)):
     print 'sorted directory does not exist'
     os.makedirs(sdir)


for f in files:
    if len(f) != 0:
        audio = EasyID3(f)
        artist = audio["artist"][0]
        album = audio["album"][0]
        s = string.join([artist,album],'/')
        alb_dir = string.join([sdir,s],'/')
        print alb_dir
        fname = re.findall(name_re,f)
        fname = fname[0]
        dest = string.join([alb_dir, fname],'/')
        if not (os.path.exists(alb_dir)):
            os.makedirs(alb_dir)
        pdb.set_trace()
        os.rename(f, dest)
        
            
#audio.save()

#print out

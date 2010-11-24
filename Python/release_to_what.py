#! /usr/bin/env python
#
#Usage release_to_tracker tracker directory
#

import sys
import subprocess
import what_mb
import os

if len(sys.argv) < 3:
    print "Usage: what_mb 'tracker' 'directory'"
    exit(1)

announce={}
announce['what'] = 'http://tracker.what.cd:34000/d95f93d9a238d190d0df5334f2072cf8/announce'
announce['waffles']='http://tracker.waffles.fm/announce.php?passkey=76bafecc6bbc5f378169b506455a757dccdbdb42&uid=115232'

code = {}
code['what'] = '(wtCD)'
code['waffles']='(waf)'

tracker = sys.argv[1]
dir = sys.argv[2]


if not tracker in announce.keys():
    print( 'Sorry, unsupported tracker' )

up_root = os.environ['torrent_up_directory']
if not os.path.isdir(up_root):
    os.makedirs(up_root)
if not os.path.isdir(dir):
    print( 'The directory that you have specified dont exist')
e    exit(1)


dir=os.path.abspath(dir)
print dir
bname = os.path.basename(dir)
link_bname = bname+" "+code[tracker]
link_dir = os.path.join(up_root,link_bname)
proc_str = 'ln -sF "'+dir+'" "'+link_dir+'"'
proc =subprocess.Popen(proc_str, shell = True, stdout=subprocess.PIPE)

os.chdir(up_root)
#print os.listdir('.')
proc_str ="mktorrent -v -p -a '"+announce[tracker]+"' -o '"+link_bname+".torrent' '"+link_bname+"'";
print proc_str
proc =subprocess.Popen(proc_str, shell = True, stdout=subprocess.PIPE)



#log100_re = re.compile('100</span')
#match = re.search(log100_re,submitlog(release_log))
#if match == None:
#    print "Log failed to check!"
#    exit(1)
#submitupload(sub)

#!/usr/bin/env python

import sys
import os
import metatorrent
import pdb
import shutil
import exceptions

def main(args):
    collection_dir = '/Volumes/Media/rcollect'
    if not os.path.isdir(collection_dir) :
        os.mkdir(collection_dir)
    for root, dirs, files in os.walk('.'):
        for f in files:
            path = os.path.join(root,f)
            ext = os.path.splitext(f)[-1]
            if ext == '.torrent':
                fopen = open(path)
                data = fopen.read()
                try:
                    d = metatorrent.decode(data)
                except:
                    print 'problematic torrent file', path
                    continue
                tname = d['info']['name']
                tpath = os.path.join(root,tname)
                if os.path.isdir(tpath):    
                    try:
                        srcname = tname
                        spath = tpath
                        dpath = os.path.join(collection_dir,srcname)
                        tor_name=f
                        tor_spath=path
                        tor_dpath=os.path.join(collection_dir,tor_name)
                        shutil.copytree(spath,dpath,True)
                        shutil.copy2(tor_spath,tor_dpath)
                        print('Copied:')
                        print tor_name, " --> ", tor_dpath
                        print srcname, " --> ", dpath
                    except OSError, e:
                        print e
    return (0)


exit(main(sys.argv[1:]))

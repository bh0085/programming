#!/usr/bin/env python
import sys
import os
import my_xml
import my_mb
import getopt
import re
import pdb
import shutil
#from xml.dom.ext.reader import Sax2
#from xml.dom.ext import PrettyPrint
#from xml import xpath
from mutagen.easyid3 import EasyID3
from mutagen.flac import FLAC
from mutagen.oggvorbis import OggVorbis
from mutagen.mp3 import MP3
from mutagen.id3 import ID3
import mutagen 
import release

class Catalog(dict):
    def __init__(self,xmldoc):
        self.doc = xmldoc
    def __write_doc__(self):
        path = self.doc.documentElement.getAttribute('path')
        filename = self.doc.documentElement.getAttribute('filename')
        f = open(os.path.join(path,filename),'w')
        PrettyPrint(self.doc,f)
        f.close()
    def save(self):
        self.__write_doc__

def init_path(path,filename):
    reader = Sax2.Reader()
    doc_string = '<?xml version="1.0" encoding="UTF-8"?>\n<catalog>\n</catalog>'
    doc = reader.fromString(doc_string)
    doc.documentElement.setAttribute('filename',filename)
    doc.documentElement.setAttribute('path',path)
    f = open(os.path.join(path,filename),'w')
    PrettyPrint(doc,f)
    f.close()

def load_path(path,cname):
    reader = Sax2.Reader()
    xmlfile = os.path.join(path,cname)
    if not os.path.isfile(xmlfile):
        raise Exception('No xml exists at path')
    rdoc = reader.fromStream(xmlfile)  
    r = Catalog(rdoc)
    return r




def get_default_catalog_path():
    if not 'PY_CATALOG_PATH' in os.environ.keys():
        print "OS environment variable $PY_CATALOG_PATH not set"
        return ''
    else:
        cat_root = os.environ['PY_CATALOG_PATH']
        return cat_root


def init_release(rnode):
    path = rnode.getAttribute('path')
    name = rnode.getAttribute('name')
    release.init_path(path,name)

def init_releases(cat):
   
    releases = []
    for root, dirs, files in os.walk(u'.'):
        depth = root.count(os.sep)
        if depth != 1: continue
        for d in dirs:
            path = os.path.join(root,d)
            releases.append(path)

    cur_rid = 0
    for r in releases:
        rnode = cat.doc.createElement('release_link')
        r_path = r
        r_name = os.path.basename(r)
        r_art_name = os.path.basename(os.path.dirname(r))
        r_local_id = cur_rid
        cur_rid = cur_rid + 1

        rnode.setAttribute('path',r_path)
        rnode.setAttribute('name',r_name)
        init_release(rnode)
        cat.doc.documentElement.appendChild(rnode)

def build_release_link(cat, rnode):

    path = rnode.getAttribute('path')
    l = os.listdir(path)
    
    children = xpath.Evaluate("child::*",rnode)
    for c in children:
        rnode.removeChild(c)

    fpath = os.path.join(path,'formats')
    if os.path.isdir(fpath):
        formats = os.listdir(fpath)
        for f in formats:
            fnode = cat.doc.createElement('format')
            fnode.setAttribute('name',f)
            rnode.appendChild(fnode)

    all_mbids = []
    for root,dirs, files in os.walk(path):
        for f in files:
            inf = media_info(os.path.join(root,f))
            if 'mbid' in inf.keys():
                mbid = inf['mbid']
                if not mbid in all_mbids:
                    all_mbids.append(mbid)
                    
    for mbid in all_mbids:
        mnode = cat.doc.createElement('mbid')
        t = cat.doc.createTextNode(mbid)
        mnode.appendChild(t)
        rnode.appendChild(mnode)
            
                
def build_catalog(cat):

    release_links = xpath.Evaluate('child::release_link',cat.doc.documentElement)
    for r in release_links:
        rnew = build_release_link(cat.doc,r)

def print_catalog(cat):
    release_links = xpath.Evaluate('child::release_link',cat.doc.documentElement)
    for rlink in release_links:    
        path = rlink.getAttribute('path')
        r = release.load_path(path)
        print r.getName()
def print_release_link(rnode):
    verbose = 0

    r_path = rnode.getAttribute('path')
    rr = release.load_path(r_path)

    print ''
    print rr.getName()
    print rr.getPath()
    print ''

    if verbose:
        print "formats:"
        formats = xpath.Evaluate("child::format",rnode)
        for f in formats:
            print "   ", f.getAttribute('name')
        print "mbIDs:"
        mbids = xpath.Evaluate("child::mbid",rnode)
        for f in mbids:
            print "   ", my_xml.node_text(f)


def media_info(f):
    aid_re = re.compile("brainz.*album.*id",re.I)
    has_info = 0
    ext = os.path.splitext(f)[-1]
    if ext == ".mp3":
        has_info = 1
        info = ID3(f)
        format = "MP3"
    if ext == ".flac":
        has_info = 1
        info = FLAC(f)
        format = "FLAC"
    if ext == ".ogg":
        has_info = 1
        info = OggVorbis(f)
        format = "OGG"

    if not has_info:
        return {}
    for k in info.keys():
        if re.search(aid_re,k) != None:
            aid = info[k]
            if type(aid) ==mutagen.id3.TXXX:
                aid = aid.__unicode__()
            if type(aid) == type([0]):
                aid = aid[0]
    
    info_d = {}
    info_d['mbid'] = aid
    return info_d
    

def move_songs():
    all_dirs = []
    for root, dirs, files in os.walk(u'.'):
        for d in dirs:
            all_dirs.append(os.path.join(root,d))

    for d in all_dirs:
        exts = []
        found_tags = 0
        albums = []
        formats = []
        artists = []
        for f in os.listdir(d):
            if os.path.isdir(os.path.join(d,f)): continue
            ext = os.path.splitext(f)[-1]
            if not ext in exts:
                exts.append(ext)
                
            info = -1
            if ext == ".mp3":
                info = EasyID3(os.path.join(d,f))
                infom = MP3(os.path.join(d,f))
                format = "MP3"
            if ext == ".flac":
                info = FLAC(os.path.join(d,f))
                format = "FLAC"
            if ext == ".ogg":
                info = OggVorbis(os.path.join(d,f))
                format = "OGG"
            if info != -1:
                found_tags = 1
                alb = info['album']
                artist = info['artist']
                
                if not alb in albums:
                    albums.append(alb)
                if not artist in artists:
                    artists.append(artist)
                if not format in formats:
                    formats.append(format)

        if not found_tags: continue

        if len(artists) != 1:
            target_art = u"Various Artists"
        else:
            target_art =artists[0][0]
            

        cat_root = get_default_catalog_path()
        if cat_root == '':
            print 'Catalog path not set, cannot move files'
            return
        base_dir=os.path.join(cat_root,target_art)  
      
        for root, dirs, files in os.walk(d):
            print root, "........", target_art
            for f in files:
                ext = os.path.splitext(f)[-1]
                print ext
                info = -1
                if ext == ".mp3":
                    info = EasyID3(os.path.join(d,f))
                    infom = MP3(os.path.join(d,f))
                    format = "MP3"
                if ext == ".flac":
                    info = FLAC(os.path.join(d,f))
                    format = "FLAC"
                if ext == ".ogg":
                    info = OggVorbis(os.path.join(d,f))
                    format = "OGG"
                if info != -1:
                    found_tags = 1
                    alb = info['album']
                    artist = info['artist']
                    spath = os.path.join(root,f)
                    target_dir = os.path.join(base_dir, alb[0],'formats',format)
                    if not os.path.isdir(target_dir):
                        os.makedirs(target_dir)
                    dpath = os.path.join(target_dir, f)
                    print dpath
                    if not os.path.isfile(dpath):
                        shutil.move(spath,dpath)
                    
                    


def move_fluff():
    all_dirs = []
    for root, dirs, files in os.walk(u'.'):
        for d in dirs:
            all_dirs.append(os.path.join(root,d))

    for d in all_dirs:
        exts = []
        found_tags = 0
        albums = []
        formats = []
        artists = []
        for f in os.listdir(d):
            if os.path.isdir(os.path.join(d,f)): continue
            ext = os.path.splitext(f)[-1]
            if not ext in exts:
                exts.append(ext)
                
            info = -1
            if ext == ".mp3":
                info = EasyID3(os.path.join(d,f))
                infom = MP3(os.path.join(d,f))
                format = "MP3"
            if ext == ".flac":
                info = FLAC(os.path.join(d,f))
                format = "FLAC"
            if ext == ".ogg":
                info = OggVorbis(os.path.join(d,f))
                format = "OGG"
            if info != -1:
                found_tags = 1
                alb = info['album']
                artist = info['artist']
                if not alb in albums:
                    albums.append(alb)
                if not artist in artists:
                    artists.append(artist)
                if not format in formats:
                    formats.append(format)

        if not found_tags: continue

        if len(artists) != 1:
            target_art = u"Various Artists"
        else:
            target_art =artists[0][0]
            
        
        cat_root = get_default_catalog_path()
        if cat_root == '':
            print 'Catalog path not set, cannot move files'
            return
        base_dir=os.path.join(cat_root,target_art)  

        for root, dirs, files in os.walk(d):
            print root
            for f in files:
                if os.path.splitext(f)[-1] in [u'.mp3',u'.flac',u'.ogg']: continue
                spath = os.path.join(root,f)
                has_copied = 0
                for alb in albums:
                    target_dir = os.path.join(base_dir, alb[0],'dump')
                    if not os.path.isdir(target_dir):
                        os.makedirs(target_dir)
                    dpath = os.path.join(target_dir, f)
                    if not os.path.isfile(dpath):
                        has_copied = 1
                        print "Copying: ", f, dpath
                        shutil.copy2(spath,dpath)
                if has_copied ==1:
                    os.remove(spath)

def usage():
    print '''Usage: catalog.py -opt
Options:
   -h: Prints help
   -b: Builds a new catalog over subdirectories.
   -i: Requests user input for the catalog (artwork and reviews) as necessary.
   -f: Specify a catalog file name, default 'catalog.xml'.
   -p: Print catalog data.
   -m: Move songs and info to a root music dir
'''
def main(argv):   
    do_build = 0
    do_input = 0
    do_clean = 0
    do_print = 1
    do_move = 0
    do_init = 0
    cname = '.catalog.xml'

    try:  
        opts, args = getopt.getopt(argv, 'hbio:pcm')
    except getopt.GetoptError:          
        usage()                         
        sys.exit(2)      
    for opt, arg in opts:  
        if opt in ("-h", "--help"):      
            usage()                     
            sys.exit()                  
        elif opt == '-b':                
            do_build=1
        elif opt == '-c':
            do_clean=1
        elif opt == 'o':
            cname = arg
        elif opt == 'p':
            do_print = 1
        elif opt == '-m':
            do_move = 1
        elif opt == '-i':
            do_init = 1
        
    #create catalog if it does not exist or instructed to do so
    if do_init or not os.path.isfile(cname):
        init_path('.',cname)
        cat = load_path('.',cname)
   
    if do_init:
        init_releases(cat)

    if do_move: 
        move_fluff()
        move_songs()
    
    if do_build:
        build_catalog(cat)

    if do_clean: clean_catalog(cat)
    if do_input:user_input(cat)
    if do_print:
        print_catalog(cat)

    cat.save()

    return 0

if __name__ == "__main__":
    exit(main(sys.argv[1:]))

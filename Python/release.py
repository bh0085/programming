from xml.dom.ext.reader import Sax2
from xml.dom.ext import PrettyPrint
import os
import pdb

class Release(dict):
    def __init__(self,xmldoc):
        self.doc = xmldoc
    def __write_doc__(self):
        path = self.doc.documentElement.getAttribute('path')
        f = open(os.path.join(path,'.release.xml'),'w')
        PrettyPrint(self.doc,f)
        f.close()
    def getName(self):
        return self.doc.documentElement.getAttribute('name')
    def getPath(self):
        return self.doc.documentElement.getAttribute('path')
    def setName(self,name):
        self.doc.documentElement.setAttribute('name',name)
    def setPath(self,path):
        self.doc.documentElement.setAttribute('path',name)
                
    def save(self):
        self.__write_doc__()
          
    def clean_directory(self):
        path = self.getPath()
        dump = 'dump'
        dump_p = os.path.join(path,dump)
        if not os.path.isdir(dump):
            os.mkdir(dump)    
        
        for root, dirs, files in os.walk(path):
            if dump in dirs:
                dirs.remove(dump)
            
            for f in files:
                ext = os.path.splitext(f)[-1]
                if not ext in ['.flac','.mp3','.ogg']:
                    print "Funny file type: ", ext, " in ", f
                    spath = os.path.join(root,f)
                    dpath = os.path.join(dump_p,f)
                    print "renaming:", spath, dpath
                    os.rename(spath, dpath)                

        for f in os.listdir(dump_p):
            ext = os.path.splitext(f)[-1]
            if ext in ['.jpeg','.gif','.png','.jpg']:
                print "Found art: ", f
            if ext in ['.log']:
                print "Found log: ", f


def load_path(path):

    reader = Sax2.Reader()
    xmlfile = os.path.join(path,'.release.xml')
    if not os.path.isfile(xmlfile):
        raise Exception('No xml exists at path')
    rdoc = reader.fromStream(xmlfile)  
    r = Release(rdoc)
    return r


def init_path(path,name):
    reader = Sax2.Reader()
    doc_string = '<?xml version="1.0" encoding="UTF-8"?>\n<release>\n</release>'
    doc = reader.fromString(doc_string)
    doc.documentElement.setAttribute('name',name)
    doc.documentElement.setAttribute('path',path)
    f = open(os.path.join(path,'.release.xml'),'w')
    PrettyPrint(doc,f)
    f.close()


 
                    


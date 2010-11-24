#! /usr/bin/env python

import string,cgi,time, os, re
from os import curdir, sep
from http.server import BaseHTTPRequestHandler, HTTPServer
webroot="/Users/bh0085/Programming/Python/pythonweb"

PORT = 8080
INDEX_FILE = "index.html"  

class MyHandler(BaseHTTPRequestHandler):

    MIME = {"HTML":"text/html", "TEXT":"text"}

    def serveHTML(self, path):
            f = open(path) 
            self.send_response(200)
            self.send_header('Content-type',	self.MIME["HTML"])
            self.end_headers()
            self.wfile.write(f.read().encode())
            f.close()

    def servePLAIN(self, path):
            f = open(path,'rb') 
            self.send_response(200)
            self.send_header('Content-type',	self.MIME["TEXT"])
            self.end_headers()
            self.wfile.write(f.read())
            f.close()

    def serveDirectory(self,path="/Users/bh0085/Programming/Python/"):
            import os
            newlist=os.listdir(path)
            stemp = ''
            for i in newlist:
                stemp=stemp+"::"+i
            ftemp=open(webroot+"/temp",'w')
            ftemp.write(stemp)
            ftemp.close()
            import subprocess
            subprocess.call(["/Users/bh0085/Programming/Bash/htmlDirectories.sh "+ webroot+"/temp"],shell=True)
            f = open("/Users/bh0085/Programming/Bash/htmlOut")
            self.send_response(200)
            self.send_header('Content-type',	self.MIME["HTML"])
            self.end_headers()
            self.wfile.write(f.read().encode())

    def do_GET(self):
        try:
            if self.path.count('~~')==1:
                regEx=re.compile('~~')
                end=regEx.search(self.path).end()
                targetpath=self.path[end:]
            elif self.path.count("~")==1:
                regEx=re.compile('~')
                end=regEx.search(self.path).end()
                targetpath=webroot+self.path[end:]     
            else:
                targetpath=curdir  + self.path
            try:
                indexCount=os.listdir(targetpath).count(INDEX_FILE)
                if indexCount != 0:
                    targetpath=targetpath+INDEX_FILE
            except:
                dummyline="dummyline"
           
            occurence=re.compile(".htm").search(targetpath)
            if occurence != None:
                self.serveHTML(targetpath)
                return
            else:
                self.servePLAIN(targetpath)
                return
        except IOError:
            try:
                self.serveDirectory(targetpath)
            except IOError:
                self.send_error(404,'File Not Found: %s' % self.path)

def main():
    try:
        server = HTTPServer(('', PORT), MyHandler)
        print ('started httpd')
        server.serve_forever()
    except KeyboardInterrupt:
        print ('^C received, shutting down server')
        server.socket.close()

if __name__ == '__main__':
    main()


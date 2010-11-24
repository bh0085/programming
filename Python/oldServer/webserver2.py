#! /usr/bin/python

import string,cgi,time, os
from os import curdir, sep
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

PORT = 80
INDEX_FILE = "index.html"  

class MyHandler(BaseHTTPRequestHandler):

    MIME = {"HTML":"text/html", "TEXT":"text"}

    def serveHTML(self, path):
        try:
            f = open(path) #self.path /index.html
            self.send_response(200)
            self.send_header('Content-type',	self.MIME["HTML"])
            self.end_headers()
            self.wfile.write(f.read())
            print("html")
            f.close()
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)
        
    def servePLAIN(self, path):
        try:
            f = open(path) #self.path /index.html
            self.send_response(200)
            self.send_header('Content-type',	self.MIME["TEXT"])
            self.end_headers()
            self.wfile.write(f.read())
            print("plain",path)
            f.close()
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)

    def do_GET(self):
        try:

            #Directories stuff
            if os.path.isdir(curdir + sep + self.path):
                self.path = self.path + "/"

            if self.path.endswith('/'):
                self.path = self.path + INDEX_FILE

            if self.path.endswith(".html") or self.path.endswith(".htm"):
                self.serveHTML(curdir + sep + self.path)
                return
            elif self.path.endswith(".php"):
                self.send_error(501, "PHP Not Implemented")
                return
            else:
                self.servePLAIN(curdir + sep + self.path)
                return
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)
     

    def do_POST(self):
        global rootnode
        try:
            self.versionCheck()
            ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
            if ctype == 'multipart/form-data':
                query=cgi.parse_multipart(self.rfile, pdict)
            self.send_response(301)
            
            self.end_headers()
            upfilecontent = query.get('upfile')
            print "filecontent", upfilecontent[0]
            self.wfile.write("<HTML>POST OK.<BR><BR>");
            self.wfile.write(upfilecontent[0]);
            
        except :
            pass

def main():
    try:
        server = HTTPServer(('', PORT), MyHandler)
        print 'started httpd'
        server.serve_forever()
    except KeyboardInterrupt:
        print '^C received, shutting down server'
        server.socket.close()

if __name__ == '__main__':
    main()


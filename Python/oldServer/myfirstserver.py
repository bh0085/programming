#! /usr/bin/python

import BaseHTTPServer
htmlpage = """
<html><head><title>Web Page</title></head>
<body>Hello Python World</body>
</html>"""
notfound = "File not found"
class WelcomeHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type","text/html")
            self.end_headers()
            self.wfile.write(htmlpage)
        else:
            self.send_error(404, notfound)
httpserver = BaseHTTPServer.HTTPServer(("",80), WelcomeHandler)
httpserver.serve_forever()

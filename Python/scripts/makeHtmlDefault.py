#! /usr/bin/env python
#A utility to bring up the basic html template and apply my default style sheet...

def gen1(cssName="css1.css"):
    import os
    import re
    from misc import stringAfterRegEx

    webdir="/Users/bh0085/Programming/Web/"
    pythondir="/Users/bh0085/Programming/Python/"
    writeDir="/Users/bh0085/Programming/Python/pythonweb/autopages/"
    cssfile= "~/css/"+cssName

    f=open(webdir+"htmlTemplate1.html")
    temp=f.read()

    exp = re.compile(r"head.*>")
    csstext="\n"+'<link rel="stylesheet" type="text/css" href="'+cssfile+'" />'
    temp=stringAfterRegEx(temp,re.compile(r"head[^>]*>"),csstext)
    temp=stringAfterRegEx(temp,re.compile(r"body[^>]*>"),"""
<p class='right'>right Aligned text</p>
""")
    temp=stringAfterRegEx(temp,re.compile(r"body[^>]*>"),"""
<div class="frametop"><span class='frametop'>Test Frame
<table width="100%">
<col align="left"></col>
<col align="right"></col>
<tr>
<td>
<a class="white" href="http://localhost:8080/"><div style="width:20; height:20; background:#000000" /></a>
</td>
<td align="right"></td>
</tr>
<tr>
<td>cell1</td>
<td align="right"><a class="white" href="http://localhost:8080/">webroot</a></td>
</tr>
</table>
</div>
</span>
""")   

    
    ldir=os.listdir(writeDir)
    num=ldir.__len__()+1
    name="webout_"+str(num)+".html"
    name0="webout_"+"0"+".html"
    fOut=open(writeDir+name,'w')
    fOut.write(temp)
    fOut.close
    fOut=open(writeDir+name0,'w')
    fOut.write(temp)
    fOut.close

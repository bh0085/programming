def convert_m4a():
    import extensions
    import re
    import subprocess
    import pdb
    from mutagen.m4a import M4A
    from mutagen.easyid3 import EasyID3
    from mutagen.mp3 import MP3
    ext_re = re.compile("\.[^\./]{2,4}$",re.I)

    ext = extensions.list_ext()
    if ext.has_key('.m4a'):
        files = ext['.m4a']
        for f in files:
            f = unicode(f,'utf-8')
            m4tag = M4A(f)

            lopts = u''
            ufields = {}
            for key in m4tag.keys():
                print key
                if re.search(re.compile('alb',re.I),key) != None:
                    album = m4tag[key]
                    lopts = lopts + '--tl ' + '"' + album  + '" '
                    ufields['album'] = album
                if re.search(re.compile('nam',re.I),key) != None:
                    title = m4tag[key]
                    ufields['title'] =title
                    lopts = lopts + '--tt ' + '"' + title  + '" ' 
                if re.search(re.compile('day',re.I),key) != None:
                    year = str(m4tag[key])
                    lopts = lopts + '--ty ' + '"' + year  + '" ' 
                if re.search(re.compile('art',re.I),key) != None:
                    artist = m4tag[key]
                    ufields['artist'] = artist
                    lopts = lopts + '--ta ' + '"' + artist  + '" ' 
                if re.search(re.compile('trkn',re.I),key) != None:
                    num = m4tag[key]
                    num = str(num[0])
                    lopts = lopts + '--tn ' + '"' + num  + '" ' 
                    
            fext0 = re.split(ext_re,f,1)
            fmp3 = fext0[0] + '.mp3'
            execstr = u'faad -o - "' + f +'" | lame -V 0 '+lopts+ ' - "' + fmp3 + '"'
            subprocess.call(execstr,shell = True)

            #rewrite tags in unicode...
            mptag = EasyID3(fmp3)
            for key in ufields.keys():
                print key
                mptag[key] = ufields[key]
            mptag.save()
            

                    
                
            




def list_ext():
    import os
    import subprocess
    import re
    import string

    newline_re = re.compile('^.*',re.M)
    ext_re = re.compile("\.[^\./]{2,4}$",re.I)
#first, lets see what kind of files are living in this directory
    execstring = 'find .'
    proc = subprocess.Popen(execstring,shell = True, stdout = subprocess.PIPE)
    all_files = proc.communicate()[0]
    all_files = re.findall(newline_re,all_files)

    extensions = {}
    for f in all_files:
        ext = re.findall(ext_re,f)
        if len(ext) != 0:
            e = ext[0]
            e = string.lower(e)
            if not extensions.has_key(e):
                extensions[e] = [f]
            else:
                extensions[e].append(f)
                
    return extensions

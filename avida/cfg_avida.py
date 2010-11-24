import os
import re 

#Make a custom events file.
def make_eve(name, fname):
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')

    new.write(lines)
    old.close() ; new.close()
    return new_fname

#Make an environment config. Nothing yet implemented - just copies.
def make_env(name, fname):
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')
    new.write(lines)
    old.close() ; new.close()

    return new_fname

#Make an organism. Nothing yet implemented - just copies.
def make_org(name, fname):
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')
    new.write(lines)
    old.close() ; new.close()

    return new_fname

#Make an inst set. Nothing yet implemented - just copies.
def make_ins(name, fname):
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')
    new.write(lines)
    old.close() ; new.close()

    return new_fname

#Make an analysis config. Nothing yet implemented - just copies.
def make_ana(name, fname):
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')
    new.write(lines)
    old.close() ; new.close()

    return new_fname

def make_gen(name,
             params,
             fname = 'avida.cfg'
             ):

    
    old = open(os.path.join(name,fname))
    lines = old.read()
    new_fname = os.path.join(name,os.path.join('autogen',fname+'.auto'))
    new = open(new_fname,'w')    

 

    print 'rewriting avida.cfg'
    print params
    print
    
    for k, v in params.iteritems():
        lines = sub_after(lines,
                          k,
                          v)
    
    new.write(lines)
    old.close() ; new.close()
    return new_fname


def sub_after(lines,
              term,
              value):
    lines = re.sub(re.compile('.*'+term+'.*',re.M),'',lines)
    lines = lines + '\n'+term+' '+str(value)
    return lines

def alter_eve(fname,append_str):
    f = open(fname,'r')
    data = f.read()

    data +='\n'+append_str
        
    f.close()
    f = open(fname,'w')
    f.write(data)
    f.close()
    
def alter_env(fname,append_str):
    f = open(fname,'r')
    data = f.read()

    data +='\n'+append_str
        
    f.close()
    f = open(fname,'w')
    f.write(data)
    f.close()
    
def append_lines(fname, lines):
    f = open(fname,'r')
    data = f.read()
    
    for l in lines:
        data +='\n'+l
        
    data += '\n\n'
    f.close()
    f = open(fname,'w')
    f.write(data)
    f.close()
    

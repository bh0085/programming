import re
import os
import scipy

from numpy import *
import numpy as np

def genesis_seqs(genesis):
    data = open(genesis).read()
    org = re.search(re.compile('START_CREATURE (\S+)'),data).group(1)
    instructions = re.search(re.compile('INST_SET (\S+)'),data).group(1)

    seq = org_sequence(instructions,org)
    return seq

def data_filepath(filename):
    return os.path.join('data',filename)

def parse_printed(filename):
    f = open(data_filepath(filename))
    lines = f.readlines()
    columns = []
    data = []
    for l in lines:
        if l[0] == '#':
            is_column = re.search(re.compile('# *[0-9]+'),l)
            if is_column:
                columns.append(re.search(re.compile(': *(.*)'),l).group(1))
        else:
            datapoints = []
            datamatches = re.finditer(re.compile('[0-9\.e\+\-]+'),l)
            for match in datamatches:
                datapoints.append(eval(match.group()))
        
            if len(datapoints):    
                data.append(datapoints)
            
    return (columns, data)
    
def parse_res_grid(name):
    #these resource grids are stored in a screwy format.
    #to get the first one out of a file, it is best to read
    #the first ny numeric lines out of a file and then just
    #delete the damned thing.
    
    fname = 'data/resource_'+name+'.m'
    f = open(fname)
    
    data = f.read()
    match = re.search(         re.compile('res[^\n]*\.\.\.\n([^\]]*)\n\][^\]]$'),data        )

    if not match:
        raise Exception('nogrid')
    file_keep = data[match.start():]
    a = match.group(1).strip().split('\n')
    a = [ i.strip().split(' ') for i in a]
    a = array(a, float)


    f.close()
    
    prune_file = True
    if prune_file:
        f = open(fname,'w')
        f.write(file_keep)
        f.close()
    
    return a

def save_genome(genesis, genome, fname):
    data = open(genesis).read()
    instructions = re.search(re.compile('INST_SET (\S+)'),data).group(1)    
    ilines = open(instructions).readlines()

    new_org = ''
    
    instr_keys = {}
    letters = list('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')[::-1]
    for l in ilines:
        if not l.strip(): continue
        if l[0] == '#': continue
        match = re.match(re.compile('\S+'),l)
        if not match:
            break

        instr = match.group()
        letter = letters.pop()
        instr_keys[letter] = instr
    
    new_org = new_org + '#Genome synthesized in python from a strand\n'
    for letter in list(genome):
        new_org += instr_keys[letter]+'\n'

    newfile = open(fname,'w')
    newfile.write(new_org)
    newfile.close
    return fname
        

    
        
def org_sequence(instructions, organism):
    ilines = open(instructions).readlines()
    olines = open(organism).readlines()
    
    instr_keys = {}
    
    letters = list('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')[::-1]
    for l in ilines:
        if not l.strip(): continue
        if l[0] == '#': continue
        match = re.match(re.compile('\S+'),l)
        if not match:
            break

        instr = match.group()
        letter = letters.pop()
        instr_keys[instr] = letter
    
    out = ''
    for l in olines:
        if not l.strip(): continue
        if l[0] == '#': continue
        match = re.match(re.compile('\S+'),l)
        if not match:
            break
        out = out+instr_keys[match.group()]
        
    return out
    


def resource_lines( names, opts):
    lines =[]
    n = len(names)
    for i in range(n):
        opts_str = ':'.join([ '='.join(elt) for elt in opts[i]])
        name=names[i]
        rec_str = 'RESOURCE ' + ':'.join([name,opts_str])
        lines.append(rec_str)
    return lines

#require a [N,NOPT,2] array for both process_opts and requisite opts
def reaction_lines( names, tasks, 
               process_opts = None ,
               requisite_opts = None):
    lines = []
    n = len(names)
    for i in range(n):
        name = names[i]
        task = tasks[i]
        rxn_str = 'REACTION ' + name + ' ' + task
        
        if process_opts:
            procopts = ':'.join([' process',':'.join(['='.join(elt) for elt in process_opts[i]])])
            rxn_str += procopts
        
        if requisite_opts:
            reqopts = ':'.join([' requisite',':'.join(['='.join(elt) for elt in requisite_opts[i]])])
            rxn_str += reqopts

        lines.append(rxn_str)
    return lines
    


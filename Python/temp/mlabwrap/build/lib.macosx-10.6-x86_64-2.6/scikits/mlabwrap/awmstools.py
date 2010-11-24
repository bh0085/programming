#############################################################################
################## awmstools : Common functions for python ###################
##############################################################################
##
## o author: Alexander Schmolck (A.Schmolck@gmx.net)
## o created: 2000-04-08T15:52:17+00:00
## o last changed: $Date: 2007/01/29 17:50:59 $
## o license: see file LICENSE
## o keywords: python, helper functions
## o requires: python >= 2.3
## o FIXME:
##   - DefaultDict
##   - set-operations (and dict variants) semi-upkludged to n-arity
##   - iterstuff and other new fixme's (need to load from itertools, if av.)
##   - completely rewrite Indenter interface to use += overloading instead
##   - `silentlyRunProcess` and `readProcess` are unix-only
## o TODO:
##   - sublis, position, find etc. like stuff
##   - curry function
##   - window that uses zip?
##   - saveVars etc. should have `silent` option or so
##   - not all functions are tested rigorously yet
##     * the set functions (union etc.) have been superficially tested
##   - put text-specific stuff in new module ?
##   - look at merge (and other older list functions)
##   - unify testing
##
## Sorted in inverse order of uselessness :) The stuff under EXPERIMENTAL is
## just that: experimental. Expect it not to work, or to disappear or to be
## incompatibly modified in the future. The rest should be fairly stable.

## (query-replace-regexp "i\\(sort\\|reverse\\|shuffle\\|concat\\|rotate\\|append\\|extend\\|update\\)" "ip\\1")
## perl -i -pe 's/\bi(sort|reverse|shuffle|concat|rotate|append|extend|update)\b/ip\1/g' **/*.py
"""A collection of various convenience functions and classes, small utilities
   and 'fixes'.

   Some just save a little bit of typing (`mkDict`, `ipsort`), others are
   things that seem to have been forgotten in the standard libraries
   (`binarySearch`) that have a strange behavior (os.path.splitext). Apart
   from several general purpose utilities for lists (`flatten`), dicts
   (`DefaultDict`) or iterables in general (`unique`, `union`,
   `xgroup` etc.) there are also more special purpose utilities such as
   various handy functions and classes for writing scripts (`email`, `DryRun`,
   `runInfo`) or for debugging (`makePrintReturner`).

   
"""
from __future__ import division
__docformat__ = "restructuredtext en"
__revision__ = "$Id: awmstools.py,v 1.27 2007/01/29 17:50:59 aschmolc Exp $"
__version__  = "0.8"
__author__   = "Alexander Schmolck (A.Schmolck@gmx.net)"
import codecs
import types, re, sys, os, popen2, operator, copy
import cPickle
import bisect
import smtplib
import time
import math
import inspect, new
import getpass
try: set # python 2.3 compatibility
except NameError: from sets import Set as set

from itertools import *

#FIXME reloading
__unique = object()


# this is for doctest
__test__ = {}

#_. FIXES
# Fixes for things in python I'd like to behave differently

def ignoreErrors(func, *args, **kwargs):
    """
    >>> ignoreErrors(int, '3')
    3
    >>> ignoreErrors(int, 'three')
    
    """
    try:    return func(*args, **kwargs)
    except Exception: return None

def rexGroups(rex):
    """Return the named groups in a regular expression (compiled or as string)
       in occuring order.

       >>> rexGroups(r'(?P<name>\w+) +(?P<surname>\w+)')
       ('name', 'surname')
       
    """
    if isinstance(rex,basestring): rex = re.compile(rex)
    return zip(*sorted([(n,g) for (g,n) in rex.groupindex.items()]))[1]
    
def iterable(obj):
    """Test if `obj` is iterable.
    
    >>> iterable(1)
    False
    >>> iterable([1])
    True
    """
    try: len(obj);    return True
    except Exception: return False


class IndexMaker(object):
    """Convinience class to make slices etc. that can be used for creating
       indices (mainly because using `slice` is a PITA).

    Examples:

    >>> range(4)[indexme[::-1]] == range(4)[::-1] == [3, 2, 1, 0]
    True
    >>> indexme[::-1]
    slice(None, None, -1)
    >>> indexme[0,:]
    (0, slice(None, None, None))
    """
    def __getitem__(self, a): return a
indexme = IndexMaker()


# A shortcut for 'infinite' integer e.g. for slicing: ``seq[4:INFI]`` as
# ``seq[4:len(seq)]`` is messy and only works if `seq` isn't an expression
INFI = sys.maxint
# real infinity
INF = 1e999999


class Empty(object):
    r"""Just an empty class."""
    pass                   

class Result(object):
    """Circumvent python's lack of assignment expression (mainly useful for
       writing while loops):

        >>> import re
        >>> s = 'one 2 three 4 five 6'
        >>> findNumber = Result(re.compile('\d+').search)
        >>> while findNumber(s):
        ...     match = findNumber.result
        ...     print 'found', `match.group(0)`, 'at position', match.start()
        ...     s = s[match.end():]
        ...
        found '2' at position 4
        found '4' at position 7
        found '6' at position 6
    """
    def __init__(self, func):
        self.func = func
    def __call__(self,*args,**kwargs):
        self.result = self.func(*args,**kwargs)
        return self.result
    

def div(a,b):
    """``div(a,b)`` is like ``a // b`` if ``b`` devides ``a``, otherwise
    an `ValueError` is raised.
    
    >>> div(10,2)
    5
    >>> div(10,3)
    Traceback (most recent call last):
    ...
    ValueError: 3 does not divide 10
    """
    res, fail = divmod(a,b)
    if fail:
        raise ValueError("%r does not divide %r" % (b,a))
    else:
        return res


# XXX: add a file mixin (and similar thingies)
def mixInto(target, mixin):
    r"""Extends class `target` with the functionality provided by `mixin`."""
    target.__bases__ = (list(target.__bases__) + mixin)

def sort(seq, cmpfunc=None, key=None, reverse=None):
    r"""Return a sorted *copy* of `seq`.
    Parameters:
    
     - `seq`: any iterable type, whose constructor takes a list as argument.
     - `cmpfunc`: comparison function to be used for sorting, defaults to
                 `cmp`.1
    """
    return ipsort(list(seq), cmpfunc, key, reverse)
# XXX for python < 2.4 
try:
    sorted
except NameError:
    sorted = sort
__test__['sort'] = r"""
>>> l = [3,9,1]
>>> sort(l)
[1, 3, 9]
>>> l
[3, 9, 1]
>>> sort(l, lambda x,y: cmp(y,x))
[9, 3, 1]
>>> sort(tuple(l), lambda x,y: cmp(y,x))
[9, 3, 1]
"""

#FIXME untested
def ipsort(l, cmpfunc=None, key=None, reverse=False):
    r"""Sort list `l` in-place and return the result.
    >>> ipsort([1,-2,3],key=abs)
    [1, -2, 3]
    """
    if key:
        if cmpfunc is None: cmpfunc = operator.lt
        cmpfunc = (lambda c=cmpfunc:(lambda x,y: c(key(x), key(y))))()
    if cmpfunc:
        l.sort(cmpfunc)
    else:
        l.sort()
    if reverse: l.reverse()
    return l

__test__['ipsort'] = r"""
>>> l = [3,9,1]
>>> ipsort(l)
[1, 3, 9]
>>> l
[1, 3, 9]
"""

def remove(l, item):
    """Like ``l[:].remove(item)`` but returns the new list/set.
    
    >>> l = [1, 1, 3]
    >>> remove(l, 1)
    [1, 3]
    >>> l
    [1, 1, 3]
    >>> s = set([1])
    >>> remove(s, 1)
    set([])
    >>> s
    set([1])
    """
    res = copy.copy(l)
    res.remove(item)
    return res

#FIXME add iremove

#FIXME should we be clever here ??? not the same behavior as 2.4's reversed
def reverse(seq):
    r"""Return a reversed *copy* of `seq`.
    Parameters:
    
     - `seq`: any iterable type, whose constructor takes a list as
         argument. Strings (`str` and `unicode`) are receive special
         treatment to ensure the expected result.
        
    Examples:
    
    >>> reverse("abcd")
    'dcba'
    >>> reverse((1,2,3))
    (3, 2, 1)
    >>> reverse([1,2,3])
    [3, 2, 1]
    """
    if isinstance(seq, list):
        return ipreverse(seq[:])
    elif isString(seq):
        return seq[0:0].join(ipreverse(list(seq))) # seq[0:0] == ""*or*  u"" 
    else:
        return type(seq)(ipreverse(list(seq)))

__test__['reverse'] = r'''
>>> l = [1,2,3]
>>> reverse(l)
[3, 2, 1]
>>> l
[1, 2, 3]
'''


#_ :ipreverse

def ipreverse(l):
    r"""Same as ``l.reverse()``, but returns `l`."""
    l.reverse()
    return l
__test__['lreverse'] = r'''
>>> l = [1,2,3]
>>> ipreverse(l) is l
True
>>> l
[3, 2, 1]
'''


def ipshuffle(l, random=None, int=int):
    r"""Shuffle list `l` inplace and return it."""
    import random as _random
    _random.shuffle(l, random)
    return l

__test__['ipshuffle'] = r'''
>>> l = [1,2,3]
>>> ipshuffle(l, lambda :0.3) is l
True
>>> l
[2, 3, 1]
>>> l = [1,2,3]
>>> ipshuffle(l, lambda :0.4) is l
True
>>> l
[3, 1, 2]
'''


def shuffle(seq, random=None,int=int):
    r"""Return shuffled *copy* of `seq`."""
    if isinstance(seq, list):
        return ipshuffle(seq[:], random, int)
    elif isString(seq):
        return seq[0:0].join(ipshuffle(list(seq)),random,int) # seq[0:0] == ""*or*  u"" 
    else:
        return type(seq)(ipshuffle(list(seq),random,int))

__test__['shuffle'] = r'''
>>> l = [1,2,3]
>>> shuffle(l, lambda :0.3)
[2, 3, 1]
>>> l
[1, 2, 3]
>>> shuffle(l, lambda :0.4)
[3, 1, 2]
>>> l
[1, 2, 3]
'''

# s = open(file).read() would be a nice shorthand -- unfortunately it doesn't
# work (because the file is never properly closed, at least not under
# Jython). Thus:

#_ :withFile
# FIXME UNTESTED
def withFile(file, func, mode='r', expand=False):
    """Pass `file` to `func` and ensure the file is closed afterwards. If
       `file` is a string, open according to `mode`; if `expand` is true also
       expand user and vars.
    """
    if isString(file):
        if expand: file = os.path.expandvars(os.path.expanduser(file))
        file = open(file, mode)
    try:      return func(file)
    finally:  file.close()

#_ :slurpIn
def slurpIn(file, binary=False, expand=False):
    r"""Read in a complete file `file` as a string
    Parameters:
    
     - `file`: a file handle or a string (`str` or `unicode`).
     - `binary`: whether to read in the file in binary mode (default: False).
    """

    if isString(file):
        if expand: file = os.path.expandvars(os.path.expanduser(file))
        file = open(file, ("r", "rb")[bool(binary)])
    try:
        result = file.read()
        return result
    finally:
        file.close()


#_ :slurpInLines

def slurpInLines(file, expand=False):
    r"""Read in a complete file (specified by a file handler or a filename
    string/unicode string) as list of lines"""

    if isString(file):
        if expand: file = os.path.expandvars(os.path.expanduser(file))
        file = open(file)
    try:
        result = file.readlines()
        return result
    finally:
        file.close()

#_ :slurpInChompedLines

def slurpInChompedLines(file, expand=False):
    r"""Convinience function for ``chompLines(slurpInLines(file)``"""

    return chompLines(slurpInLines(file,expand))

#_ :spitOut

def spitOut(s, file, binary=False, expand=False):
    r"""Write string `s` into `file` (which can be a string (`str` or
    `unicode`) or a `file` instance)."""
    if isString(file):
        if expand: file = os.path.expandvars(os.path.expanduser(file))
        file = open(file, "w" + ("", "b")[binary])
    try:     file.write(s)
    finally: file.close()

    
#_ :spitOutLines

def spitOutLines(lines, file, expand=False):
    r"""Write all the `lines` to `file` (which can be a string/unicode or a
       file handler)."""

    if isString(file):
        if expand: file = os.path.expandvars(os.path.expanduser(file))
        file = open(file, "w")
    try:     file.writelines(lines)
    finally: file.close()

#_ :readProcess

# FIXME hack
def _fixupCmdStr(cmd, args):
    escape = lambda s: '"%s"' % re.sub(r'\"$!', r'\\\1',s) #FIXME
    return " ".join([cmd] + map(escape, args))
#FIXME should use new subprocess module
def readProcess(cmd, *args):
    r"""Similar to `os.popen3`, but returns 2 strings (stdin, stdout) and the
    exit code (unlike popen2, exit is 0 if no problems occured (for some
    bizarre reason popen2 returns None... <sigh>). FIXME: only works for
    UNIX!
    """
    BUFSIZE=1024
    import select
    cmdStr = _fixupCmdStr(cmd, args)
    popen = popen2.Popen3(cmdStr, capturestderr=True)
    which = {id(popen.fromchild): [],
             id(popen.childerr):  []}
    select = Result(select.select)
    read   = Result(os.read)
    try:
        popen.tochild.close() # XXX make sure we're not waiting forever
        while select([popen.fromchild, popen.childerr], [], []):
            readSomething = False
            for f in select.result[0]:
                while read(f.fileno(), BUFSIZE):
                    which[id(f)].append(read.result)
                    readSomething = True
            if not readSomething:
                break
        out, err = ["".join(which[id(f)])
                    for f in [popen.fromchild, popen.childerr]]
        exit = popen.wait()
    finally:
        try:
            popen.fromchild.close()
        finally:
            popen.childerr.close()
    return out or "", err or "", exit
    
    
#_ :silentlyRunProcess
def silentlyRunProcess(cmd,*args):
    """Like `runProcess` but stdout and stderr output is discarded. FIXME: only
       works for UNIX!"""
    return readProcess(cmd,*args)[2]

def runProcess(cmd, *args):
    """Run `cmd` (which is searched for in the executable path) with `args` and
    return the exit status. 

    In general (unless you know what you're doing) use::

     runProcess('program', filename)

    rather than::

     os.system('program %s' % filename)

    because the latter will not work as expected if `filename` contains
    spaces or shell-metacharacters.

    If you need more fine-grained control look at ``os.spawn*``.
    """
    from os import spawnvp, P_WAIT
    return spawnvp(P_WAIT, cmd, (cmd,) + args)
    
        
#_ :isString
# unfortunately there is no decent way to test whether something is a string
# in python (prior to 2.3 and `basestring` that is)
def isString(obj):
    r"""Return `True` iff `obj` is some type of string (i.e. `str` or
    `unicode`)."""
    return isinstance(obj, basestring)

# ...same for sequences (*AAARGH*)
def isSeq(obj):
    r"""Returns true if obj is a sequence (which does purposefully **not**
    include strings, because these are nefarious pseudo-sequences that mess
    everything up!!!)"""
    return operator.isSequenceType(obj) and not isinstance(obj, (str, unicode))

    
#_ :splitext
# os.path's splitext is EVIL: it thinks that dotfiles are extensions!
def splitext(p):
    r"""Like the normal splitext (in posixpath), but doesn't treat dotfiles
    (e.g. .emacs) as extensions. Also uses os.sep instead of '/'."""

    root, ext = os.path.splitext(p)
    # check for dotfiles
    if (not root or root[-1] == os.sep): # XXX: use '/' or os.sep here???
        return (root + ext, "")
    else:
        return root, ext


#_ : identity

def identity(obj):
    r"Returns its sole argument."
    return obj

#FIXME not fully tested
            
    


#_. LIST MANIPULATION

#FIXME this is rubbish
#_ : concat
def concat(*seqs):
    r"""Concatenate input sequences together.
    
    >>> concat([1,2,3], [4,5], [6,[7,8]])
    [1, 2, 3, 4, 5, 6, [7, 8]]
    >>> concat("2 become", " one")
    '2 become one'
    """
    return reduce(operator.add, seqs)

#FIXME this is rubbish
#_ : ipconcat
def ipconcat(*seqs):
    r"""Concatenate input sequences **in-place** into first ``seqs[0]`` and
    return ``seqs[0]``.
    """
    return reduce(type(seqs[0]).__iadd__, seqs)
__test__['ipconcat'] = r"""
>>> l1, l2, l3 = range(3), range(4,7), range(8, 10)
>>> ipconcat(l1, l2, l3) is l1 and l2 == range(4,7) and l3 == range(8, 10)
True
"""

def bipart(func, seq):
    r"""Like a partitioning version of `filter`. Returns
    ``[itemsForWhichFuncReturnedFalse, itemsForWhichFuncReturnedTrue]``.

    Example:

    >>> bipart(bool, [1,None,2,3,0,[],[0]])
    [[None, 0, []], [1, 2, 3, [0]]]
    """

    if func is None: func = bool
    res = [[],[]]
    for i in seq: res[not not func(i)].append(i)
    return res

#_  ,unzip
def unzip(seq):
    r"""Perform the reverse operation to the builtin `zip` function."""
    return zip(*seq)


#_  ,binarySearch

def binarySearchPos(seq, item, cmpfunc=cmp):
    r"""Return the position of `item` in ordered sequence `seq`, using comparison
    function `cmpfunc` (defaults to ``cmp``) and return the first found
    position of `item`, or -1 if `item` is not in `seq`. The returned position
    is NOT guaranteed to be the first occurence of `item` in `seq`."""

    if not seq:	return -1
    left, right = 0, len(seq) - 1
    if cmpfunc(seq[left],  item) ==  1 and \
       cmpfunc(seq[right], item) == -1:
        return -1
    while left <= right:
        halfPoint = (left + right) // 2
        comp = cmpfunc(seq[halfPoint], item)
        if   comp > 0: right = halfPoint - 1
        elif comp < 0: left  = halfPoint + 1
        else:          return  halfPoint
    return -1

__test__['binarySearchPos'] = r"""
>>> binarySearchPos(range(20), 20)
-1
>>> binarySearchPos(range(20), 1)
1
>>> binarySearchPos(range(20), 19)
19
>>> binarySearchPos(range(20), 0)
0
>>> binarySearchPos(range(1,21,2),4)
-1
>>> binarySearchPos(range(0,20,2), 6)
3
>>> binarySearchPos(range(19, -1, -1), 3, lambda x,y:-cmp(x,y))
16
"""


def binarySearchItem(seq, item, cmpfunc=cmp):
    r""" Search an ordered sequence `seq` for `item`, using comparison function
    `cmpfunc` (defaults to ``cmp``) and return the first found instance of
    `item`, or `None` if item is not in `seq`. The returned item is NOT
    guaranteed to be the first occurrence of item in `seq`."""
    pos = binarySearchPos(seq, item, cmpfunc)
    if pos == -1: raise KeyError("Item not in seq")
    else:         return seq[pos]

#XXX could extend this for other sequence types
def rotate(l, steps=1):
    r"""Rotates a list `l` `steps` to the left. Accepts 
    `steps` > `len(l)` or < 0.
    
    >>> rotate([1,2,3])
    [2, 3, 1]
    >>> rotate([1,2,3,4],-2)
    [3, 4, 1, 2]
    >>> rotate([1,2,3,4],-5)
    [4, 1, 2, 3]
    >>> rotate([1,2,3,4],1)
    [2, 3, 4, 1]
    >>> l = [1,2,3]; rotate(l) is not l
    True
    """
    if len(l):
        steps %= len(l)
        if steps:
            res = l[steps:]
            res.extend(l[:steps])
    return res

def iprotate(l, steps=1):
    r"""Like rotate, but modifies `l` in-place.

    >>> l = [1,2,3]
    >>> iprotate(l) is l
    True
    >>> l
    [2, 3, 1]
    >>> iprotate(iprotate(l, 2), -3)
    [1, 2, 3]

    """
    if len(l):
        steps %= len(l)
        if steps:
            firstPart = l[:steps]
            del l[:steps]
            l.extend(firstPart)
    return l
    

#_  ,merge

# XXX: should do this more efficiently and for more than 2 lists
def merge(list1, list2):
    r"Merges two sorted lists into a sorted list XXX."
    if len(list1) == 1 or len(list2) == 1:
        if list1[0] < list2[0]:
            return list1 + list2
        else:
            return list2 + list1
    if list1[0] < list2[0]:
        return [list1[0]] +  merge(list1[1:], list2)
    else:
        return [list2[0]] +  merge(list2[1:], list1)

#_  ,unique/notUnique

# XXX: could wrap that in try: except: for non-hashable types, or provide an
# identity function parameter, but well... this is fast and simple (but wastes
# memory)
def unique(seq):
    r"""Returns all unique items in `seq` in the *same* order (only works if
    items in `seq` are hashable)."""
    d = {}
    return [d.setdefault(x,x) for x in seq if x not in d]

__test__['unique'] = r"""
>>> unique(range(3)) == range(3)
True
>>> unique([1,1,2,2,3,3]) == range(1,4)
True
>>> unique([1]) == [1]
True
>>> unique([]) == []
True
>>> unique(['a','a']) == ['a']
True
"""

def notUnique(seq, reportMax=INFI):
    """Returns the elements in `seq` that aren't unique; stops after it found
    `reportMax` non-unique elements.

    Examples:
    
    >>> notUnique([1,1,2,2,3,3])
    [1, 2, 3]
    >>> notUnique([1,1,2,2,3,3],1)
    [1]
    """
    hash = {}
    result = []
    if reportMax < 1:
        raise ValueError("`reportMax` must be >= 1 and is %r" % reportMax)
    for item in seq:
        count = hash[item] = hash.get(item, 0) + 1
        if count > 1:
            result.append(item)
            if len(result) >= reportMax:
                break
    return result
__test__['notUnique'] = r"""
>>> notUnique(range(3))
[]
>>> notUnique([1])
[]
>>> notUnique([])
[]
>>> notUnique(['a','a'])
['a']
>>> notUnique([1,1,2,2,3,3],2)
[1, 2]
>>> notUnique([1,1,2,2,3,3],0)
Traceback (most recent call last):
[...]
ValueError: `reportMax` must be >= 1 and is 0
"""


#_  ,unweave
def unweave(seq, n=2):
    r"""Divide a `seq` in `n` subsequences, so that every nth element belongs to
    subsequence `n`.

    Example:
    
    >>> unweave((1,2,3,4,5), 3)
    [[1, 4], [2, 5], [3]]
    """
    res = [[] for i in range(n)]
    i = 0
    for x in seq:
        res[i % n].append(x)
        i += 1
    return res

#_  ,weave


def weave(*iterables):
    r"""weave(seq1 [, seq2] [...]) ->  [seq1[0], seq2[0] ...]. 
    Length of result = ``len(shortest_seq) * number_of_sequences``
    Example:
    
    >>> weave((1,2,3), (4,5,6,'A'), (6,7,8, 'B', 'C'))
    [1, 4, 6, 2, 5, 7, 3, 6, 8]

    also works with iters:

    >>> weave(('there','no', 'censorship'), iter(('is','psu')))
    ['there', 'is', 'no', 'psu']
    """
    iterables = map(iter, iterables)
    try:
        res = []
        while 1: res.extend([it.next() for it in iterables])
    except StopIteration: 
        return res
##     return [s[i] for i in range(min(map(len,seqs)))
##             for s in seqs]




def atIndices(indexable, indices, default=__unique):
    r"""Return a list of items in `indexable` at positions `indices`.

    Examples:
    
    >>> atIndices([1,2,3], [1,1,0])
    [2, 2, 1]
    >>> atIndices([1,2,3], [1,1,0,4], 'default')
    [2, 2, 1, 'default']
    >>> atIndices({'a':3, 'b':0}, ['a'])
    [3]
    """
    if default is __unique:
        return [indexable[i] for i in indices]
    else:
        res = []
        for i in indices:
            try:
                res.append(indexable[i])
            except (IndexError, KeyError):
                res.append(default)
        return res

__test__['atIndices'] = r'''
>>> atIndices([1,2,3], [1,1,0,4])
Traceback (most recent call last):
[...]
IndexError: list index out of range
>>> atIndices({1:2,3:4}, [1,1,0,4])
Traceback (most recent call last):
[...]
KeyError: 0
>>> atIndices({1:2,3:4}, [1,1,0,4], 'default')
[2, 2, 'default', 'default']
'''

#_  , GENERATORS


#XXX: should those have reduce like optional end-argument?
def window(iterable, n=2, s=1):
    r"""Move an `n`-item (default 2) windows `s` steps (default 1) at a time
    over `iterable`.
    
    Examples:
    
    >>> list(window(range(6),2))
    [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]
    >>> list(window(range(6),3))
    [(0, 1, 2), (1, 2, 3), (2, 3, 4), (3, 4, 5)]
    >>> list(window(range(6),3, 2))
    [(0, 1, 2), (2, 3, 4)]
    >>> list(window(range(5),3,2)) == list(window(range(6),3,2))
    True
    """
    assert n >= s
    last = []
    for elt in iterable:
        last.append(elt)
        if len(last) == n: yield tuple(last); last=last[s:]
#FIXME
xwindow = window
def group(iterable, n=2):
    r"""Iterate `n`-wise (default pairwise)  over `iter`.
    Examples:
    
    >>> for (first, last) in group("Akira Kurosawa John Ford".split()):
    ...     print "given name: %s surname: %s" % (first, last)
    ... 
    given name: Akira surname: Kurosawa
    given name: John surname: Ford
    >>>
    >>> # both contain the same number of pairs
    >>> list(group(range(9))) == list(group(range(8)))
    True
    >>> # with n=3
    >>> list(group(range(9), 3))
    [(0, 1, 2), (3, 4, 5), (6, 7, 8)]
    """
    assert n>0    # ensure it doesn't loop forever
    iterable = iter(iterable)
    perTuple = xrange(n)
    while 1:
        yield tuple([iterable.next() for i in perTuple])
xgroup = group #FIXME
xrepeat = repeat #FIXME
xcycle = cycle #FIXME
#FIXME: throw that away
def iterate(func, arg):
    r"""
    >>> xseq(iterate(lambda x: x**2, 3))[:6]
    (3, 9, 81, 6561, 43046721, 1853020188851841L)
    """
    while 1:
        yield arg
        arg = func(arg)

def dropwhilenot(func, iterable):
    iterable = iter(iterable)
    for x in iterable:
        if func(x): break
    else: return
    yield x
    for x in iterable:
        yield x
    
    
    
        

def stretch(seq, n=2):
    r"""Repeat each item in `seq` `n` times.

    Example:
    
    >>> list(stretch(range(3), 2))
    [0, 0, 1, 1, 2, 2]
    """
    times = range(n)
    for item in seq:
        for i in times: yield item





def paddedIter(iterable, padding=None):
    r"""Return elements of `iterable` (any iterable), then yield `padding`
    forever.
    
    Example:
    
    >>> gen = paddedIter(["full", "half empty"], "empty")
    >>> [gen.next() for i in range(4)]
    ['full', 'half empty', 'empty', 'empty']
    """
    iterable = iter(iterable)
    try:
        while 1: yield iterable.next()
    except StopIteration:
        while 1: yield padding
        

def isplitAt(iterable, indices):
    r"""Yield chunks of `iterable`, split at the points in `indices`:
    
    >>> [l for l in isplitAt(range(10), [2,5])]
    [[0, 1], [2, 3, 4], [5, 6, 7, 8, 9]]

    splits past the length of `iterable` are ignored:
    
    >>> [l for l in isplitAt(range(10), [2,5,10])]
    [[0, 1], [2, 3, 4], [5, 6, 7, 8, 9]]

    
    """
    iterable = iter(iterable)
    now = 0
    for to in indices:
        try:
            res = []
            for i in range(now, to): res.append(iterable.next())
        except StopIteration: yield res; return
        yield res
        now = to
    res = list(iterable)
    if res: yield res
          

__test__['isplitAt'] = r"""
>>> [l for l in isplitAt(range(10), [1,5])]
[[0], [1, 2, 3, 4], [5, 6, 7, 8, 9]]
>>> [l for l in isplitAt(range(10), [2,5,10])]
[[0, 1], [2, 3, 4], [5, 6, 7, 8, 9]]
>>> [l for l in isplitAt(range(10), [2,5,9])]
[[0, 1], [2, 3, 4], [5, 6, 7, 8], [9]]
>>> [l for l in isplitAt(range(10), [2,5,11])]
[[0, 1], [2, 3, 4], [5, 6, 7, 8, 9]]

"""
        
        
def ipappend(lst, item):
    r"""Destructively append `item` to list `lst`.

    Examples:
    
    >>> a = [4]
    >>> ipappend(a, 3)
    [4, 3]
    >>> a
    [4, 3]
    """
    lst.append(item)
    return lst

def ipextend(lst, seq):
    r"""Destructively extend `seq1` with dict `seq2`."""
    lst.extend(seq)
    return lst

__test__['ipextend'] = r"""
>>> a = [3, 4]
>>> ipextend(a, [3])
[3, 4, 3]
>>> a
[3, 4, 3]
"""

def ipupdate(d, e):
    r"""Destructively update dict `d` with dict `e`."""
    d.update(e)
    return d

__test__['ipupdate'] = r"""
>>> d = {1:2}
>>> ipupdate(d, {3:4})
{1: 2, 3: 4}
>>> d
{1: 2, 3: 4}
"""

def ipadd(s, x):
    r"""Destructively add `x` to set `s`."""
    s.add(x)
    return s
__test__['ipadd'] = r"""
>>> s = set([])
>>> ipadd(s, 1)
set([1])
>>> s
set([1])
"""

def add(s, x):
    r"""Return new set with `x` added to `s`."""
    res = s.copy()
    res.add(x)
    return res
__test__['add'] = r"""
>>> s = set([])
>>> add(s, 1)
set([1])
>>> s
set([])
"""



#_. HASH MANIPULATION


#_ :makeDict

def mkDict(**kwargs):
    r"""Convinience function to create a `dict`.
    
    >>> mkDict(a=1,b=2,c='three') == {'a':1, 'b':2,'c':'three'}
    True
    """
    return kwargs

class DefaultDict(dict):
    r"""Dictionary with a default value for unknown keys."""
    def new(cls, default, noCopies=False):
        self = cls()
        self.default = default
        if noCopies:
            self.noCopies = True
        else:
            self.noCopies = False
        return self
    new = classmethod(new)
    def __getitem__(self, key):
        r"""If `self.noCopies` is `False` (default), a **copy** of
           `self.default` is returned by default.
        """              
        if key in self: return self.get(key)
        if self.noCopies: return self.setdefault(key, self.default)
        else:             return self.setdefault(key, copy.copy(self.default))


## class DefaultDict(object):
##     r"""Dictionary with a default value for unknown keys."""
##     def __init__(self, default, noCopies=False):
##         self.d = {}
##         self.default = default
##         if noCopies:
##             self.noCopies = True
##         else:
##             self.noCopies = False
##     def __getattr__(self, name):
##         attr = getattr(self.d, name)
##         setattr(self, name, attr)
##         return attr
##     def __getitem__(self, key):
##         r"""If `self.noCopies` is `False` (default), a **copy** of
##            `self.default` is returned by default.
##         """
##         d = self.d
##         if key in d:      return d.get(key)
##         if self.noCopies: return d.setdefault(key, self.default)
##         else:             return d.setdefault(key, copy.copy(self.default))


__test__['DefaultDict'] = r"""
>>> dd = DefaultDict.new([1])
>>> dd[2]
[1]
>>> dd[2][0] = 3
>>> dd[2]
[3]
>>> dd[1]
[1]
>>> dd = DefaultDict.new([1], 1)
>>> dd[2]
[1]
>>> dd[2][0] = 3
>>> dd[1]
[3]
"""

#FIXME deprecated; for backwards compatibility only
itemsToHash = dict


# XXX should we use copy or start with empty dict? former is more generic
# (should work for other dict types, too)
def update(d, e):
    """Return a copy of dict `d` updated with dict `e`."""
    res = copy.copy(d)
    res.update(e)
    return res

def invertDict(d, allowManyToOne=False):
    r"""Return an inverted version of dict `d`, so that values become keys and
    vice versa. If multiple keys in `d` have the same value an error is
    raised, unless `allowManyToOne` is true, in which case one of those
    key-value pairs is chosen at random for the inversion.

    Examples:
    
    >>> invertDict({1: 2, 3: 4}) == {2: 1, 4: 3}
    True
    >>> invertDict({1: 2, 3: 2})
    Traceback (most recent call last):
      File "<stdin>", line 1, in ?
    ValueError: d can't be inverted!
    >>> invertDict({1: 2, 3: 2}, allowManyToOne=True).keys()
    [2]
    """
    res = dict(zip(d.values(), d.keys()))
    if not allowManyToOne and len(res) != len(d):
        raise ValueError("d can't be inverted!")
    return res


#_. LISP LIKES

#AARGH strings are EVIL...
def xflatten(seq, isSeq=isSeq):
    r"""Like `flatten` but lazy."""
    for elt in seq:
        if isSeq(elt):
            for x in xflatten(elt, isSeq):
                yield x
        else:
            yield elt

__test__['xflatten'] = r"""
>>> type(xflatten([]))
<type 'generator'>
>>> xflatten([]).next()
Traceback (most recent call last):
  File "<console>", line 1, in ?
StopIteration
>>> (a,b,c) = xflatten([1,["2", ([3],)]])
>>> (a,b,c) == (1, '2', 3)
True

"""
 
def flatten(seq, isSeq=isSeq):
    r"""Returns a flattened version of a sequence `seq` as a `list`.
    Parameters:
    
     - `seq`: The sequence to be flattened (any iterable).
     - `isSeq`: The function called to determine whether something is a
        sequence (default: `isSeq`). *Beware that this function should
        **never** test positive for strings, because they are no real
        sequences and thus cause infinite recursion.*

    Examples:
    
    >>> flatten([1,[2,3,(4,[5,6]),7,8]])
    [1, 2, 3, 4, 5, 6, 7, 8]
    >>> # flaten only lists
    >>> flatten([1,[2,3,(4,[5,6]),7,8]], isSeq=lambda x:isinstance(x, list))
    [1, 2, 3, (4, [5, 6]), 7, 8]
    >>> flatten([1,2])
    [1, 2]
    >>> flatten([])
    []
    >>> flatten('123')
    ['1', '2', '3']
    """
    return [a for elt in seq
            for a in (isSeq(elt) and flatten(elt, isSeq) or
                      [elt])]


def countIf(predicate, seq):
    r"""Count all the elements of `seq` for which `predicate` returns true."""
    return reduce(lambda x,y: x + bool(predicate(y)), seq, 0)

__test__['countIf'] = r"""
>>> countIf(bool, range(10))
9
>>> countIf(bool, range(-1))
0
"""



def union(seq1=(), *seqs):
    r"""Return the set union of `seq1` and `seqs`, duplicates removed, order
    random.

    Examples:
    >>> union()
    []
    >>> union([1,2,3])
    [1, 2, 3]
    >>> union([1,2,3], {1:2, 5:1})
    [1, 2, 3, 5]
    >>> union((1,2,3), ['a'], "bcd")
    ['a', 1, 2, 3, 'd', 'b', 'c']
    >>> union([1,2,3], iter([0,1,1,1]))
    [0, 1, 2, 3]

    """
    if not seqs: return list(seq1)
    res = setify(seq1)
    for seq in seqs:
        res.update(setify(seq))
    return res.keys()

def setify(iterable):
    r"""Transform `iterable` into a "set", i.e. the keys of a `dict`.
    """
    return dict(zip(iterable, xrepeat(True)))
__test__['setify'] = r""">>> ipsort(setify([1,2,3]).keys())
[1, 2, 3]
"""

# by making this a function, we can accomodate for new types later
def isSet(obj):
    return isinstance(obj,dict)




def intersection(iterable1=(), *iterables):
    r"""Return the intersection of `iterable1`, `iterable2`, order random.

    Examples:
    >>> intersection()
    []
    >>> intersection([1,2,3])
    [1, 2, 3]
    >>> intersection([1,2,3], [3,4])
    [3]
    >>> intersection([1,2,3], (0,4))
    []
    >>> intersection({1:3, 2:4}, [1,2])
    [1, 2]
    >>> intersection([1,2,3], [4,5,6,1,2], [4,5,1,2])
    [1, 2]
    """
    if len(iterables) == 0:
        return list(iterable1)
    #FIXME should rewrite this as loop
    elif len(iterables) > 1:
        return intersection(iterable1, intersection(iterables[0], *iterables[1:]))
    if isSet(iterable1):
        d = iterable1
    else:
        # XXX should time how expensive funcall is here...
        d = setify(iterable1)
    return [elt for elt in iterables[0] if elt in d]



def without(seq1, seq2):
    r"""Return a list with all elements in `seq2` removed from `seq1`, order
    preserved.

    Examples:

    >>> without([1,2,3,1,2], [1])
    [2, 3, 2]
    """
    if isSet(seq2): d2 = seq2
    else: d2 = setify(seq2)
    return [elt for elt in seq1 if elt not in d2]



def setDifference(seq1=(), *seqs):
    r"""Return a list that is the set difference of iterables `seq1` and
    `seq2`, duplicates removed, order random.
    
    Example:
    >>> setDifference()
    []
    >>> ipsort(setDifference([1,2,3,"a", 4.5,1,1], {"a":3, 3:"a"}))
    [1, 2, 4.5]
    """
    return without(setify(seq1), union(*seqs)) #FIXME this is inefficient


def isSubset(seq1, seq2):
    r"""Return `True` iff all elements in `seq1` are completely contained in
    `seq2`.

    Examples:

    >>> isSubset({}, [1,2,3])
    True
    >>> isSubset([1,2,3], {})
    False
    >>> isSubset(["hungry", "alone"], ["satiated", "girlfriend"])
    False
    >>> isSubset(["satiated"], ["satiated", "girlfriend"])
    True
    >>> isSubset(["satiated", "alone"], ["satiated", "girlfriend"])
    False
    """
    try:
        if len(seq1) > len(seq2): return False
    except TypeError: pass
    seq2 = setify(seq2)
    for item in seq1:
        if item not in seq2:
            return False
    return True


#XXX this is fairly inefficient but general (works for lazy and unlimited
#sequences). Should presumably add special case for len(seqs) == 1
def some(predicate, *seqs):
    iterables = map(iter, seqs)
    try:
        while 1:
            bol = predicate(*[iterable.next() for iterable in iterables])
            if bol: return bol
    except StopIteration: return False
        

#XXX see comments to some
def every(predicate, *iterables):
    r"""Like `some`, but only returns `True` if all the elements of `iterables`
    satisfy `predicate`.

    Examples:
    >>> every(bool, [])
    True
    >>> every(bool, [0])
    False
    >>> every(bool, [1,1])
    True
    >>> every(operator.eq, [1,2,3],[1,2])
    True
    >>> every(operator.eq, [1,2,3],[0,2])
    False
    """
    iterables = map(iter, iterables)
    try:
        while predicate(*[iterable.next() for iterable in iterables]): pass
        return False
    except StopIteration: return True


#_. PERL LIKES

#_ :chomp

# XXX: the 

def chomp(s):
    r"""Discards all trailing newlines in string `s`. Accepts empty
    string."""

    while s[-1:] == "\n":
        s = s[:-1]
    return s
__test__['chomp'] = r"""
>>> chomp('foobar\n\nf') == 'foobar\n\nf'
True
>>> chomp('foobar\n\n') == 'foobar'
True
"""

def xchompLines(lines):
    r"""Like `chompLines`, but lazily iterates over a list of strings."""
    
    for line in lines:
        if line[-1:] == "\n":
            line = line[:-1]
        yield line
        
__test__['xchompLines'] = r"""
>>> list(xchompLines(['\n', 'foo\n', 'foobar\n\nf']))
['', 'foo', 'foobar\n\nf']
>>> xchompLines(['foo\n', '3', 'foobar\n\nf']).next()
'foo'
"""
    
#_ :chompLines

def chompLines(lines):
    r"""Like `chomp`, but takes a list of strings which it alters
    **destructively** rather then a single string.  It only exits for
    efficiency reasons."""
    for i,line in enumerate(lines):
        if line[-1:] == "\n":
            lines[i] = line[:-1]
    return lines
        
__test__['chompLines'] = r"""
>>> chompLines(['\n', 'foo\n', 'foobar\n\nf'])
['', 'foo', 'foobar\n\nf']
"""


#_. TIME AND DATE HANDLING

# date string convinience functions

#_ :isoDateStr

#FIXME local time...
def isoDateStr(secs=None):
    r"""Return yyyy-mm-dd date string (as in "ISO 8601",
    http://www.w3.org/TR/NOTE-datetime) of `secs` seconds since epoch in
    localtime. Convenience function.

    Parameters:
    
     - `secs`: seconds since epoch of the date to be generated (default: use
       current time).

    Example:

    under unix:

    >>> isoDateStr(0)
    '1970-01-01'
    """
    if secs is None:secs = time.time();
    return time.strftime("%Y-%m-%d", time.localtime(secs))


#_ :isoDateTimeStr
#FIXME: changed needs testing
def isoDateTimeStr(secs=None, addT=False, tzInfo=None):
    r"""Return ``yyyy-mm-dd HH:MM:SS`` date string (as in ISO 8601, see
    http://www.w3.org/TR/NOTE-datetime) of `secs` seconds since epoch in
    localtime. Convinience Function.

    Parameters:
    
     - `secs`: seconds since epoch of the date to be generated (default: use
            current time).
        
     - `addT`: insert a 'T' between date and time (equally standard-compliant
               and useful to generate filenames etc.).
        
     - `tzInfo`: whether to take the timezone into account (default:
        implicitly use localtime)
        
        Possible Values:
         - ``"utc"`` create ``yyyy-mm-dd HH:MM:SSZ`` that uses Coordinated
           Universal Time (UTC, thanks to the French).
         - ``"offset"`` create ``yyyy-mm-dd HH:MM:SS(+/-)HH:MM`` where
           ``HH:MM`` is the the offset of the local time zone to UTC.

    """

    if secs is None: secs = time.time();
    if addT: dateFormatStr = "%Y-%m-%dT%H:%M:%S"
    else:    dateFormatStr = "%Y-%m-%d %H:%M:%S"
    timeFunc = time.localtime
    if   tzInfo is None:
        offsetInfo = ""
    elif tzInfo == "utc":
        offsetInfo = "Z"
        timeFunc = time.gmtime
    elif tzInfo == "offset":
        offsetInfo = "%+03d:%02d"  % (time.timezone // 3600, abs(time.timezone // 60))
    else:
        raise ValueError("Illegal vlalue for ``tzInfo``:", tzInfo)
    return time.strftime(dateFormatStr, timeFunc(secs)) + offsetInfo

#FIXME this test only works under GMT (and offset calculations are untest)

__test__['isoDateTimeStr'] = r"""
>>> isoDateTimeStr(0)
'1970-01-01 01:00:00'
>>> isoDateTimeStr(0,1)
'1970-01-01T01:00:00'
>>> isoDateTimeStr(0,1,'utc')
'1970-01-01T00:00:00Z'
"""

# XXX: not strictly a time related function, but well...
def nTimes(*timesAndFuncAndArgs, **kwargs):
    r"""Repeat a function (the second argument) n-times (the first argument),
    passing through all remaining arguments. Useful e.g. for simplistic
    timing.

    Examples:

    >>> nTimes(3, sys.stdout.write, 'hallo\n')
    hallo
    hallo
    hallo
    
    To time how long executing ``func('foo', spam=1)`` a 1000 times takes, you
    would do::

      timeCall(nTimes, 1000, func, 'foo', spam=1)
    
    """
    times, func = timesAndFuncAndArgs[0:2]
    args = timesAndFuncAndArgs[2:]
    for i in xrange(times): func(*args, **kwargs)
        

def timeCall(*funcAndArgs, **kwargs):
    r"""Return the time (in ms) it takes to call a function (the first
    argument) with the remaining arguments and `kwargs`.

    Examples:

    To find out how long ``func('foo', spam=1)`` takes to execute, do:

    ``timeCall(func, foo, spam=1)``
    """
    
    func, args = funcAndArgs[0], funcAndArgs[1:]
    start = time.time()
    func(*args, **kwargs)
    return time.time() - start

__test__['timeCall'] = r"""
>>> round(timeCall(time.sleep, 1))
1.0
"""

#_ :Timer

class TimerError(Exception):pass
# FIXME UNTESTED CHANGES

class Timer:
    r"""General purpose timer:

    >>> t = Timer().start()
    >>> # do something...
    >>> t.stop().getTimeS() # -> 00:00:12
    '00:00:00'
    """
    def __init__(self, timerStr=None):
        self.reset()
        if timerStr is not None:
            if timerStr.startswith('running: '):
                timerStr = timerStr.replace('running: ','')
                running = True
            else:
                running = False
            if not len(timerStr) == 8 and (
                timerStr[2] == timerStr[5] == ":"):
                raise ValueError("illegal time string: %s" % s)
            h,m,s = map(int, timerStr.split(":"))
            delta = h*3600 + m * 60 + s            
            self.startT = time.time() - delta
            if not running:
                self.stopT = self.startT + delta
    def __repr__(self):
        name = self.__class__.__name__
        if not self.hasStarted():
            return "%s()" % name
        elif not self.hasStopped():
            return "%s(%r)" % (name, "running: " + self.getTimeS())
        else:
            return "%s(%r)" % (name, self.getTimeS())
    def __str__(self):
        if not self.hasStarted():
            return "Not started"
        elif not self.hasStopped():
            return "Running for: %s" %  self.getTimeS()
        else:
            return "Total running time: %s" % self.getTimeS()
    def reset(self):
        self.startT = None
        self.stopT = None
    def start(self):
        if self.hasStarted():
            raise TimerError('Timer already started') #FIXME
        self.startT = time.time()
        return self
    def hasStarted(self):
        return self.startT is not None
    def hasStopped(self):
        return self.stopT is not None
    #FIXME (cf: sinceStartedS())
##     def restart(self):
##         if self.hasStarted():
##             if not self.hasStopped():
##                 raise TimerError('Timer not stopped yet!')
##             self.startT, self.stopT = time.time() - (self.stopT - self.startT), None
##         else:
##             self.start() #XXX
##         return self
    def stop(self):
        if self.startT is None: raise TimerError("Timer hasn't been started")
        self.stopT = time.time()
        return self
    def getTimeS(self, format="%(H)02d:%(M)02d:%(S)02d"):
        h,m,s,_ = self._getHMSMyu()
        return format % {'H': h, 'M' : m, 'S' :s} #XXX
    def _getHMSMyu(self):
        start, stop = self.startT, self.stopT
        if stop is None: stop = time.time()
        if start is None: raise TimerError("Timer hasn't been started")
        h, rest  = divmod(stop - start, 3600)
        m, s = divmod(rest, 60)
        myu = math.modf(stop - start)[0] # FIXME
        return h,m,s,myu
    def startDateAndTime(self):
        if not self.hasStarted(): raise TimerError("Timer hasn't been started")
        return isoDateTimeStr(self.start)
    def sinceStartedS(self):
        if not self.hasStarted():
            raise TimerError("Timer not started yet!")
        return "%s, started at %s" % (self, isoDateTimeStr(self.startT))

#_. STRING PROCESSING

def ipl(*args):
    r"""Return a string that consists of the 'str'ed concatenation of all
    arguments.

    Example:
    
    >>> ipl(1,2,3,'4',[0])
    '1234[0]'
    """

    return "".join(map(str, args))

def replaceStrs(s, *args):
    r"""Replace all ``(frm, to)`` tuples in `args` in string `s`.

    >>> replaceStrs("nothing is better than warm beer",
    ...             ('nothing','warm beer'), ('warm beer','nothing'))
    'warm beer is better than nothing'

    """
    if args == (): return s
    mapping = dict([(frm, to) for frm, to in args])
    return re.sub("|".join(map(re.escape, mapping.keys())),
                  lambda match:mapping[match.group(0)], s)

def lineAndColumnAt(s, pos):
    r"""Return line and column of `pos` (0-based!) in `s`. Lines start with
    1, columns with 0.
    
    Examples:
    
    >>> lineAndColumnAt("0123\n56", 5)
    (2, 0)
    >>> lineAndColumnAt("0123\n56", 6)
    (2, 1)
    >>> lineAndColumnAt("0123\n56", 0)
    (1, 0)
    """
    if pos >= len(s):
        raise IndexError("`pos` %d not in string" % pos)
    # *don't* count last '\n', if it is at pos!
    line = s.count('\n',0,pos)
    if line:
        return line + 1, pos - s.rfind('\n',0,pos) - 1
    else:
        return 1, pos

#_. EVIL THINGS

def magicGlobals(level=1):
    r"""Return the globals of the *caller*'s caller (default), or `level`
    callers up."""
    return inspect.getouterframes(inspect.currentframe())[1+level][0].f_globals

def magicLocals(level=1):
    r"""Return the locals of the *caller*'s caller (default) , or `level`
    callers up.
    """
    return inspect.getouterframes(inspect.currentframe())[1+level][0].f_locals

def thisModule():
    return sys.modules[sys._getframe(3).f_globals['__name__']]

#_. PERSISTENCE

def __saveVarsHelper(filename, varNamesStr, outOf,extension='.bpickle',**opts):
    filename = os.path.expanduser(filename)
    if outOf is None: outOf = magicGlobals(2)
    if not varNamesStr or not isString(varNamesStr):
        raise ValueError, "varNamesStr must be a string!"
    varnames = varNamesStr.split()
    if not splitext(filename)[1]: filename += extension
    if opts.get("overwrite") == 0 and os.path.exists(filename):
	raise RuntimeError("File already exists")
    return filename, varnames, outOf

def saveVars(filename, varNamesStr, outOf=None, **opts):
    r"""Pickle name and value of all those variables in `outOf` (default: all
    global variables (as seen from the caller)) that are named in
    `varNamesStr` into a file called `filename` (if no extension is given,
    '.bpickle' is appended). Overwrites file without asking, unless you
    specify `overwrite=0`. Load again with `loadVars`.

    Thus, to save the global variables ``bar``, ``foo`` and ``baz`` in the
    file 'savedVars' do::

      saveVars('savedVars', 'bar foo baz')

    """
    filename, varnames, outOf = __saveVarsHelper(
        filename, varNamesStr, outOf, **opts)
    print "pickling:\n", "\n".join(ipsort(varnames))
    try:
        f = None
	f = open(filename, "wb")
        
	cPickle.dump(dict(zip(varnames, atIndices(outOf, varnames))),
                     f, 1) # UGH: cPickle, unlike pickle doesn't accept bin=1
    finally:
        if f: f.close()


#FIXME untested
def saveDict(filename, d, **kwargs):
    saveVars(filename, " ".join(d.keys()), outOf=d, **kwargs)
    

def addVars(filename, varNamesStr, outOf=None):
    r"""Like `saveVars`, but appends additional variables to file."""
    filename, varnames, outOf = __saveVarsHelper(filename, varNamesStr, outOf)
    f = None
    try:
        f = open(filename, "rb")
        h = cPickle.load(f)
        f.close()
        
        h.update(dict(zip(varnames, atIndices(outOf, varnames))))
        f = open(filename, "wb")
        cPickle.dump( h, f , 1 )
    finally:
        if f: f.close()

def loadDict(filename):
    """Return the variables pickled pickled into `filename` with `saveVars`
    as a dict."""
    filename = os.path.expanduser(filename)
    if not splitext(filename)[1]: filename += ".bpickle"
    f = None
    try:
        f = open(filename, "rb")
        varH = cPickle.load(f)
    finally:
        if f: f.close()
    return varH

def loadVars(filename, ask=True, into=None, only=None):
    r"""Load variables pickled with `saveVars`.
    Parameters:
    
        - `ask`: If `True` then don't overwrite existing variables without
                 asking.
        - `only`: A list to limit the variables to or `None`.
        - `into`: The dictionary the variables should be loaded into (defaults
                   to global dictionary).
           """
    
    filename = os.path.expanduser(filename)
    if into is None: into = magicGlobals()
    varH = loadDict(filename)
    toUnpickle = only or varH.keys()
    alreadyDefined = filter(into.has_key, toUnpickle)
    if alreadyDefined and ask:
	print "The following vars already exist; overwrite (yes/NO)?\n",\
	      "\n".join(alreadyDefined)
	if raw_input() != "yes":
	    toUnpickle = without(toUnpickle, alreadyDefined)
    if not toUnpickle:
	print "nothing to unpickle"
	return None
    print "unpickling:\n",\
	  "\n".join(ipsort(list(toUnpickle)))
    for k in varH.keys():
        if k not in toUnpickle:
            del varH[k]
    into.update(varH)

#_. TERMINAL OUTPUT FUNCTIONS

def prin(*args, **kwargs):
    r"""Like ``print``, but a function. I.e. prints out all arguments as
    ``print`` would do. Specify output stream like this::

      print('ERROR', `out="sys.stderr"``).
      
    """
    print >> kwargs.get('out',None), " ".join([str(arg) for arg in args])
__test__['prin'] = r"""
>>> prin(1,2,3,out=None)
1 2 3
"""


def underline(s, lineC='-'):
    r"""Return `s` + newline + enough '-' (or lineC if specified) to underline it
    and a final newline.

    Example:

    >>> print underline("TOP SECRET", '*'),
    TOP SECRET
    **********
    
    """
    return s + "\n" + lineC * len(s) + "\n"

def fitString(s, maxCol=79, newlineReplacement=None):
    r"""Truncate `s` if necessary to fit into a line of width `maxCol`
    (default: 79), also replacing newlines with `newlineReplacement` (default
    `None`: in which case everything after the first newline is simply
    discarded).

    Examples:
    
    >>> fitString('12345', maxCol=5)
    '12345'
    >>> fitString('123456', maxCol=5)
    '12...'
    >>> fitString('a line\na second line')
    'a line'
    >>> fitString('a line\na second line', newlineReplacement='\\n')
    'a line\\na second line'
    """
    assert isString(s)
    if '\n' in s:
        if newlineReplacement is None:
            s = s[:s.index('\n')]
        else:
            s = s.replace("\n", newlineReplacement)
    if maxCol is not None and len(s) > maxCol:
        s = "%s..." % s[:maxCol-3]
    return s


#_. SCRIPTING

    
#_ : runInfo
def runInfo(prog=None,vers=None,date=None,user=None,dir=None,args=None):
    r"""Create a short info string detailing how a program was invoked. This is
    meant to be added to a history comment field of a data file were it is
    important to keep track of what programs modified it and how.

    !!!:`args` should be a **``list``** not a ``str``."""
    
    return "%(prog)s %(vers)s;" \
           " run %(date)s by %(usr)s in %(dir)s with: %(args)s'n" % \
           mkDict(prog=prog or sys.argv[0],
                  vers=vers or magicGlobals().get("__version__", ""),
                  date=date or isoDateTimeStr(),
                  usr=user or getpass.getuser(),
                  dir=dir or os.getcwd(),
                  args=" ".join(args or sys.argv))


#_ : DryRun

class DryRun:
    """A clever little class that is usefull for debugging and testing and for
programs that should have a "dry run" option.


Examples:

    >>> import sys
    >>> from os import system
    >>> dry = True
    >>> # that's how you can switch the programms behaviour between dry run
    >>> 
    >>> if dry:
    ...     # (`out` defaults to stdout, but we need it here for doctest)
    ...     run = DryRun(dry=True, out=sys.stdout)
    ... else:
    ...     run = DryRun(dry=False, out=sys.stdout)
    ...
    >>> ## IGNORE 2 hacks to get doctest working, please ignore
    >>> def system(x): print "hallo"
    ...
    >>> run.__repr__ = lambda : "<awmstools.DryRun instance at 0x8222d6c>"
    >>> ## UNIGNORE
    >>> run(system, 'echo "hallo"')
    system('echo "hallo"')
    >>> # now let's get serious
    >>> run.dry = False
    >>> run(system, 'echo "hallo"')
    hallo
    >>> # just show what command would be run again
    >>> run.dry = True
    >>> # You can also specify how the output for a certain function should be
    ... # look like, e.g. if you just want to print the command for all system
    ... # calls, do the following:
    >>> run.addFormatter(system, lambda x,*args, **kwargs: args[0])
    <awmstools.DryRun instance at 0x8222d6c>
    >>> run(system, 'echo "hallo"')
    echo "hallo"
    >>> # Other functions will still be formated with run.defaultFormatter, which
    ... # gives the following results
    >>> run(int, "010101", 2)
    int('010101', 2)
    >>> # Switch to wet run again:
    >>> run.dry = False
    >>> run(int, "010101", 2)
    21
    >>>
    
Caveats:

    - remember that arguments might look different from what you specified in
      the source-code, e.g::

            >>> run.dry = True
            >>> run(chr, 0x50)
            chr(80)
            >>>
            
    - 'DryRun(showModule=True)' will try to print the module name where func
       was defined, this might however *not* produce the results you
       expected. For example, a function might be defined in another module
       than the one from which you imported it:

            >>> run = DryRun(dry=True, showModule=True)
            >>> run(os.path.join, "path", "file")
            posixpath.join('path', 'file')
            >>>

see `DryRun.__init__` for more details.""" 

    def __init__(self, dry=True, out=None, showModule=False):
        """
        Parameters:
            - `dry` : specifies whether to do a try run or not.
            - `out` : is the stream to which all dry runs will be printed
                      (default stdout).
            - `showModule` : specifies whether the name of a module in which a
               function was defined is printed (if known).
    """

        self.dry = dry
        self.formatterDict = {}
        self.out = out
        self.showModule = showModule
        def defaultFormatter(func, *args, **kwargs):
            if self.showModule and inspect.getmodule(func):
                funcName = inspect.getmodule(func).__name__ + '.' + func.__name__
            else:
                funcName = func.__name__
            return "%s(%s)" % (funcName,
              ", ".join(map(repr,args) + map(lambda x: "%s=%s" %
                                             tuple(map(repr,x)), kwargs.items())))
        self.defaultFormatter = defaultFormatter
    def __call__(self, func, *args, **kwargs):
        """Shorcut for self.run."""
        return self.run(func, *args, **kwargs)
    def run(self, func, *args, **kwargs):
        """Same as ``self.dryRun`` if ``self.dry``, else same as ``self.wetRun``."""
        if self.dry:
            return self.dryRun(func, *args, **kwargs)
        else:
            return self.wetRun(func, *args, **kwargs)
    def addFormatter(self, func, formatter):
        """Sets the function that is used to format calls to func. formatter is a
        function that is supposed to take these arguments: `func`, `*args` and
        `**kwargs`."""
        self.formatterDict[func] = formatter
        return self
    def dryRun(self, func, *args, **kwargs):
        """Instead of running function with `*args` and `**kwargs`, just print
           out the function call."""
        
        print >> self.out, \
              self.formatterDict.get(func, self.defaultFormatter)(func, *args, **kwargs)
    def wetRun(self, func, *args, **kwargs):
        """Run function with ``*args`` and ``**kwargs``."""
        return func(*args, **kwargs)




#_. DEBUGGING/INTERACTIVE DEVELOPMENT
#_ : makePrintReturner
def makePrintReturner(pre="", post="" ,out=None):
    r"""Creates functions that print out their argument, (between optional
    `pre` and `post` strings) and return it unmodified. This is usefull for
    debugging e.g. parts of expressions, without having to modify the behavior
    of the program.

    Example:
    
    >>> makePrintReturner(pre="The value is:", post="[returning]")(3)
    The value is: 3 [returning]
    3
    >>> 
    """
    def printReturner(arg):
        myArgs = [pre, arg, post]
        prin(*myArgs, **{'out':out})
        return arg
    return printReturner


#_ : notifier
def notifier():
    """Unix only: pops up an bright red xterm window and beeps. Useful for
    notification that a long computation has finished."""
    os.system("xterm -bg red -fg black -e \
    sh -c '/bin/echo -e \\\\aFINISHED `date`;  sleep 4'")

#_ : Tracing like facilities

#_  , ShowWrap
# FIXME This is not recursive (and really shouldn't be I guess, at least not
# without extra argument) but returning a function wrapper here is really not
# enough, it should be a class (callable hack is of limited workability)
class ShowWrap(object):
    """A simple way to trace modules or objects
    Example::
    
    >> import os
    >> os = ShowWrap(os, '->')
    >> os.getenv('SOME_STRANGE_NAME', 'NOT_FOUND')
    -> os.getenv('SOME_STRANGE_NAME','NOT_FOUND')
    'NOT_FOUND'
    """
    def __init__(self,module, prefix='-> '):
        self.module=module
        self.prefix=prefix
    def __getattribute__(self, name):
        myDict = super(ShowWrap, self).__getattribute__('__dict__')
        realThing = getattr(myDict['module'], name)
        if not callable(realThing):
            return realThing
        else:
            def show(*x, **y):
                print >>sys.stderr, "%s%s.%s(%s)" % (
                    myDict['prefix'],
                    getattr(myDict['module'], '__name__', '?'),
                    name,
                    ",".join(map(repr,x) + ["%s=%r" % (n, v) for n,v in y.items()]))
                return realThing(*x, **y)
            return show

#_  , asVerboseContainer
# XXX a nice example of python's expressiveness, but how useful is it?
def asVerboseContainer(cont, onGet=None, onSet=None, onDel=None):
    """Returns a 'verbose' version of container instance `cont`, that will
       execute `onGet`, `onSet` and `onDel` (if not `None`) every time
       __getitem__, __setitem__ and __delitem__ are called, passing `self`, `key`
       (and `value` in the case of set). E.g:

       >>> l = [1,2,3]
       >>> l = asVerboseContainer(l,
       ...                onGet=lambda s,k:k==2 and prin('Got two:', k),
       ...                onSet=lambda s,k,v:k == v and prin('k == v:', k, v),
       ...                onDel=lambda s,k:k == 1 and prin('Deleting one:', k))
       >>> l
       [1, 2, 3]
       >>> l[1]
       2
       >>> l[2]
       Got two: 2
       3
       >>> l[2] = 22
       >>> l[2] = 2
       k == v: 2 2
       >>> del l[2]
       >>> del l[1]
       Deleting one: 1
       
    """
    class VerboseContainer(type(cont)):
        if onGet:
            def __getitem__(self, key):
                onGet(self, key)
                return super(VerboseContainer, self).__getitem__(key)
        if onSet:
            def __setitem__(self, key, value):
                onSet(self, key, value)
                return super(VerboseContainer, self).__setitem__(key, value)
        if onDel:
            def __delitem__(self, key):
                onDel(self, key)
                return super(VerboseContainer, self).__delitem__(key)
    return VerboseContainer(cont)

#_ : grep
## This is really handy for interactive sessions and searching through
## `dir`, or doing 'real' file-globbing.  XXX: should we
## add (index, what) return mode? only show match?
##      print? lazy version? recursive mode?
def grep(reS, iter, opts=""):
    r"""grep through `iter` as unix grep greps through files.
    
    Parameters:
    
        - `iter`: The iterable to be searched through. 
        - `reS`: a string specifying a perl 5 regular expression to search with.

        `opts`: grep options, the following are available:

            - ``'v'``
                Invert match (only nonmatching entries are shown/counted).

            - ``'c'``
                Count matches.

            - ``'l'``
                Return the indices of the items that matched instead.

            - ``'F'``
                Search using a normal string, not a regular expression.

            - ``'i'``
                Ignore case.

            - ``'w'``
                Only match words.

            - ``'x'``
                Only match whole lines.
                
    Examples:
    
    >>> # dictionaries work, too
    >>> grep('Grep', globals())
    []
    >>> # ignore case
    >>> grep('Grep', globals(), 'i')
    ['grep']
    >>> # list matching indicies, not the matches
    >>> grep('man', ['beast', 'man', 'woman', 'bat man'],'l')
    [1, 2, 3]
    >>> # match only whole words and show the indices
    >>> grep('man', ['beast', 'man', 'woman', 'bat man'],'lw')
    [1, 3]
    >>> # count how many did *not* match the above
    >>> grep('man', ['beast', 'man', 'woman', 'bat man'],'cvw')
    2
    >>> # match only whole lines (or strings)
    >>> grep('man', ['beast', 'man', 'woman', 'bat man'],'x')
    ['man']
    >>> # match only integers
    >>> grep(r'\d+', ['123.4', '1', 'armpit', '312', 'three'],'x')
    ['1', '312']
    """
    if notUnique(opts) or ('x' in opts and 'w' in opts) \
       or ('c' in opts and 'l' in opts):
        raise TypeError('Illegal `opts`: %s' % opts)
    countMatches = returnIndices = False
    flags = 0
    if 'i' in opts:
        flags |= re.I
    if 'F' in opts:
        reS = re.escape(reS)
    #FIXME: the following 2 should replace potentially occuring \b's and '$'s
    if 'w' in opts:
        reS = r'\b%s\b' % reS
    elif 'x' in opts:
        reS = r'^%s$' % reS
    rec = re.compile(reS, flags)
    if 'l' in opts:
        returnIndices = True
        matches = []
    elif 'c' in opts:
        countMatches = True
        matches = 0
    else:
        matches = []
    if 'v' in opts:
        invertor = operator.not_
    else:
        invertor = identity
    for i, elt in enumerate(iter): # XXX
        match = rec.search(elt)
        if invertor(match):
            if returnIndices:
                matches += [i]
            elif countMatches:
                matches += 1
            else:
                matches += [elt]
    return matches

#_. CONVENIENCE
#_ : EasyStruct
#FIXME untested change
#FIXME add checks for valid names
class EasyStruct(object):
    r"""
    Examples:
    
        >>> brian = EasyStruct(name="Brian", age=30)
        >>> brian.name
        'Brian'
        >>> brian.age
        30
        >>> brian.life = "short"
        >>> brian
        EasyStruct(age=30, life='short', name='Brian')
        >>> del brian.life
        >>> brian == EasyStruct(name="Brian", age=30)
        True
        >>> brian != EasyStruct(name="Jesus", age=30)
        True
        >>> len(brian)
        2

    Call the object to create a clone:
    
        >>> brian() is not brian and brian(name="Jesus") == EasyStruct(name="Jesus", age=30)
        True

    Conversion to/from dict:

        >>> EasyStruct(**dict(brian)) == brian
        True

    Evil Stuff:
    
        >>> brian['name', 'age']
        ('Brian', 30)
        >>> brian['name', 'age'] = 'BRIAN', 'XXX'
        >>> brian
        EasyStruct(age='XXX', name='BRIAN')
    """
    def __init__(self,**kwargs):
        self.__dict__.update(kwargs)
    def __call__(self, **kwargs):
        import copy
        res = copy.copy(self)
        res.__init__(**kwargs)
        return res
    def __eq__(self, other):
        return self.__dict__ == other.__dict__
    def __ne__(self, other):
        return not self.__eq__(other)
    def __len__(self):
        return len([k for k in self.__dict__.iterkeys() if not (k.startswith('__') or k.endswith('__'))])
    # FIXME rather perverse
    def __getitem__(self, nameOrNames):
        if isString(nameOrNames):
            return self.__dict__[nameOrNames]
        else:
            return tuple([self.__dict__[n] for n in nameOrNames])
    # FIXME rather perverse
    def __setitem__(self, nameOrNames, valueOrValues):
        if isString(nameOrNames):
            self.__dict__[nameOrNames] = valueOrValues
        else:
            for (n,v) in zip(nameOrNames, valueOrValues):
                self.__dict__[n] = v
    def __contains__(self, key):
        return key in self.__dict__ and not (key.startswith('__') or key.endswith('__'))
    def __iter__(self):
        for (k,v) in self.__dict__.iteritems():
            if not (k.startswith('__') or k.endswith('__')):
                yield k,v
    def __repr__(self):
        return mkRepr(self, **vars(self))

#XXX should we really sort? This makes it impossible for the user to
#customise sorting by specifying a priority dict, but well...
#XXX this should do folding...

def mkRepr(instance, *argls, **kwargs):
    r"""Convinience function to implement ``__repr__``. `kwargs` values are
        ``repr`` ed. Special behavior for ``instance=None``: just the
        arguments are formatted.

    Example:
    
        >>> class Thing:
        ...     def __init__(self, color, shape, taste=None):
        ...         self.color, self.shape, self.taste = color, shape, taste
        ...     def __repr__(self):
        ...         return mkRepr(self, self.color, self.shape, taste=self.taste)
        ...
        >>> maggot = Thing('white', 'cylindrical', 'chicken')
        >>> maggot
        Thing('white', 'cylindrical', taste='chicken')
        >>> Thing('Color # 132942430-214809804-412430988081-241234', 'unkown', taste=maggot)
        Thing('Color # 132942430-214809804-412430988081-241234',
              'unkown',
              taste=Thing('white', 'cylindrical', taste='chicken'))
    """
    width=79
    maxIndent=15
    minIndent=2
    args = (map(repr, argls) + ["%s=%r" % (k, v)
                               for (k,v) in ipsort(kwargs.items())]) or [""]
    if instance is not None:
        start = "%s(" % instance.__class__.__name__
        args[-1] += ")"
    else:
        start = ""
    if len(start) <= maxIndent and len(start) + len(args[0]) <= width and \
           max(map(len,args)) <= width: # XXX mag of last condition bit arbitrary
        indent = len(start)
        args[0] = start + args[0]
        if sum(map(len, args)) + 2*(len(args) - 1) <= width:
            return ", ".join(args)
    else:
        indent = minIndent
        args[0] = start + "\n" + " " * indent + args[0]
    return (",\n" + " " * indent).join(args)

__test__['mkRepr'] = r"""
>>> EasyStruct()
EasyStruct()
>>> EasyStruct(a=1,b=2,c=3)(_='foooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000')
EasyStruct(
  _='foooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000',
  a=1,
  b=2,
  c=3)
>>> EasyStruct(a=1,b=2,c=3)(d='foooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000')
EasyStruct(a=1,
           b=2,
           c=3,
           d='foooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000')
>>> EasyStruct(a=1,b=2,c=3)
EasyStruct(a=1, b=2, c=3)
"""
            
#_ :email
def email(frm, to, subject, message, server="localhost"):
    r"""A convinience function to send simple email messages.
    
    Parameters:
    
    `frm`: From address string.
    `to`: To address (list of strings or string).
    `subject`: The message subject.
    `message`: Message body to send (string).
    `server`: The smtp server to use.
    """

    if isSeq(to):
        to = ", ".join(to)
    smtp = smtplib.SMTP(server)
    msg = ("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n%s" % \
           (frm, to, subject, message))
    smtp.sendmail(frm,to,msg)
    smtp.quit()


#_. EXPERIMENTAL

def d2attrs(*args, **kwargs):
    """Utility function to remove ``**kwargs`` parsing boiler-plate in
       ``__init__``:
       
        >>> kwargs = dict(name='Bill', age=51, income=1e7)
        >>> self = EasyStruct(); d2attrs(kwargs, self, 'income', 'name'); self
        EasyStruct(income=10000000.0, name='Bill')
        >>> self = EasyStruct(); d2attrs(kwargs, self, 'income', age=0, bloodType='A'); self
        EasyStruct(age=51, bloodType='A', income=10000000.0)
        
        To set all keys from ``kwargs`` use:
        
        >>> self = EasyStruct(); d2attrs(kwargs, self, 'all!'); self
        EasyStruct(age=51, income=10000000.0, name='Bill')
    """
    (d, self), args = args[:2], args[2:]
    if args[0] == 'all!':
        assert len(args) == 1
        for k in d: setattr(self, k, d[k])
    else:
        if len(args) != len(set(args)) or set(kwargs) & set(args):
            raise ValueError('Duplicate keys: %s' %
                             notUnique(args) + list(set(kwargs) & set(args)))
        for k in args:
            if k in kwargs: raise ValueError('%s specified twice' % k)
            setattr(self, k, d[k])
        for dk in kwargs:
            setattr(self, dk, d.get(dk, kwargs[dk]))



def xpairwise(fun, v):
    for x0,x1 in window(v): yield fun(x1,x0)

def pairwise(fun, v):
    if not hasattr(v, 'shape'):
        return list(xpairwise(fun,v))
    else:
        return fun(v[1:],v[:-1])
    

def callIgnoring(exceptionType, callable, *args, **kwargs):
    """ Call `callable` returning result; if an exception of type
        `exceptionType` occurs return `Null` instead.
    
    >>> callIgnoring(AttributeError, getattr, [1], '__len__')()
    1
    >>> callIgnoring(AttributeError, getattr, 1, '__len__')()
    Null
    >>> callIgnoring(ValueError, getattr, 1, '__len__')()
    Traceback (most recent call last):
    [...]
    AttributeError: 'int' object has no attribute '__len__'
    """
    try:
        return callable(*args, **kwargs)
    except exceptionType:
        return Null


#FIXME 3 below untested
_bert = []


class softspaceLess(object):
    """
    >>> import sys
    >>> print "a", "b", " ", "d"
    a b   d
    >>> print >>softspaceLess(sys.stdout), "a", "b", " ", "d"
    ab d
    """
    def __init__(self, file=sys.stdout):
        self.__dict__['_file'] = file
        file.softspace = False
    def __getattr__(self,a):
        if a == 'softspace': return False
        return getattr(self._file,a)
    def __setattr__(self,a,v):
        if a=='softspace': return
        setattr(self._file,a,v)

def pGet(name, prefix="_", default=_bert):
    "Convenience function to make typical `property` getter."
    def getter(self):
        if not hasattr(self,prefix+name):
            if default is not _bert:
                setattr(self, name, default)
        return getattr(self, prefix+name)
    return getter
def pSet(name, prefix="_"):
    "Convenience function to make typical `property` setter."    
    def setter(self, value):
        setattr(self, prefix+name, value)
    return setter
def pDel(name, prefix="_"):
    "Convenience function to make typical `property` deleter."
    def deleter(self):
        delattr(self, prefix+name)
    return deleter

def unescape(s):
    try:
        return unescapeAscii(s)
    except Exception:
        return unescapeUnicode(s)
def unescapeAscii(s):
    return codecs.getreader('string_escape').decode(s)[0]
def unescapeUnicode(s):
    return codecs.getreader('unicode_escape').decode(s)[0]
    
import optparse
RCS_HEADER_OR_ID_RE = re.compile("\\$(?P<type>Id|Header): (?P<filename>.*?) \
(?P<version>.*?) (?P<timestamp>\\d{4}/\\d\\d/\\d\\d \\d\\d:\\d\\d:\\d\\d) \
(?P<author>.*?) (?P<garbage>.*)\$")
def parseRcsHeader(s):
    d = RCS_HEADER_OR_ID_RE.search(s).groupdict()
    for k in d: d[k] = unescape(d[k]) # XXX better safe than sorry
    d['timestamp'] = parseRcsTimestamp(d['timestamp'])
    return EasyStruct(**d)

def parseRcsTimestamp(s):
    from datetime import datetime
    return datetime(*time.strptime(s, '%Y/%m/%d %X')[:6])

class versionedOptionParser(optparse.OptionParser):
    def __init__(self, *args, **kwargs):
        super(versionedOptionParser, self)(*args, **kwargs)
        

#FIXME both UNTESTED
def barfAndDie(n, msg):
    print >> sys.stderr, msg % n
    sys.exit(1)
def dieUnlessAll(test, it, msg="Check failed for %s", fail=barfAndDie):
    for e in it:
        if not test(e):
            fail(e, msg)

#FIXME UNTESTED
def positionIf(seq, pred):
    for i,e in enumerate(seq):
        if pred(e):
            return i
    return -1

def smallestNatural(*rest):
    """Return the smallest number in ``*rest`` that is >= 0.

    >>> smallestNatural(-3, 20, 2)
    2
    >>> text = "there is no"
    >>> boundary = text.find('boundary')
    >>> text[:smallestNatural(boundary,len(text))]
    'there is no'
    >>> smallestNatural(-1,-2,-10)
    Traceback (most recent call last):
    [...]
    ValueError: min() arg is an empty sequence
    >>>
    """
    return min([x for x in rest if x >= 0])

#FIXME untested

    

def allEqual(iterable):
    """Return True if all elements in iterable `iterable` are equal, else return False.
    
    >>> allEqual(iter([])) == allEqual([0]) == allEqual([0,0]) == True
    True
    >>> allEqual([1,0]) == allEqual([0,0,1]) == allEqual(iter([1,0,1])) == False
    True
    """
    for first in iterable: break
    else: return True
    for other in iterable:
        if other != first: return False
    return True

def allTheSame(func, iterable):
    """
    >>> allTheSame(abs, (-1, 1, 0-1j))
    True
    >>> allTheSame(len, []) == allTheSame(len, ([1,2], [True,False], [4,5])) == True
    True
    >>> allTheSame(abs, (-1,2)) == allTheSame(id, (False, True, True)) == False
    True
    """
    it = iter(iterable)
    for first in it: break
    else: return True
    firstVal = func(first)
    for other in it:
        if func(other) != firstVal: return False
    return True
    
        
#FIXME untested
#FIXME superfluous thanks argmax?
def maxFor(scorer, iterable, returnScore=False):
    """Return the best scoring item in `iterable` according to scoring method
    `scorer`, if `returnScore` is `True` (default: `False`), also return the
    score.

    >>> maxFor(abs, [1,2,3, -10, 2, 3])
    -10
    >>> maxFor(abs, [1,2,3, -10, 2, 3], True)
    (-10, 10)
    """
    
    it = iter(iterable)
    best = it.next()
    bestScore = scorer(best)
    for item in it:
        score = scorer(item)
        if score > bestScore:
            bestScore = score
            best = item
    if returnScore:
        return best, bestScore
    return best

#FIXME untested
## def argmaxFor(scorer, col, returnScore=False):
##     if hasattr(col, 'iteritems'):
##         it = col.iteritems()
##     else:
##         it = enumerate(col)
##     bestKey, first = it.next()
##     bestScore = scorer(first)
##     for (key, item) in it:
##         score = scorer(item)
##         if score > bestScore:
##             bestScore = score
##             bestKey = key
##     if returnScore:
##         return bestKey, bestScore
##     return bestKey
#FIXME untested
def argmax(iterable, key=None, both=False):
    """
    >>> argmax([4,2,-5])
    0
    >>> argmax([4,2,-5], key=abs)
    2
    >>> argmax([4,2,-5], key=abs, both=True)
    (2, 5)
    """
    if key is not None:
        it = imap(key, iterable)
    else:
        it = iter(iterable)
    score, argmax = reduce(max, izip(it, count()))
    if both:
        return argmax, score
    return argmax

def argmin(iterable, key=None, both=False):
    """See `argmax`.
    """
    if key is not None:
        it = imap(key, iterable)
    else:
        it = iter(iterable)
    score, argmin = reduce(min, izip(it, count()))
    if both:
        return argmin, score
    return argmin


# not fully tested, in particular tests for prefixedByTest and equalityTest
# are missing
# XXX aliases should be handled by resolveAmbiguous
def prefixOf(prefix, iterable,
             prefixedByTest=str.startswith,
             equalityTest=operator.eq,
             resolveAmbiguous=None):
    
    """Find an element in iterable `iterable` that has the unique prefix `prefix`.
    If there a multiple elements that start with `prefix` (and no element that
    is identical to `prefix`), a ValueError is raised unless
    `resolveAmbiguous` is specified.

    `resolveAmbiguous` must be a callable that accepts 2 parameters (the
    `prefix` and the members of `iterable` with that `prefix`).
    
    >>> prefixOf('barf', ['bar', 'barfoot', 'bart', 'lisa'])
    'barfoot'
    >>> prefixOf('bar', ['bar', 'barfoot', 'bart','lisa'])
    'bar'
    >>> prefixOf('ba', ['bar', 'barfoot', 'bart', 'lisa'],
    ...                resolveAmbiguous=lambda p,l: l[-1])
    'bart'
    >>> prefixOf('ba', ['bar', 'barfoot', 'bart', 'lisa'])
    Traceback (most recent call last):
      File "<console>", line 1, in ?
    ValueError: Error: more than one match for 'ba': ['bar', 'barfoot', 'bart'].
    >>> prefixOf('fred', ['bar', 'barfoot', 'bart', 'lisa'])
    Traceback (most recent call last):
      File "<console>", line 1, in ?
    ValueError: No match for prefix 'fred'.
    """
    assert isString(prefix)
    matching = [s for s in iterable if prefixedByTest(s, prefix)]
    if   not matching:
        raise ValueError("No match for prefix %r." % prefix)
    elif len(matching) == 1:
        return matching.pop()
    else:
        if equalityTest is operator.eq and prefix in matching or \
               some(lambda p: equalityTest(prefix,s), matching):
            return prefix
        elif resolveAmbiguous:
            return resolveAmbiguous(prefix, matching)
        else:
            raise ValueError(fitString(
                "Error: more than one match for %r: %r." % (prefix, matching)))

        
# FIXME this won't work for complexes but then you can't use them as ints
# anyway
def isInt(num):
    """Returns true if `num` is (sort of) an integer.
    >>> isInt(3) == isInt(3.0) == 1
    True
    >>> isInt(3.2)
    False
    >>> import numpy
    >>> isInt(numpy.array(1))
    True
    >>> isInt(numpy.array([1]))
    False
    """
    try:
        len(num) # FIXME fails for Numeric but Numeric is obsolete
    except:
        try:
            return (num - math.floor(num) == 0) == True
        except: return False
    else: return False
def ordinalStr(num):
    """ Convert `num` to english ordinal.
    >>> map(ordinalStr, range(6))
    ['0th', '1st', '2nd', '3rd', '4th', '5th']
    """
    assert isInt(num)
    return "%d%s" % (num, {1:'st', 2:'nd', 3:'rd'}.get(int(num), 'th'))
    

# The stuff here is work in progress and may be dropped or modified
# incompatibly without further notice

#FIXME rename to Hole?
class NullType(object):
    r"""Similar to `NoneType` with a corresponding singleton instance `Null`
that, unlike `None` accepts any message and returns itself.

Examples:
>>> Null("send", "a", "message")("and one more",
...      "and what you get still") is Null
True
>>> not Null
True
>>> Null['something']
Null
>>> Null.something
Null
>>> Null in Null
False
>>> hasattr(Null, 'something')
True
>>> Null.something = "a value"
>>> Null.something
Null
>>> Null == Null
True
>>> Null == 3
False
"""

    def __new__(cls):                    return Null
    def __call__(self, *args, **kwargs): return Null
##    def __getstate__(self, *args):       return Null
    def __getinitargs__(self):
        print "__getinitargs__"
        return ('foobar',)
    def __getattr__(self, attr):         return Null
    def __getitem__(self, item):         return Null
    def __setattr__(self, attr, value):  pass
    def __setitem__(self, item, value):  pass
    def __len__(self):                   return 0
    # FIXME: is this a python bug? otherwise ``for x in Null: pass``
    #        never terminates...
    def __iter__(self):                  return iter([])
    def __contains__(self, item):        return False
    def __repr__(self):                  return "Null"
Null = object.__new__(NullType)
Void = Null # backwards comp.
#XXX def position(seq, item, test):
# sublis, merge(s.b.), search,  mismatch, find, *-if, substlis, replace etc., 
# count, count-if

#XXX should there be *flat* position handlers, to?
def treeAt(tree, pos):
    return reduce(operator.getitem, pos, tree)

def treeSet(tree, pos, value):
    operator.setitem(treeAt(tree, pos[:-1]), pos[-1], value)

def treeLen(tree, isSeq=isSeq):
    return reduce(lambda x,y:x+1, xtreeIndices(tree, isSeq), 0)

#XXX throw out the for-loops and see whether it's much slower           
def xtreeIndices(tree, isSeq=isSeq):
    r"""Iterate over the indices of tree `seq`.
    
    >>> nl = [1,[2,3], [4,[5,6]]]
    >>> list(xtreeIndices(nl))
    [[0], [1, 0], [1, 1], [2, 0], [2, 1, 0], [2, 1, 1]]
    """
    pos = [0]
    for elt in tree:
        if isSeq(elt):
            for p in xtreeIndices(elt,isSeq):
                yield concat(pos, p)
        else:
            yield pos[:] # FIXME AAARGH why strange behavior without [:]???
        pos[-1] += 1

#_ :mapConcat

# rename to mapcan
def mapConcat(func, *iterables):
    """Similar to `map` but the instead of collecting the return values of
    `func` in a list, the items of each return value are instaed collected
    (so `func` must return an iterable type).

    Examples:

    >>> mapConcat(lambda x:[x], [1,2,3])
    [1, 2, 3]
    >>> mapConcat(lambda x: [x,str(x)], [1,2,3])
    [1, '1', 2, '2', 3, '3']
    """
    return [e for l in imap(func, *iterables) for e in l]





# FIXME evil and untested
# should return values be optionally handled?
# sync between set attribs...
class Multiplexer(object):
    r"""A mixin that allows multiplexing method calls and attribute
    settings."""
    def __init__(self, multiplexees, multiplexedMethods, multiplexedAttrs=()):
        for method in multiplexedMethods:
            d = {}
            d['multiplexees'] = multiplexees
            exec('''\
def multiplexedMethod_%(m)s(*args, **kwargs):
    for multiplex in multiplexees:
        getattr(multiplex, "%(m)s")(*args, **kwargs)
''' % {'m':method}, d)
            setattr(self, method, d['multiplexedMethod_%s' % method])
        for attr in multiplexedAttrs:
            d = {}
            d['multiplexees'] = multiplexees
            exec('''\
def multiplexedSet_%(a)s(value):
    for multiplex in multiplexees:
        setattr(multiplex, "%(a)s", value)(*args, **kwargs)
''' % {'a': attr}, d)
            #FIXME: should also have fget
            setattr(type(self), attr, property(
                    fset=d["multiplexedSet_%s" % attr]))


#FIXME can we make this into file?
#FIXME .softspace must be readable, too (and synched?)
class Tee(Multiplexer):
    r"""A class acting like a beefed-up unix tee command."""
    _multiplexedMethods = ['close',
                           'flush',
                           'seek',
                           'tell',
                           'truncate',
                           'write',
                           'writelines']
    _multiplexedAttrs = ['softspace']
    def __init__(self, *outs):
        r"""Create a tee file that performs everything it is done to it to all
        the files in `outs`."""
        self.closed = False
        super(Tee,self).__init__(outs, self._multiplexedMethods,
                                 self._multiplexedAttrs)



#_ :Indenter

# FIXME: design not yet settled
# XXX: canonicalisation

class Indenter(object):
    r"""Convenience class to easily generate indented text.

    The indentation level of the previous lines is kept for the succeeding
    lines by default. Useful for generating e.g. python-code on the fly or
    pretty-printing stuff.

    Examples::
    
        >>> ir = Indenter()
        >>> ir += ["1. First", "2. Second", "3. Third", 1,
        ...        "3.a. subpoint of 3.", "3.b. another subpoint",
        ...         -1, "4. Fourth"]
        >>> ir += "5. Fifth"
        >>> ir += 1
        >>> ir += "5.1 another subpoint"
        >>> print ir.text
        1. First
        2. Second
        3. Third
            3.a. subpoint of 3.
            3.b. another subpoint
        4. Fourth
        5. Fifth
            5.1 another subpoint
    """
    def __init__(self, indent=" " * 4, indentList=None):
        self.indent = indent
        self.indentList = indentList or []
    def __iadd__(self, items):
        if not isSeq(items):
            items = [items]
        self.indentList += items
        return self
    def __isub__(self, n):
        if not isinstance(n,int):
            raise TypeError("Can only dedent by ints, got %r." % n)
        self.indentList.append(-n)
        return self        
    def __repr__(self):
        return mkRepr(self, indentList=self.indentList + [self.level],
                            indent=self.indent)
    def getText(self):
        res = []
        level = 0
        for item in self.indentList:
            if isinstance(item, int):
                level += item
            else:
                res.append(self.indent * level + item)
        return "\n".join(res)
    def getLevel(self):
        return reduce(operator.add,
                      filter(lambda x: isinstance(x, int),
                             indentList),
                      0)

        
                             
    text = property(getText)

class Dedenter(object):
    def __init__(self, indent=" " * 4):
        self.indentList = []
        self.indent = indent
        self._dedentRE = re.compile("^(?:%s)+" % re.escape(indent))
    def __iadd__(self, s):
        for s in s.split('\n'):
            striped = self._dedentRE.sub("",s)
            self.indentList += [(len(s) - len(striped)) / len(self.indent),
                                striped]
        return self

#_ :combinations


def combinations(n, k):
    r"Computes the number of ways to choose `k` items from `n` items."
    #FIXME: let's do this really stupidly first
    #FIXME: TESTING
    assert k <= n, "Illegal arguments: k>n"
    if k in (0,n): return 1
    if k > n - k:
        k = n - k
    return reduce(operator.mul, range(n-k+1,n+1)) // \
           reduce(operator.mul, range(1,k+1))


#FIXME - should this thing really return tuples?
#      - is it really useful?
class xseq(object):
    r"""Create a lazy indexable sequence from iterable object `iter`. When the
    xseq object indexed or sliced, it returns a tuple, calling `iter.next` as
    necessary. Essentially, this provides a handy way to index iterators/generators.

    Examples:
    
    >>> seq = xseq(iter(range(10)))
    >>> seq[0]
    0
    >>> #
    >>> # More complex example that shows the caching:
    >>> #
    >>> def myGen(n=10):
    ...     for i in xrange(n):
    ...         print "iter computes", i
    ...         yield(i)
    ...
    >>> gen = myGen()
    >>> seq = xseq(myGen())
    >>> seq = xseq(myGen())
    >>> seq[0]
    iter computes 0
    0
    >>> seq[0]
    0
    >>> seq[0:3]
    iter computes 1
    iter computes 2
    (0, 1, 2)
    >>> seq[0:2]
    (0, 1)
    >>> #
    >>> # special cases are also handled correctly:
    >>> #
    >>> seq = xseq(myGen(5))
    >>> seq[:]
    iter computes 0
    iter computes 1
    iter computes 2
    iter computes 3
    iter computes 4
    (0, 1, 2, 3, 4)
    >>> seq[:-3]
    (0, 1)
    >>> xseq(myGen(5))[-1]
    iter computes 0
    iter computes 1
    iter computes 2
    iter computes 3
    iter computes 4
    4
    """
    
    def __init__(self, iterable):
        self.iter = iter(iterable)
        self._cache = []
    def __iter__(self):
        return self
    def next(self):                         # FIXME
        return self.iter.next()
    def __getitem__(self, index):
        intIndex = 0
        if isinstance(index,int):
            intIndex = 1
            # special case: negative indexing
            if index < 0:
                self._cache.extend([x for x in self.iter])
                index += len(self._cache)
            upTo = index + 1
        elif isinstance(index, types.SliceType):
            assert index.step is None
            upTo = index.stop
            # special case: negative indexing or indexing of complete list
            if upTo is None or upTo < 0:
                self._cache.extend([x for x in self.iter])
                upTo = len(self._cache) + (upTo or 0)
        else:
            raise ValueError("Illegal type for index: %s" %
            type(index))
        if upTo > len(self._cache) or upTo < 0:
            try:
                for i in xrange(len(self._cache), upTo):
                    self._cache.append(self.iter.next())
            except StopIteration:
                if intIndex:
                    raise IndexError("%s index out of range: %s" % \
                                     (self.__class__.__name__, index))
        #AAARGH : that [1,2,3][slice(0,2)] doesn't work is definitively a
        #python (design) BUG!!!. So have to do stupid checking instead
        if intIndex: result = self._cache[index]
        else:
            result = tuple(self._cache.__getslice__(index.start or 0, upTo))

        return result

#FIXME: is this really useful?
class fancyIter(object):
    r"""A generator wrapper that keeps the last returned value as `self.this`
    and allows returning more than one item at a time. `seq` can be any
    iterable.
    
    Examples:

    >>> fi = fancyIter(range(10))
    >>> fi.next(3)
    (0, 1, 2)
    >>> fi.this
    2
    >>> [i for i in fi]
    [3, 4, 5, 6, 7, 8, 9]

    """
    def __init__(self, gen):
        self.gen = iter(gen)
    def __iter__(self):
        return self
    def next(self, howMany=None):
        gen = self.gen
        if howMany:
            res = tuple([gen.next() for i in xrange(howMany)])
            self.this = res[-1]
            return res
        self.this = gen.next()
        return self.this

#FIXME: this should replace all args that can be replaced with kwargs with kwargs
#       will need eval to do this properly...
def rcurry(*funcAndCurriedArgs, **curriedKwargs):
    func, cargs = funcAndCurriedArgs[0], funcAndCurriedArgs[1:]
    def curried(*args, **kwargs):
        rightLen = len(kwargs) + len(curriedKwargs)
        kwargs.update(curriedKwargs)
        # XXX don't allow specifying curried kwargs
        if len(kwargs) != rightLen:
            raise TypeError("Illegal keyword argument specified")
        func(*(args+cargs), **kwargs)
    return curried

#FIXME: should this one be culled?
def allEqual(iterable, equal=operator.eq):
    r"""Return `True` iff all elements in iterable are equal."""
    iterable = iter(iterable)
    first = iterable.next()
    for x in iterable:
        if x != first:
            return False
    return True

__test__['allEqual'] = r"""
>>> allEqual([1])
True
>>> allEqual([1,2,1])
False
>>> allEqual([0,0,0])
True
"""

#XXX: should values be compared?
def dictDifference(d1, d2):
    r"""Difference between two dicts, values taken from `d1`.
    
    >>> dictDifference({'a': 1, 'b': 3}, {'a':1000, 'c':0})
    {'b': 3}
    """
    return dict([(k,v) for k,v in d1.iteritems()
                 if k not in d2])

def dictUnion(d1, d2):
    r"""Create the union of dicts `d1` and `d2`, values taken from `d1`."""
    res = {}
    res.update(d2)
    res.update(d1)
    return res

def dictIntersection(d1, d2):
    r"""Forms the intersection betweeen `d1` and `d2`, values taken from `d1`.
    
    >>> dictIntersection({1:2, 3:4, 5:6}, {1:20, 3:40})
    {1: 2, 3: 4}
    """
    return dict([(k,v) for k,v in d1.iteritems() if k in d2])

  
def filterD(func, d):
    r"""Like `filter`, only for dictionaries.

    Parameters:

     - `func`: a 2 argument function, taking key, value and returning a bool.

    >>> filterD(lambda x,y: x>1 and y != 'bar',
    ...         {0: "foo", 1: "bar", 2: "baz"}) == {2: 'baz'}
    True

    """ 
    return ipupdate({}, dict([(k,v) for (k,v) in d.items() if func(k,v)]))

def bipartD(func,d):
    r"""See `bipart` and filterD

    Example:
    
    >>> bipartD(lambda x,y: x<2, {1: 2, 3: 4})
    [{3: 4}, {1: 2}]
    """

    res = [{},{}]
    for k,v in d.iteritems():
        res[not not func(k,v)][k] = v
    return res


def itemsAtIndices(d, indices):
    r"""Example:
    
    >>> itemsAtIndices({1:2, 3:4, "a":"b"}, [3,"a"])
    {'a': 'b', 3: 4}
    """
    res = {}
    for i in indices: res[i] = d[i]
    return res
    
def mapD(func, *ds):
    r"""Like `map`, only for dictionaries.

    Parameters:
    
     - `func`: a 2 argument function, taking key, value and returning a 2-tuple.

    >>> mapD(lambda x,y:(y,x), *({1:2}, {3:4})) == {2: 1, 4: 3}
    True
    """
    res = {}
    for d in ds:
        for k,v in d.iteritems(): res.__setitem__(*func(k,v))
    return res

#FIXME: the permutation algorithms below are highly stupid
#_ :permute

#first, the elegant python 2.0 solution that will only work for lists
#with unique elements, however

# def permute (l):
#     if l == []: return [[]]
#     else: return [[e] + tail
# 		  for e in l
# 		  for tail in permute( filter(lambda x,y=e: x!=y, l) )]

def xpermute(l):
    r"Return all permutations of a list l."
    if len(l) < 2:
        return l
    results = [[]]
    newResults = []
    for current in l:
        for result in results:
            for r in range(0, len(result) + 1):
                newResults.append(result[:r] + [current] + result[r:])
        # print "###DEBUG: ", results, newResults, l[i]
        results = newResults
        newResults = []
    return results



def when(cond, then_, else_=None):
    r"""``if`` as expression.
    
    >>> when(1==1, lambda:'yes', lambda:'no')
    'yes'
    >>> when(0==1, lambda:'yes', lambda:'no')
    'no'
    >>> when(0==1, lambda:'yes')
    >>>
    """
    if cond:
        return then_()
    elif else_:
        return else_()

if_ = when #FIXME rename
#FIXME
#_ :pprintObject

def pprintObject(object):
    varis = dir(object)
    longestNameLength = max( map(len, varis))
    for var in varis:
        print var, ' ' * (longestNameLength - len(var)), ":", vars(object)[var]


#FIXME
#this is really meant to be used in an editor-template
def DEBUG_P(msg, thingies, level=1):
    r"""Print a debugging message if the `level` is greater-equal than what
    `DEBUG` in the callers namespace (if defined) specifies.
    """
    #FIXME experimental
    if not msg:
        msg = `inspect.getouterframes(inspect.currentframe())[1][3]`
    if level >  magicGlobals().get('DEBUG', 0):
        return
    print '###DEBUG', msg
    if not thingies: return
    if isString(thingies):
        varnames = thingies.split()
        kvs = zip(varnames, atIndices(magicLocals(), varnames))
    elif isinstance(thingies, tuple):
        kvs = thingies
    for k,v in kvs:
        HEADING_FIELD_LEN = 15
        filler = " " * (HEADING_FIELD_LEN + 1)
        kS  = k.ljust(HEADING_FIELD_LEN)
        vSs = repr(v).split('\n')
        print "%s= %s" % (kS,vSs[0])
        for vS in vSs[1:]:
            print filler, vS


#FIXME
def argFilter(*args):
    res = []
    seenNone = False
    for a in args:
        if a is None:
            if seenNone:
                raise ValueError("`None` between non-`None` values")
            seenNone=True
        else:
            res.append(a)
    return res

#FIXME
def filterNone(*args):
    r"""Return all `args` that are not `None`.

    This is a very handy shortcut in situations such as:

    >>> def foo(*args):
    ...     print args
    ... 
    >>> def bar(x, y=None, z=None):
    ...     foo(*filterNone(x,y,z))
    ... 
    >>> bar('only one')
    ('only one',)
    >>> bar('one', 'two', 'three')
    ('one', 'two', 'three')
    
    """
    return [a for a in args if a is not None]

#FIXME
def quote(s, what=r'\\"'):
    return re.sub('([' + what + '])', r'\\\1',s)
#FIXME this doesn't work...
def magicGetSpecial(name, default=None):
    r"""
##     def rutnick():
##         foo = 3
##         bar()
##     def bar():
##         foo = 5
##         egg()
##     def egg():
##         spam()
##     def spam():
##         print magicGetSpecial('foo')
    """
    frames = inspect.getouterframes(inspect.currentframe())
    for i in range(len(frames)-2,-1,-1):
        locals = frames[i].f_locals
        print locals.keys()
        if locals.has_key(name):
            return locals[name]
    return None

def romanNumeral(n):
    """
    >>> romanNumeral(13)
    'XIII'
    >>> romanNumeral(2944)
    'MMCMXLIV'
    """
    if 0 > n > 4000: raise ValueError('``n`` must lie between 1 and 3999: %d' % n)
    roman   = 'I IV  V  IX  X  XL   L  XC    C   CD    D   CM     M'.split()
    arabic  = [1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]
    res = []
    while n>0:
        pos = bisect.bisect_right(arabic, n)-1
        fit = n//arabic[pos]
        res.append(roman[pos]*fit); n -= fit * arabic[pos]
    return "".join(res)



#_ : OBSOLETE
# the following are deprecated

def indexed(seq, start=0):
    warn.warnings('This function is deprecated')
    return zip(seq, range(start, len(seq) + start))

def xindexed(seq, start=0):
    r"Lazy version of `indexed`"
    warn.warnings('This function is deprecated')    
    for x in seq:
        yield (x, start)
        start += 1


#_  ,safeSetItem
#XXX negative pos's
def safeSetItem(l, pos, item, filler=None):
    r"""
    Like ``l[pos] = item`` but the `l` is extended (with
    filler's) if ``pos >= len(l)``.  Returns the list."""
    if pos < 0:
        raise IndexError("`pos` must be positive: %d" % pos)
    diff = pos - len(l)
    if diff > 0:
        l.extend([filler] * diff)
        l.append(item)
    elif diff == 0:
        l.append(item)
    else:
        l[pos] = item
    return l
__test__['safeSetItem'] = r"""
>>> safeSetItem([], 3, "bar")
[None, None, None, 'bar']
>>> safeSetItem([3], -3, "bar", "foo")
Traceback (most recent call last):
[...]
IndexError: `pos` must be positive: -3
>>> safeSetItem([3], 1, "bar", "foo")
[3, 'bar']
>>> safeSetItem([3], 0, "bar", "foo")
['bar']
"""


#_ : TESTING

#_  ,testing functions

class TestError(RuntimeError):
    pass
lastTestExceptionInfo = (None,None,None)

def _docTest():
    import doctest, awmstools
    return doctest.testmod(awmstools)


if __name__ in ("__main__", "__IPYTHON_main__"):
    _docTest()
    import unittest
    class ProcessTest(unittest.TestCase):
        def testProcesses(self):
            assert silentlyRunProcess('ls') == 0
            assert silentlyRunProcess('ls /tmp') == 0            
            assert silentlyRunProcess('i-DoNOT___EXIST')
            assert silentlyRunProcess('latex')
            assert readProcess('ls', '-d', '/tmp') == ('/tmp\n', '', 0)
            assert readProcess('ls', '-d', '/i-DoNOT___.EXIST') == \
                   ('', 'ls: /i-DoNOT___.EXIST: No such file or directory\n', 256)
    suite = unittest.TestSuite(map(unittest.makeSuite,
                                   (ProcessTest,
                                   )))
    #suite.debug()            
    unittest.TextTestRunner(verbosity=2).run(suite)


# don't litter the namespace on ``from awmstools import *``
__all__ = []
me = sys.modules[__name__]
for n in dir(me):
    if n != me and not isinstance(getattr(me,n), type(me)):
        __all__.append(n)
del me

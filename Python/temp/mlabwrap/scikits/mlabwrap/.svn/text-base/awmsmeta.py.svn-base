##############################################################################
################### awmsmeta.py: Meta progamming utilities ###################
##############################################################################
##
## o author: A.Schmolck (a.schmolck@gmx.net)
## o created: 2002-04-17 22:21:56+00:00
## o last modified: $Date: 2005/10/03 10:00:41 $
## o keywords: meta programming; introspection; code generation
## o license: MIT
##          - gensym should be fixed to guarantee uniqueness (if possible)
##          - the `read*` stuff needs more testing, in particular the start
##            and end boundary conditions are quite tricky (in particular in
##            combindation with start, end, which are *not* the same as
##            slicing) and currently at least slightly broken;
##            \b and (?<!\w) etc. have rather complexly different effects.
##          - `readPyString` doesn't handle \-escapes!!!
##          - __coerce__ is broken for s.m.s
##          - `selfStr` is an idiotic name.

r"""A set of meta programming tools for python. **WARNING**: This is a very
early version and still subject to change."""
__docformat__ = "restructuredtext en"

__revision__ = "$Id: awmsmeta.py,v 1.25 2005/10/03 10:00:41 aschmolc Exp $"
__version__  = "0.2"
__author__   = "Alexander Schmolck (A.Schmolck@gmx.net)"

DEBUG=0
DEBUG_P = lambda *x, **y:None

__test__ = {}


import inspect, new, types, operator, warnings, copy, sys
import re
import itertools
from awmstools import isSubset, setDifference, dictDifference, without,\
     atIndices, replaceStrs, if_, xwindow, DEBUG_P, makePrintReturner, \
     invertDict, mkRepr,\
     mkDict, filterD, underline, bipart, prin, ipsort, mapConcat, \
     update, EasyStruct, unescapeAscii, unescapeUnicode, \
     Result, d2attrs

#._ INTROSPECTIVE FUNCTIONS AND BASIC TOOLS

# handle reloads
try:
    _symbolN
except NameError:
    _symbolN = 0
    _gensyms = {}
def gensym(prefix="GSYM"):
    r"""Returns an interned string that is valid as a unique python variable
    name. Usefull when creating functions etc. on the fly.
    """
    global _symbolN, _gensyms
    res = intern("%s%d" % (prefix, _symbolN))
    assert res not in _gensyms
    _symbolN += 1
    _gensyms[res] = True
    return res

__test__['gensym'] = r"""
>>> import awmsmeta
>>> bak = awmsmeta._symbolN, awmsmeta._gensyms
>>> awmsmeta._symbolN, awmsmeta._gensyms = 0, {}
>>> gensym()
'GSYM0'
>>> gensym()
'GSYM1'
>>> gensym('FOO')
'FOO2'
>>> import awmsmeta
>>> reload(awmsmeta) and None
>>> bool(awmsmeta._gensyms) 
True
>>> awmsmeta._gensyms.copy().has_key(awmsmeta.gensym('FOO'))
False
>>> awmsmeta._symbolN = 0
>>> gensym()
Traceback (most recent call last):
[...]
AssertionError
>>> awmsmeta._symbolN, awmsmeta._gensyms = bak
>>> 
"""
# FIXME this is as yet unimplemented    
def guessSignatureFromDocStr(docStr):
    pass
    
def getFuncSignature(func, guess=False):
    r"""Returns information about the `func`'s signature, similar to
    `inspect.getargspec`, but more accessible.

    Examples:
    
    >>> def bar(spam, eggs, beans=4, *args, **kwargs): pass
    ...
    >>> getFuncSignature(bar)
    ['bar', [['spam'], ['eggs'], ['beans', 4]], 'args', 'kwargs']
    >>> getFuncSignature(lambda x,y:x)
    [None, [['x'], ['y']], None, None]
    
    """
    try:
        # XXX HACK: do this the hard way (getargspec doesn't work for methods)
        vnames, args, kwargs  = inspect.getargs(func.func_code)
        defaults              = func.func_defaults
    except AttributeError, msg:
        if guess:
            try:    guessSignatureFromDocStr(func.__doc__)
            except: raise RuntimeError("Failed to guess for: %s" % func)
                
            
        raise "Problem with %s: %s" % (func, msg)
    if defaults:
        varAndDefaults = [[vname] for vname in vnames[:-len(defaults)]] + \
                         [[vname, default] for (vname, default) in
                          zip(vnames[-len(defaults):], defaults)]
    else: varAndDefaults = [[vname] for vname in vnames]
        

    try:
        if func.__name__ == '<lambda>': funcName = None
        else:                           funcName = func.__name__
    except AttributeError:
        funcName = None
    return [funcName, varAndDefaults, args, kwargs]


def funcSignatureToStr(signature, callSig=0):
    r"""Returns what the first line of `func`'s definition would have looked
    like as a string -- in the special case that `func` is a ``lambda``, an
    unique name that begins with lambda is generated. XXX

    Examples:
    
    >>> def foo(a, b=0, c='string', d='bar', **kwargs): pass
    ... 
    >>> funcSignatureToStr(getFuncSignature(foo))
    "def foo(a, b=0, c='string', d='bar', **kwargs):"
    >>> funcSignatureToStr(getFuncSignature(foo),1)
    'foo(a, b, c, d, **kwargs)'

    for ``lambdas``::
    
        >> funcSignatureToStr(getFuncSignature(lambda *args:None))
        'def lambdaG1(*args):'

    """
    sig = signature
    funcS = sig[0] or gensym("lambda")
    if callSig:
        defStart, defEnd = funcS, ""
        vs = ["%s" % item[0] for item in sig[1]]
    else:
        defStart, defEnd = "def " + funcS, ":"
        vs = [["%s", "%s=%r"][len(item)==2] % tuple(item) for item in sig[1]]
    if sig[2]: vs.append("*"  + sig[2])
    if sig[3]: vs.append("**" + sig[3])
    return "%s(%s)%s" % (defStart, ", ".join(vs), defEnd)

#FIXME UNTESTED
def getAttributes(thingy):
    """Returns all attributes in `thingy`, i.e. either its ``dict`` (**not** a
    copy), or, if it has ``__slots__``, a `dict` representation of all those
    slots that are set, or if neither of the above, `None`.

    Example:
    
    >>> from awmstools import sort
    >>> class Normal(object):
    ...     first, second = 1,2
    ...
    >>> class Pervert(object):
    ...       __slots__ = ['first', 'second']
    ...       first, second = 1,2
    ...
    >>> getAttributes(Normal)['second'] == 2
    True
    >>> getAttributes(Pervert)['second'] == 2
    True
    """
    
    theSlots = getattr(thingy, '__slots__', None)
    if theSlots is not None:
        return dict([(k,getattr(thingy,k))
                     for k in theSlots if hasattr(thingy, k)])
    else:
        #FIXME: this returns the *ORIGINAL*
        return getattr(thingy, '__dict__', None)


#FIXME this is rubbish
def newInstance(klass, dikt=None):
    # old-style class
    if type(klass) is types.ClassType:
        class Dummy: pass
        instance = Dummy()
        instance.__dict__ = dikt
        instance.__class__ = klass
    else:
        instance = object.__new__(klass)
        if hasattr(klass, '__slots__'):
            for k in dikt:
                if hasattr(instance,k):
                    setattr(instance,k, getattr(instance,k))
        else:
            instance.__dict__ = dikt
    return instance

#FIXME this is rubbish
def getRenewedInstance(instance, klass):
    return newInstance(klass, getAttributes(instance))

#FIXME this is rubbish
def renewInstances(klasses, *globalsT):
    if not globalsT:
        globalsT = (inspect.getouterframes(inspect.currentframe())[1][0].f_globals,)
    klassNames = [klass.__name__ for klass in klasses]
    klassLookup = dict([(klass.__name__, klass) for klass in klasses])
    for globals in globalsT:
        for k, v in globals.iteritems():
            vKlassName = type(v).__name__
            if vKlassName in klassNames:
                globals[k] = getRenewedInstance(globals[k],
                                                klassLookup[vKlassName])


#_. NAME CONVERSION
#FIXME add docu
import string
_UP = string.uppercase               # XXX is that what we should use?
_lo = string.lowercase
_UP_0_9 = _UP + string.digits
def camelJoin(strs, capitalizeFirst=True):
    """Join `strs` to a CamelCasedWord.

    Examples:

    >>> camelJoin(["this", "is", "easy"])
    'ThisIsEasy'
    >>> camelJoin(["IS", "HARDER", "this"])
    'IS_HARDERThis'
    >>> camelJoin(["A", "SINGLE", "underbar"])
    'A_SINGLEUnderbar'
    >>> camelJoin(["not", "A", "Single", "underbar"])
    'NotASingleUnderbar'
    """
    if len(strs) == 1:
        parts = strs
    else:
        parts = []
        for this, next in xwindow(strs):
            if this[-1] in _UP:
                if (next[-1] in _UP_0_9):
                    parts.append(this + "_")
                else:
                    parts.append(this)
            else:
                parts.append(this.capitalize())
        if next[-1] in _UP_0_9:
            parts.append(next)
        else:
            parts.append(next.capitalize())
    if not capitalizeFirst:
        parts[0] = parts[0].lower()
    return "".join(parts)

#FIXME CapsAndACRIsOK should be 'caps' 'and' 'a' 'c' 'r' 'is' 'o' 'k'
def camelSplit(name, strict=True):
    """Split a CamelCase name into its components. Retains capitalization
    information where it isn't used to separate words. Retains leading and
    trailing 'magic' underbars.

    Examples:

    >>> camelSplit("CapsAndACRIsOK")
    ['Caps', 'and', 'ACR', 'is', 'OK']
    >>> camelSplit("CONSTANTS_ARE_FINE")
    ['CONSTANTS', 'ARE', 'FINE']
    >>> camelSplit("CapsAndUS_ACRIsOK")
    ['Caps', 'and', 'US', 'ACR', 'is', 'OK']
    >>> camelSplit("thisIs_not_OK")
    Traceback (most recent call last):
    ValueError: Illegal CamelCase name supplied: thisIs_not_OK
    >>> camelSplit("thisIs_not_OK", strict=False)
    ['this', 'is', 'not', 'OK']
    >>> camelSplit("_butMagicNamesAreFine")
    ['_but', 'magic', 'names', 'are', 'fine']

    """
    #FIXME
    global _UP, _lo
    leading_bars , mid, trailing_bars = re.match(r'(_+)?(.*?)(_+)?$', name).groups()
    if not mid: # very special case: name ~= /_*/
        return [[name], []][not name]
    elif mid.isupper():
        # HACK the '_*' bit is to have consecutive '_'s fail
        split = re.split('(_)_*', mid)
    elif "_" not in mid and name.islower():
        split = [mid]
    else:
        r = r'''    ^[lo][lo\d]*(?=[UP]|$)
                    |
                     [UP][UP\d]*(?=_[UP\d])
                    |
                     [UP][lo][lo\d]*
                    |
                     [UP][UP\d]*(?=[UP][lo]|$)
                    |
                    _ # need to keep this to reconstruct case for 1 char parts
                 '''
        splitRE = re.compile(replaceStrs(r, ("UP", _UP), ("lo", _lo)), re.X)
        if strict:    
            split = splitRE.findall(mid)
        else:
            split = reduce(operator.add, map(splitRE.findall, re.split('(_)_*', mid)))
        def normCase(t):
            previous, x = t
            if (re.search(r'[A-Z]{2,}',x)): return x
            else: return x.lower()
        # NB: split[0] is *not* normalized
        split[1:] = map(normCase, xwindow(split))
    split[0]  =  (leading_bars or "") + split[0]
    split[-1] += (trailing_bars or "")
    if reduce(int.__add__, map(len,split),0) != len(name):
        raise ValueError("Illegal CamelCase name supplied: %s" % name)
    # kick out all '_'s, except "magic" trailing and leading ones
    return filter("_".__ne__, split)



#_. PARSING

#_ : FORMAT STRING PARSING

#XXX this regexp is a bit overgeneral
formatStrRe = re.compile(r'''
(?<!%)%(?:%%)*
(?: \( (?P<name>[^\)]+) \) )?
(?P<flag>[\#0\-\ +]+)?
(?P<width>[*]|\d+)?
(?:\.(?P<precision>[*]|\d+))?
[hlL]?  # meaningless
(?P<type>\w)
    ''',re.X)

_formatSpecifiers = {
    'd':  'Signed integer decimal',
    'i':  'Signed integer decimal',
    'o':  'Unsigned octal' ,
    'u':  'Unsigned decimal',
    'x':  'Unsigned hexidecimal (lowercase)',
    'X':  'Unsigned hexidecimal (uppercase)',
    'e':  'Floating point exponential format (lowercase)',
    'E':  'Floating point exponential format (uppercase)',
    'f':  'Floating point decimal format',
    'F':  'Floating point decimal format',
    'g':  'Same as "e" if exponent is greater than -4 or less than precision, "f" otherwise',
    'G':  'Same as "E" if exponent is greater than -4 or less than precision, "F" otherwise',
    'c':  'Single character (accepts integer or single character string)',
    'r':  'repr',
    's':  'str',
    }



#_ : READ FUNCTIONS (like eval for a limited number of types) 
#
# this could be used e.g. to safely parse configuration files that are written
# in a (function-call-less) subset of python.



INT_RE = re.compile(r"(?<!\w)[-+]?(0)?\d+(x\d)?\d*\b", re.X | re.I)
#FIXME doesn't do '1L'
def readInt(s, start=0, end=None, search=False):
    """
    >>> [readInt(x)[0] for x in "1 ;-1;+1;0x10;-010;33;0".split(";")]
    [1, -1, 1, 16, -8, 33, 0]
    >>> [readInt(x) for x in "1a;a- 1;+1A;0x ;--010;".split(";")]
    [None, None, None, None, None, None]
    >>> [readInt('--010', search=True), readInt(' 223a',start=1,end=3)[0]]
    [(-8, 1, 5), 22]

    !!! Careful:
    
    >>> readInt('1223a',start=1,end=3)

    """

    if search: searcher = INT_RE.search
    else:      searcher = INT_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    #XXX could simply use `eval`, but well
    mat, oct, hex = match.group(0), bool(match.group(1)), bool(match.group(2))
    if   hex:  base = 16; mat = mat.replace('0x','')
    elif oct:  base = 8;  mat = mat.replace('0','',1)
    else:      base = 10
    return int(mat, base), match.start(), match.end()

REAL_RE = re.compile(r'(?<!\w)[-+]?(?:(?:\d+(?:\.\d*)?)|\.\d+)(?:[eE][+-]?\d+)?')
_isFloat = re.compile(r'[eE.]').search
def readReal(s, start=0, end=None, search=False, alwaysAsFloat=False):
    """
    >>> [readReal(x,search=True)[0] for x in "1;+99;.0;-0.;+.0;0.; 12.34; 3e1;3.e4; .4e3".split(";")]
    [1, 99, 0.0, -0.0, 0.0, 0.0, 12.34, 30.0, 30000.0, 400.0]
    >>> readReal("99")
    (99, 0, 2)
    >>> readReal("99",alwaysAsFloat=True)
    (99.0, 0, 2)
    """
    if search: searcher = REAL_RE.search
    else:      searcher = REAL_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    s = match.group(0).replace(" ", "")
    if alwaysAsFloat or _isFloat(s):
        cast = float
    else:
        cast = int
    return cast(s), match.start(), match.end()

FLOAT_RE = re.compile(
    r'(?<!\w)[-+]?[-+]?(?:(?:\d+\.\d*)|(?:\d*\.\d+)|(?:\d+(?=e)))(?:e[-+]?\d+)?')
def readFloat(s, start=0, end=None, search=False):
    """
        >>> [readFloat(x,search=True)[0] for x in ".0;-0.;+.0;0.; 12.34; 3e1;3.e4; .4e3".split(";")]
        [0.0, -0.0, 0.0, 0.0, 12.34, 30.0, 30000.0, 400.0]
        >>> # XXX: last one...
        >>> [readFloat(x) for x in "0;- 0;.;e1; .e1;111;a1.3;1.3.a".split(";")]
        [None, None, None, None, None, None, None, (1.3, 0, 3)]
        >>> readFloat('a3+33.5', search=True)
        (33.5, 3, 7)
        >>> readFloat('  .53', start=2, end=4)
        (0.5, 2, 4)
        >>> readFloat('  33.5', search=True)
        (33.5, 2, 6)
    
    !!! Careful:
    
        >>> readFloat('33.53', start=2, end=4) is None
        True

    """
    if search: searcher = FLOAT_RE.search
    else:      searcher = FLOAT_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    return float(match.group(0).replace(" ", "")), match.start(), match.end()

#FIXME below is very ugly
#FIXME test this properly
_RAW_INT_OR_FLOAT_RES = \
   r'[-+]?\s*(?:(?:\d+\.\d*)|(?:\d*\.\d+)|(?:\d+))(?:e[-+]?\d+)?'

INT_OR_FLOAT_RE = re.compile(r"""
(?ix)
#XXX\b
%s
#XXX\b
""" % _RAW_INT_OR_FLOAT_RES)


#XXX doesn't grok parens in `(1j+4)`, but that should be ok.
COMPLEX_RE = re.compile(r"""
(?ix)
\b
(?:
  (?:
  %sj
  (?:\s*[+-]%s)?
  )
|
  (?:
  %s
  (?:\s*[+-]%sj)
  )
)
\b
""" % (_RAW_INT_OR_FLOAT_RES, _RAW_INT_OR_FLOAT_RES[5:],
       _RAW_INT_OR_FLOAT_RES, _RAW_INT_OR_FLOAT_RES[5:]))


def readComplex(s, start=0, end=None, search=False):
    """
    >>> [readComplex(x)[0] for x in '1j+4;4+10j;3e-6j;0j;1e0j;10+1.j'.split(';')]
    [(4+1j), (4+10j), 3.0000000000000001e-06j, 0j, 1j, (10+1j)]
    >>> [readComplex(x) for x in '1e;1;0.3ja'.split(';')]
    [None, None, None]
    >>> [readComplex('stuff1+3j', search=True)[0]]
    [3j]
    >>> readComplex('stuff1+3j', start=6)
    (3j, 6, 9)
    
    """
    if search: searcher = COMPLEX_RE.search
    else:      searcher = COMPLEX_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    # XXX ``complex('+ 0.0')`` is illegal, we fix this up here
    return complex(match.group(0).replace(" ", "")), match.start(), match.end()


#FIXME this is a bit too liberal (e.g. matches multiline single quoted strings,
#      comments are also not considered)

PY_STRING_RE = re.compile(r'''
(?<![\w\\])
(?P<uni>u)?
(?P<raw>r)?		
(?P<delim>(?P<char>["'])(?P=char){2}|["'])
(?P<str>
.*?
(?<!\\)(?:\\\\)*?
)
(?P=delim)
''', re.X | re.I | re.DOTALL | re.MULTILINE) #"
FIXMESTR = ' = """alpha beta gamma delta epsilon zeta eta theta iota kappa lamda\n    mu nu xi omicron pi \n    rho varsigma sigma tau upsilon phi chi psi omega""".sp'

#FIXME: refiddled heavily from version 1.21; got one test failure
#XXX: should we check for stuff like /''''/ ?
def readPyString(s, start=0, end=None, search=False):
    r"""
    >>> readPyString(r"'''ffdfd'\nfdfd\n\'''foo'''")[0]
    "ffdfd'\\nfdfd\\n\\'''foo"
    >>>
    """ #'
    if search: searcher = PY_STRING_RE.search
    else:      searcher = PY_STRING_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    gd = match.groupdict()
    if gd['raw']:
        if gd['uni']: res = unescapeUnicode(gd.get('str'))
        else:         res = unescapeAscii(gd.get('str'))
    else:
        if gd['uni']: res = unicode(gd.get('str'))
        else:         res = str(gd.get('str'))
    return res, match.start(), match.end()

PY_CONST_RE = re.compile(
r"""
(?x)(?<![\w.])(?:None|True|False|Ellipsis)\b
""")

def readPyConst(s, start=0, end=None, search=False):
    """
    Edge case (FIXME 2nd behavior might change):
    >>> [readPyConst(n, search=True) for n in (".False", ", True.")]
    [None, (True, 2, 6)]
    """
    import __builtin__
    if search: searcher = PY_CONST_RE.search
    else:      searcher = PY_CONST_RE.match
    match = searcher(s, start, end or len(s))
    if not match: return None
    return getattr(__builtin__,match.group(0)), match.start(), match.end()

__test__['readPyConst'] = r"""
>>> [readPyConst(n)[0] for n in "None True False Ellipsis".split()]
[None, True, False, Ellipsis]
>>> [readPyConst(n) for n in " None; True; False; Ellipsis".split(';')]
[None, None, None, None]
>>> [readPyConst(n, True)[0] for n in " None; True; False; Ellipsis".split(';')]
[None, True, False, Ellipsis]
>>> [readPyConst(n, True) for n in ("_None", "isFalse", "None_", "ellipsis")]
[None, None, None, None]
"""


# FIXME UNTESTED EXPERIMENTAL
class Reader(object):
    r"""Abstract Base class for Readers that read programming language literals
    (simple or compound). Examples might be JSON, SEXP or Python literal readers,
    e.g. for configuration file syntax.
    """
    def __init__(self, **kwargs): super(Reader, self).__init__(**kwargs)
    def __call__(self, *args, **kwargs): return self.read(*args, **kwargs) #XXX
        
class SuperReader(Reader):
    def __init__(self, **kwargs):
        super(SuperReader, self).__init__(**kwargs)
        self.readers = []
        for r in kwargs['readers']: self.add(r)
    def add(self, reader):
        self.readers += [reader]
    def read(self, s, start=0, end=None, search=False):
##         import pdb
##         pdb.set_trace()
        for read in self.readers:
            itSE=read(s, start, end, search)
            if itSE is not None:
                return itSE
        else: return None
class SubReader(Reader):
    def __init__(self, **kwargs):
        super(SubReader, self).__init__(**kwargs)
class SequenceReader(SubReader):
    def __init__(self, **kwargs):
        super(SequenceReader, self).__init__(**kwargs)
        d2attrs(kwargs, self, 'open', 'close', 'sep', 'cast')
    def read(self, s, start=0, end=None, search=False):
        read, open, close, sep = self.superReader.read, self.open, self.close, self.sep
        def skipWS(i):
            return re.compile(r'\s*').match(s,i).end()
        if search:
            start = s.find(open,start)
            if start<0:
                return None
        elif not s[start:].startswith(open):
            return None
        i = skipWS(start+len(open))
        res = []
        while True:
            if s[i:].startswith(close):
                return self.cast(res), start, i+len(close)
            else:
                thing, start0, end0 = read(s, i) #FIXME this can throw
                res.append(thing)
                i=skipWS(end0)
                if s[i:].startswith(sep):
                    i=skipWS(i+len(sep))
                elif s[i:].startswith(close):
                    pass
                else:
                    raise ValueError('bad sequence')
class PyListReader(SequenceReader):
    def __init__(self, **kwargs):
        super(PyListReader, self).__init__(
            **update(kwargs, dict(open= '[', close= ']', sep= ',', cast=list)))

class PyLiteralReader(SuperReader):
    """FIXME: should also at least read dicts."""
    def __init__(self, **kwargs):
        r'''
        >>> sr = PyLiteralReader()
        >>> sr("[]")
        ([], 0, 2)
        >>> sr("[1]")
        ([1], 0, 3)
        >>> sr("[1,2]")
        ([1, 2], 0, 5)
        >>> sr("[1,[   True],  3, 'bar',[[4] ,5]]")
        ([1, [True], 3, 'bar', [[4], 5]], 0, 33)
        '''
        readList=PyListReader(); readList.superReader = self
        super(PyLiteralReader,self).__init__(
            **update(kwargs, dict(readers=[
            readReal, readPyConst, readPyString, readList])))

_numRex = re.compile('(%s)' % _RAW_INT_OR_FLOAT_RES)
def smartSortStrings(ss):
    "Sorts strings in a smart way (UNTESTED XXX doesn't really belong here)"
    ss = list(ss)
    def maybeFloatify(s):
        try: return float(s)
        except ValueError: return s
    sortKeys = []
    for s in ss:
        sortKey = _numRex.split(s)
        if len(sortKey) > 1:
            sortKey = map(maybeFloatify, sortKey)
        sortKeys.append(sortKey)
    return [v for (k,v) in ipsort(zip(sortKeys, ss))]

def maybeNumify(x):
    """Tries to convert object x into an int, float or complex -- in that
       order, returns either the first succesful conversion or the object
       itself.

       Example:
       >>> (maybeNumify('1'), maybeNumify('1.3'), maybeNumify('1.3a'))
       (1, 1.3, '1.3a')
       """
    try: return int(x)
    except ValueError:
        try: return float(x)
        except ValueError:
            try: return complex(x)
            except ValueError:
                return x

def smartSortStringsByFields(ss, fieldSplit, fieldOrder=None):
    """Sorts strings by fields in a smart way (XXX doesn't really belong here)
    
    >>> ss = ['_ _',  'abc 99', 'def 23', 'abc 9b', 'ghi 4', 'abc 9a']
    >>> smartSortStringsByFields(ss, re.compile(" ").split)
    ['_ _', 'abc 9a', 'abc 9b', 'abc 99', 'def 23', 'ghi 4']
    >>> smartSortStringsByFields(ss, re.compile(" ").split)
    ['_ _', 'abc 9a', 'abc 9b', 'abc 99', 'def 23', 'ghi 4']
    >>> smartSortStringsByFields(ss, re.compile(" ").split, [1,0])
    ['ghi 4', 'abc 9a', 'abc 9b', 'def 23', 'abc 99', '_ _']
    """
    ss = list(ss)
    def maybeFloatify(s):
        try: return float(s)
        except ValueError: return s
    if fieldOrder: reorder = lambda l: [l[i] for i in fieldOrder]
    else:          reorder = lambda l:l 
    sortKeys= [[map(maybeFloatify, _numRex.split(field))
                for field in reorder(fieldSplit(s))]
               for s in ss]
    return [v for (k,v) in ipsort(zip(sortKeys, ss))]


COMMENT = intern('COMMENT')
STRING  = intern('STRING')
def yieldPyFields(s, start=0, end=None):
    delimitedSearch = Result(re.compile('[\#\'\"]').search)
    eolOrEofSearch = re.compile('$').search    # XXX !!! doesn't *include* the \n
    stringSearch = PY_STRING_RE.match
    absoluteEnd = len(s)
    if end is None:
        end = absoluteEnd
    while delimitedSearch(s, start, end):
        match = delimitedSearch.result
        if match.group(0) == '#':
            matchStart = match.start()
            matchEnd   =  eolOrEofSearch(s, matchStart).end()
            yield COMMENT, s[matchStart:matchEnd], matchStart, matchEnd
        else:
            assert match.group(0) in "'\""
            pseudoStart = match.start()
            if pseudoStart > 0 and s[pseudoStart-1].lower() in ('r', 'u'):
                if pseudoStart > 1 and s[pseudoStart-2].lower() == 'u':
                    matchStart = pseudoStart - 2
                else:
                    matchStart = pseudoStart - 1
            else:
                matchStart = pseudoStart
            matchEnd = stringSearch(s, sStart, end).end()
            yield STRING, s[matchStart:matchEnd], matchStart, matchEnd
        start = matchEnd
def isPyCodeRegionHOF(s):
    fields = awmstools.flatten([t[2:] for t in awmsmeta.yieldPyFields(s)])
    def isPyCodeRegion(start, end):
        i = awmstools.binarySearchPos(fields, start)
        return not (i % 2) or binarySearchPos(fields[i:], start)
    return isPyCodeRegion


#_. DYNAMIC CODE GENERATION TOOLS (messy!!!)

# !!! O,U,F are mutually exclusive; X is just a dummy
# FIXME should use some enum type here, and not duplicate crap all over the
# place
O, U, F, Q, M, S, X, HR, HI, I, R = [1 << x for x in range(11)]
G = M | S | X #FIXME
class SpecialMethod(object):
    _name2code = {
        "UNIQUE_SYNTAX" : U,             #FIXME
        "QUEER_THING" : Q,               #FIXME
        "DUMMY" : X,                     #FIXME

        "GENERIC" : G,
        "MATH" : M,
        "SEQUENCE" : S,

        "INPLACE" : I,
        "RIGHT" : R,
        
        "HAS_INPLACE_VARIANT" : HI,
        "HAS_RIGHT_VARIANT" : HR,
        
        "FUNCTION" : F,
        "OPERATOR" : O,
        }
    _codes = _name2code.values()
    _attrs2code = dict((zip([camelJoin(#if_(k.startswith('HAS'),[''],["is"]) +
                                      k.lower().split('_'), False)
                            for k in  _name2code.keys()],
                           atIndices(_name2code, _name2code.keys()))))
    _code2name = invertDict(_name2code)
    def __init__(self, name, func, symbol, arity, type, returnType=None):
        self.name   = name
        self.symbol = symbol
        self.func   = func
        self.arity  = arity
        self.type   = type
        self.returnType = returnType
    def anyOf(self, what):
        return bool(reduce(operator.add, map(what.__and__, self._codes)), 0)
    def allOf(self, what):
        return bool(reduce(operator.mul, map(what.__and__, self._codes)), 1)
    def getRightVariant(self):
        if not self.hasRightVariant:
            raise TypeError(self.name + " has no right variant!")
        return type(self)(self.name.replace('__', '__r', 1), func=self.func,
                      symbol=self.symbol, arity=self.arity,
                      type=(self.type & ~self.HAS_RIGHT_VARIANT) | self.RIGHT)
    def getInplaceVariant(self):
        if not self.hasInplaceVariant:
            raise TypeError(self.name + " has no inplace variant!")
        return type(self)(self.name.replace('__', '__i', 1), func=None,
                      symbol=self.symbol + "=", arity=self.arity,
                      type=self.type | self.INPLACE)
    def typeRepr(self):
        return "|".join(["%s.%s" % (type(self).__name__, name)
                         for name in 
                         atIndices(self._code2name,
                                   filter(self.type.__and__, self._codes))])
    def __repr__(self):
        return mkRepr(self, `self.name`, `self.symbol`, `self.arity`,
                      'type=%s' % self.typeRepr())
    def __getattr__(self, name):
        try:
            #FIXME should we return bool or keep info for bit-operations?
            ## return _attrs2code[name] & self.type
            return self._attrs2code[name] & self.type
        except KeyError:
            raise AttributeError(name)
# Add the flags as class attributes
for k, v in SpecialMethod._name2code.items(): setattr(SpecialMethod, k, v)
del k, v    


 #XXX precedences
SPECIAL_METHODS = [
    # NAME                       SYMBOL     ARITY  TYPE                 RETURN TYPE
    #-------------------------------------------------------------------------------
    # MAINLY MATHEMATICAL
    # unary operators
    SpecialMethod("__neg__"   ,operator.neg           ,"-",          1, O|M),
    SpecialMethod("__pos__"   ,operator.pos           ,"+",          1, O|M),
    SpecialMethod("__invert__",operator.invert        ,"~",          1, O|M),
    # binary operators                                   
    SpecialMethod("__add__"   ,operator.add           ,"+",          2, O|HI|HR|M|S),
    SpecialMethod("__sub__"   ,operator.sub           ,"-",          2, O|HI|HR|M),
    SpecialMethod("__mul__"   ,operator.mul           ,"*",          2, O|HI|HR|M|S),
    SpecialMethod("__floordiv__",operator.floordiv    ,"//",         2, O|M),
    SpecialMethod("__mod__"   ,operator.mod           ,"%",          2, O|HI|HR|M),
    SpecialMethod("__pow__"   ,operator.pow           ,"**",         2, O|HI|HR|M),
    SpecialMethod("__lshift__",operator.lshift        ,"<<",         2, O|HI|HR|M),
    SpecialMethod("__rshift__",operator.rshift        ,">>",         2, O|HI|HR|M),
    SpecialMethod("__and__"   ,operator.and_          ,"&",          2, O|HI|HR|M),
    SpecialMethod("__xor__"   ,operator.xor           ,"^",          2, O|HI|HR|M),
    SpecialMethod("__or__"    ,operator.or_           ,"|",          2, O|HI|HR|M),
    SpecialMethod("__div__"   ,operator.div           ,"/",          2, O|HI|HR|M), # FIXME
    SpecialMethod("__truediv__",operator.truediv      ,"/",          2, O|M),
                                                      
    # unary special functions                            
    SpecialMethod("__abs__"   ,abs                    ,"abs",        1, F|M),
                                                      
    # conversion functions                               
    SpecialMethod("__complex__",complex               ,"complex",    1, F|M,                   complex),
    SpecialMethod("__int__"   ,int                    ,"int",        1, F|M,                   int),
    SpecialMethod("__long__"  ,long                   ,"long",       1, F|M,                   long),
    SpecialMethod("__float__" ,float                  ,"float",      1, F|M,                   float),
    SpecialMethod("__oct__"   ,oct                    ,"oct",        1, F|M,                   string),
    SpecialMethod("__hex__"   ,hex                    ,"hex",        1, F|M,                   string),
    SpecialMethod("__coerce__",coerce                 ,"coerce",     2, F|M),
                                                      
    #General conversion functions                     
    SpecialMethod("__str__"   ,str                    ,"str",        1, F|G,                   string),
    SpecialMethod("__repr__"  ,repr                   ,"repr",       1, F|G,                   string),
    SpecialMethod("__hash__"  ,hash                   ,"hash",       1, F|G,                   string), #FIXME
    SpecialMethod("__nonzero__",bool                  ,"bool",       1, F|G,                   bool), #FIXME
                                                      
                                                      
    #binary special functions                         
    SpecialMethod("__cmp__"   ,cmp                    ,"cmp",        2, F|M,                   int),
    SpecialMethod("__divmod__",divmod                 ,"divmod",     2, F|M|HR),
    SpecialMethod("__lt__"    ,operator.lt            ,"<",          2, O|M),
    SpecialMethod("__le__"    ,operator.le            ,"<=",         2, O|M),
    SpecialMethod("__eq__"    ,operator.eq            ,"==",         2, O|M), # FIXME: should be O|G?
    SpecialMethod("__ne__"    ,operator.ne            ,"!=",         2, O|M),
    SpecialMethod("__gt__"    ,operator.gt            ,">",          2, O|M),
    SpecialMethod("__ge__"    ,operator.ge            ,">=",         2, O|M),
                                                      
                                                      
                                                      
    #ATTRIBUTE ACCESS                                 
    SpecialMethod("__getattr__",getattr               ,".",          2, O|G), # FIXME
    SpecialMethod("__setattr__",setattr               ,"%(self)s.%(name)s = %(value)s", 3, U|G),
    SpecialMethod("__delattr__",delattr               ,"del %(self)s.%(key)s",2, U|G,           type(None)),
                                                      
                                                      
    #CONTAINER FUNCTIONS                              
    SpecialMethod("__iter__"  ,iter                   ,"iter",       1, F|S),
    SpecialMethod("__len__"   ,len                    ,"len",        1, F|S,                    int),
    
    #CONTAINER OPERATORS
    #SpecialMethod("__contains__" ,"in",        2, O|S|R), #FIXME not in? should really be 'U', I guess...
    SpecialMethod("__getitem__"  ,operator.getitem,"%(self)s[%(key)s]",     2, U|S),
    SpecialMethod("__setitem__"  ,operator.setitem,"%(self)s[%(key)s] = %(value)s",3, U|S , type(None)),
    SpecialMethod("__delitem__"  ,operator.delitem,"del %(self)s[%(key)s]", 2, U|S,         type(None)),
    
    # XXX don't need silly __getslice__, __setslice__ and __delslice__

    #FUNNY STUFF
    SpecialMethod("__new__"      ,operator.__new__ ,None,    -1, Q|G),    
    SpecialMethod("__init__"     ,operator.__init__,None,    -1, Q|G),
    SpecialMethod("__del__"      ,operator.delitem ,None,     0, Q|G), #FIXME
    SpecialMethod("__call__"     ,None             ,None,    -1, Q|G),
]
# XXX ugly cleanup
del x, O, U, F, Q, M, S, X, HR, HI, I, R, G


def _addVariants():
    for sm in SPECIAL_METHODS[:]:
        if sm.hasRightVariant:
            SPECIAL_METHODS.append(sm.getRightVariant())
        if sm.hasInplaceVariant:
            SPECIAL_METHODS.append(sm.getInplaceVariant())
_addVariants()

PY_NAMES_TO_SPECIAL_METHODS = dict(map(lambda sm: (sm.name, sm), SPECIAL_METHODS))
SYMBOLS_TO_SPECIAL_METHODS = dict(map(lambda sm: (sm.symbol, sm), SPECIAL_METHODS))
SYMBOLS_TO_SPECIAL_METHODS['-'] = tuple([sm for sm in SPECIAL_METHODS
                                         if sm.name in('__neg__', '__sub__')])

class Wrapper(object):
    """Abstract baseclass to wrap functions, methods or attributes into
    existing modules, classes or objects."""
    def __init__(self, into, namespace, toWrap):
        self.namespace = namespace
        self.into = into
        self.toWrap = toWrap
        self.overwriteOld = False
    def getSignature(self, tw):
        return getFuncSignature(tw)
    def getDoc(self, tw):
        return getattr(tw, '__doc__', "") or ""
    def makeTmpName(self, name):
        """Make a version of name that is unique in the `namespace` dict."""
        tmpName = name
        while 1:
            tmpName = gensym(name + "_tmp")
            if not hasattr(self.namespace, tmpName): break
        return tmpName
    def massageDocString(self, s):
        return s
    def wrapStr(self): raise NotImplementedError()
    def _setIt(self, into, name, what):
        setattr(into, name, what)
    def wrap(self):
        s = self.wrapStr()
        exec s in self.namespace
        for name in self.names:
            if hasattr(self.into, name) and not self.overwriteOld:
                pass #XXX warnings.warn("Skipping:%s" % name)
            else:
                ##XXX ugly. Think of better design
                self._setIt(self.into, name, self.namespace[name])
##FIXME docstring stuff                             
##                           tmpName,                                              
##                                                  self.massageDocString(
##                                                   getattr(
##                                                    self.namespace[tmpName],
##                                                    '__doc__', None))
                                                  


class SimpleFunctionWrapper(Wrapper):
    def __init__(self, into, namespace, toWrap):
        super(SimpleFunctionWrapper, self).__init__(into, namespace, toWrap)
        self.wrapTemplate = """\
%(declSigS)s
    %(docS)r
 
    return %(returnCastS)s(%(callSigS)s)
"""
        self.names = {}
        for tw in toWrap:
            name = self.getSignature(tw)[0]
            tmpName = self.makeTmpName(name)
            self.namespace[tmpName] = tw
            self.names[name] = tmpName
    def massageDeclareSig(self, sig):
        return sig
    def massageCallSig(self, sig):
        sig = copy.deepcopy(sig)
        sig[0] = self.names[sig[0]]
        return sig
    def returnCast(self, sig):
        return ""
    def wrapStr(self):
        res = []
        for func in self.toWrap:
            sig = self.getSignature(func)
            newDoc = self.getDoc(func)
            newSig = self.massageDeclareSig(sig)
            declSigS = funcSignatureToStr(newSig)
            callToOld = funcSignatureToStr(self.massageCallSig(sig), 1)
            res.append(self.wrapTemplate %
                       mkDict(declSigS=declSigS,
                              docS=newDoc,
                              callSigS=callToOld,
                              returnCastS=self.returnCast(sig)))
        res.extend("\n") #XXX
        return "\n\n".join(res)

class SimpleStaticMethodWrapper(SimpleFunctionWrapper):
    def _setIt(self, into, name, what):
        setattr(into, name, staticmethod(what))


class SimpleMethodWrapper(SimpleFunctionWrapper):
    def __init__(self, into, namespace, toWrap, selfStr):
        super(SimpleMethodWrapper, self).__init__(into, namespace, toWrap)
        self.selfStr = selfStr
    def massageCallSig(self, sig):
        sig = copy.deepcopy(sig)
        sig[0] = "%s.%s" % (self.selfStr, sig[0])
        fstArg = sig[1].pop(0)
        if fstArg[0] != "self":
            warnings.warn("%s has funny 1st arg: %s" % (sig[0], fstArg))
        return sig

class SimpleClassMethodWrapper(SimpleFunctionWrapper):
    def __init__(self, into, namespace, toWrap):
        super(SimpleClassMethodWrapper, self).__init__(into, namespace,toWrap)
    def returnCast(self, sig):
        return "cls"
    def massageDeclareSig(self, sig):
        sig = copy.deepcopy(sig)
        sig[1][0:0] = [["cls"]]
        return super(SimpleClassMethodWrapper, self).massageDeclareSig(sig)
    def _setIt(self, into, name, what):
        setattr(into, name, classmethod(what))
        

#XXX this ugly and should be rewritten
class SimpleSpecialMethodWrapper(Wrapper):
    """A simple class that specifies a wrapping template for all the types of
    methods to be wrapped (signature bits => string template),
    `_WRAPING_TEMPLATE_D`, `_LOOK_AT` at function that produces the signature
    to be matched from a `SpecialMethod` instance and `wrap` a mehod to wrap
    the SpecialFunctions.
    """
    _WRAPING_TEMPLATE_D = {
        (1, SpecialMethod.OPERATOR) : """
## unaryOperator
def %(name)s(self):
    return %(returnCast)s(%(op)s%(selfStr)s)
""",
        (2, SpecialMethod.OPERATOR) : """
## binaryOperator
def %(name)s(self, other):
    return %(returnCast)s(%(selfStr)s %(op)s other)
""",
        (2, SpecialMethod.OPERATOR | SpecialMethod.RIGHT) : """
## rightBinaryOperator
def %(name)s(self, other):
    return %(returnCast)s(other %(op)s %(selfStr)s)
""",

        (2, SpecialMethod.OPERATOR | SpecialMethod.INPLACE) : """
##inplaceOperator
def %(name)s(self, other):
    %(selfStr)s %(op)s other
    return self
""",
        (1, SpecialMethod.FUNCTION) :  """
## unarySpecialMethod
def %(name)s(self):
    return %(returnCast)s(%(op)s(%(selfStr)s))
""",
        (2, SpecialMethod.FUNCTION) :  """
## binarySpecialMethod
def %(name)s(self, other):
    return %(returnCast)s(%(op)s(%(selfStr)s, other))
""",

        (2, SpecialMethod.FUNCTION | SpecialMethod.RIGHT) :  """
## rightBinarySpecialMethod
def %(name)s(self, other):
    return %(returnCast)s(%(op)s(other, %(selfStr)s))
""",


        }
    #
    _LOOK_AT = staticmethod(lambda sm:
                    (sm.arity, sm.operator | sm.function | sm.inplace | sm.right))
                    
    def __init__(self, into, namespace, toWrap, returnCast, selfStr):
        
        super(SimpleSpecialMethodWrapper, self).__init__(into, namespace, toWrap)
        self.returnCast = returnCast
        self.selfStr = selfStr
    def wrapStr(self):
        """Return a list of definitions strings for all methods
        `specialMethods` wrapped to for instances of `selfStr` and
        returning `returnCast`
        """
        res = [self._WRAPING_TEMPLATE_D[self._LOOK_AT(sm)] %
               mkDict(name=sm.name,
                      op = sm.symbol,
                      returnCast=if_(sm.returnType, lambda:"", lambda:self.returnCast),
                      selfStr=self.selfStr) for sm in self.toWrap]
        self.names = mapConcat(re.compile(r"^def (.*)\(",re.M).findall,
                               res)
        return "\n".join(res)
            
        



##     """



#_. EXPERIMENTAL
# !!!trust nothing below this point!!!

#FIXME unfinished and in flux
# XXX: once this is resumed, don't forget to check if the class/function has
# been redefined before it is re/deadviced

import weakref
class SimpleAdvice(object):
    class AdviceStruct(EasyStruct):pass
    _ADVISED = {}
    verbose = True
    def __init__(self, withDict, name, advice, where="after", doc=""):
        """Advises a function named `name` in class or module `withDict`
        with the function `advice` of type `where`.
        
        `where` can be one of the following:

        1. 'before'. `advice` then must match::

               def beforeAdvice(*args, **kwargs):
                   # DO SOMETHING
                   return args, kwargs

           (for convinience, return None is also OK and has the effect of
           passing the original args unmodified to the advised function).
           
        2. 'after' ::
            
               def afterAdvice(__res, *args, **kwargs):
                   # DO SOMETHING
                   return result
        
        3. 'around' ::

               def aroundAdvice(__func, *args, **kwargs):
                   # DO SOMETHING
                   return result

        """
        if not hasattr(withDict, '__dict__'):
            raise TypeError("withDict %r has no __dict__" % withDict)
        if not isinstance(name, str):
            raise TypeError("Not a string: %r" % name)
        if not operator.isCallable(advice):
            raise TypeError("%r not callable" % advice)

        self.withDict = withDict
        self.name = name
        self.where = where
        self.adviceFunc = advice
        
        old = getattr(withDict, name)
        if   where == "before":
            def advised(*__0args, **kw__0args):
                newArgsAndKwargs = advice(*__0args, **kw__0args)
                if newArgsAndKwargs is not None:
                    __0args, kw__0args = newArgsAndKwargs
                return old(*__0args, **kw__0args)
        elif where == "after":
            def advised(*__0args, **kw__0args):
                res = old(*__0args, **kw__0args)
                return advice(res, *__0args, **kw__0args)
        elif where == "around":
            def advised(*__0args, **kw__0args):
                return advice(old, *__0args, **kw__0args)
        else:
            raise ValueError("Illegal Value for where: %s" % where)

        if self._ADVISED.setdefault(withDict,{}).has_key(name):
            raise ValueError("Can't have multiple advice's yet!")
            #warnings.warn(name + " is already advised")
            #_ADVISED[withDict][name].old.append(old)
        else:
            self._ADVISED[withDict][name] = self.AdviceStruct(old=old)
            #setattr(withDict, name, with(old))
        self._ADVISED[withDict][name].advice = advised
        advised.__doc__ = """This function has been advised
Original descripiton:
%s

Advice descripiton:
%s
""" % (old.__doc__ or "", doc)
        
    def activate(self):
        if self.verbose:
            print "Advising %(name)s %(where)s with %(adviceFunc)s" % \
                  vars(self)
        setattr(self.withDict,
                self.name,
                self._ADVISED[self.withDict][self.name].advice)
    def deactivate(self):
        if self.verbose:
            print "Unadvising %(name)s %(where)s with %(adviceFunc)s" % \
                  vars(self)
        setattr(self.withDict,
                self.name,
                self._ADVISED[self.withDict][self.name].old)
    #FIXME
    def remove(self):
        if self.verbose:
            print "Removing %(where)s advice from %(name)s: %(adviceFunc)s" % \
                  vars(self)
        self.deactivate()
        del self._ADVISED[self.withDict][self.name]
        #self.__dict__ = {}

#FIXME untested
def aliases(d):
    """>>> from awmstools import sort
       >>> sort(map(sort, aliases(dict(a=1,b=[2],c=[2],t1=True,t2=True,t3=True,n1=None,n2=None))))
       [['n1', 'n2'], ['t1', 't2', 't3']]
       >>> aliases(dict()) == aliases(dict(a=1)) == aliases(dict(a=1, b=2)) == []
       True
    """
    #XXX
    if isinstance(d, (type, types.ClassType, types.ModuleType)):
        d = d.__dict__
    idToOneKey = dict([(id(v), k) for (k,v) in d.items()])
    if len(idToOneKey) == len(d):
        return []
    else:
        idToManyKeys = {}
        for k,v in d.iteritems():
            canonicalKey = idToOneKey[id(v)]
            if k != canonicalKey:
                idToManyKeys.setdefault(id(v), [canonicalKey]).append(k)
        return idToManyKeys.values()

#FIXME order of arguments
#FIXME testing
def aliasesFor(keys, d, ignoreMissing=False):
    idsTotheKeys = {}
    for k in keys:
        try:
            theId = id(d[k])
            idsTotheKeys[theId] = []
        except KeyError:
            if not ignoreMissing: raise
    for k,v in d.iteritems():
        if id(v) in idsTotheKeys:
            idsTotheKeys[id(v)].append(k)
    return idsTotheKeys.values()

    
        
    

    
#_  , Introspective
#FIME: what skip-re never matches?

def getOverview(d):
    return [("%-15s: %s" % (name,(getattr(d[name],'__doc__',0) or "UNDOCUMENTED")\
                           .split("\n")[0]))[:79] for name in d]
            
#FIXME this is crap (only here because curry was broken)
def _funcOverview(d):
    return "\n".join(
        ipsort(getOverview
              (filterD(lambda n,v:type(v) == types.FunctionType and n[0] !='_',
                        d))))
                       



#FIXME
def getAllX(thingWithDictOrDict, x, ignore="^$"):
    if not getattr(thingWithDictOrDict, '__dict__',None):
        d = thingWithDictOrDict
    else:
        #d = getattr(thingWithDictOrDict, '__dict__') or thingWithDictOrDict)
        d = dict(inspect.getmembers(thingWithDictOrDict)) #FIXME
    skipRE = re.compile(ignore)
    return filterD(lambda name, obj:
                   isinstance(obj, x) and not skipRE.search(name),
                   d)
methodTypes = (staticmethod, classmethod, types.MethodType,
               types.BuiltinMethodType, types.FunctionType)
funcTypes = (types.FunctionType, types.BuiltinFunctionType)
getFuncs = lambda *a,**kw: getAllX(x=funcTypes,*a,**kw)
def getMethods(thingWithDictOrDict, ignore="^$"):
    return getAllX(thingWithDictOrDict, x=methodTypes, ignore=ignore)
getClasses = lambda *a,**kw:getAllX(x=(types.ClassType, type),*a,**kw)
    


############################### test functions ###############################

## class OldStyle:
##     attribute = "ATTR"
##     def oldStyleMethod(self):
##         print "Hi, I'm an oldStyleMethod with attribute", self.attribute
## oldStyle = OldStyle()

## class NewStyle(object):
##     attribute = "ATTR"
##     def newStyleMethod(self):
##         print "Hi, I'm an newStyleMethod with attribute", self.attribute
## newStyle = NewStyle()

## class Sloty(object):
##     __slots__ = ["foo", "bar", "watz"]
##     foo = "fooSlot"
##     bar = "barSlot"
##     # no watz

##     def showSlots(self):
##         print "ALL NEW"
##         for slt in self.__slots__:
##             if hasattr(self, slt):
##                 print slt, "=", getattr(self, slt)
##             else:
##                 print slt, "NOT SET"
## sloty = Sloty()

## def fooEmpty():pass
## def fooOne(a):pass
## def fooTwo(a,b):pass
## def foo(a, b, c=None, d="foo"):pass
## def foo2(a, b, c=None, d="foo", *args):pass
## def foo4(a, b, c=None, d="foo", *args, **kwargs):pass



__test__[ "camelSplit"] = """
>>> camelSplit("A")
['A']
>>> camelSplit("a")
['a']
>>> camelSplit("aB")
['a', 'b']
>>> # XXX, this is undecidable
>>> camelSplit("AB")
['AB']
>>> camelSplit("ABC")
['ABC']
>>> camelSplit("AbC")
['Ab', 'c']
>>> # XXX, this is undecidable
>>> camelSplit("NotAB")
['Not', 'AB']
>>> camelSplit("NotABc")
['Not', 'a', 'bc']
>>> camelSplit("ABcD")
['A', 'bc', 'd']
>>> camelSplit('NotASingleUnderbar')
['Not', 'a', 'single', 'underbar']
>>> camelSplit("__",False)
['__']
>>> camelSplit("__andThis__",False)
['__and', 'this__']
>>> camelSplit("_so_",False)
['_so_']
>>> camelSplit("_thisShouldWork",False)
['_this', 'should', 'work']
>>> camelSplit("soShouldThis_",False)
['so', 'should', 'this_']
>>> camelSplit("CapsIsOK",False)
['Caps', 'is', 'OK']
>>> camelSplit("CapsAndACRIsOK",False)
['Caps', 'and', 'ACR', 'is', 'OK']
>>> camelSplit("CapsAndUS_ACRIsOK",False)
['Caps', 'and', 'US', 'ACR', 'is', 'OK']
>>> camelSplit("OKIsOk",False)
['OK', 'is', 'ok']
>>> camelSplit("CapsAndACR_IsNotOKButMayBeTolerated",False)
['Caps', 'and', 'ACR', 'is', 'not', 'OK', 'but', 'may', 'be', 'tolerated']
>>> camelSplit("",False)
[]
>>> camelSplit("thisIs_not_OK",False)
['this', 'is', 'not', 'OK']
>>> camelSplit("this_IS_AlsoWrong",False)
['this', 'IS', 'also', 'wrong']
>>> camelSplit("_and_thisToo",False)
['_and', 'this', 'too']
>>> camelSplit("",False)
[]
>>> camelSplit("very__bad",False)
Traceback (most recent call last):
...
ValueError: Illegal CamelCase name supplied: very__bad
>>> # STRICT
>>> camelSplit("_so_")
['_so_']
>>> camelSplit("_thisShouldWork")
['_this', 'should', 'work']
>>> camelSplit("soShouldThis_")
['so', 'should', 'this_']
>>> camelSplit("CapsIsOK")
['Caps', 'is', 'OK']
>>> camelSplit("CapsAndACRIsOK")
['Caps', 'and', 'ACR', 'is', 'OK']
>>> camelSplit("CapsAndUS_ACRIsOK")
['Caps', 'and', 'US', 'ACR', 'is', 'OK']
>>> camelSplit("OKIsOk")
['OK', 'is', 'ok']
>>> camelSplit("CapsAndACR_IsNotOKButMayBeTolerated")
['Caps', 'and', 'ACR', 'is', 'not', 'OK', 'but', 'may', 'be', 'tolerated']
>>> camelSplit("")
[]
>>> camelSplit("_so_", 0)
['_so_']
>>> camelSplit("_thisShouldWork", 0)
['_this', 'should', 'work']
>>> camelSplit("soShouldThis_", 0)
['so', 'should', 'this_']
>>> camelSplit("CapsIsOK", 0)
['Caps', 'is', 'OK']
>>> camelSplit("CapsAndACRIsOK", 0)
['Caps', 'and', 'ACR', 'is', 'OK']
>>> camelSplit("CapsAndUS_ACRIsOK", 0)
['Caps', 'and', 'US', 'ACR', 'is', 'OK']
>>> camelSplit("OKIsOk", 0)
['OK', 'is', 'ok']
>>> camelSplit("CapsAndACR_IsNotOKButMayBeTolerated", 0)
['Caps', 'and', 'ACR', 'is', 'not', 'OK', 'but', 'may', 'be', 'tolerated']
>>> camelSplit("CapsAndACR1_IsNotOKButMayBeTolerated", 0)
['Caps', 'and', 'ACR1', 'is', 'not', 'OK', 'but', 'may', 'be', 'tolerated']
>>> camelSplit("CONSTANTS_ARE_FINE",0)
['CONSTANTS', 'ARE', 'FINE']
>>> camelSplit("CapsAndUS_ACRIsOK", 0)
['Caps', 'and', 'US', 'ACR', 'is', 'OK']
>>> camelSplit("thisIs_not_OK", strict=False)
['this', 'is', 'not', 'OK']
>>> camelSplit("_butMagicNamesAreFine",0)
['_but', 'magic', 'names', 'are', 'fine']
>>> #numbers
>>> camelSplit("abc1")
['abc1']
>>> camelSplit("AbcD1")
['Abc', 'd1']
>>> camelSplit("abcD1")
['abc', 'd1']
>>> camelSplit("AB1_DE2")
['AB1', 'DE2']
>>> camelSplit("AB1De")
['AB1', 'de']
>>> camelSplit("thisIs_not_OK")
Traceback (most recent call last):
ValueError: Illegal CamelCase name supplied: thisIs_not_OK
>>> camelSplit("this_IS_AlsoWrong")
Traceback (most recent call last):
ValueError: Illegal CamelCase name supplied: this_IS_AlsoWrong
>>> camelSplit("_and_thisToo")
Traceback (most recent call last):
ValueError: Illegal CamelCase name supplied: _and_thisToo
"""


__test__['readPyString'] = r"""
>>> readPyString(''''""''""\'''')
('""', 0, 4)
>>> readPyString('"abc"')
('abc', 0, 5)
>>> readPyString('""')
('', 0, 2)
>>> readPyString('"abc"')
('abc', 0, 5)
>>> readPyString('''"a'bc '"''')[0]
"a'bc '"
>>> readPyString('''"a'bc'"''')
("a'bc'", 0, 7)
>>> readPyString('''"a\"bc"''')
('a', 0, 3)
>>> readPyString(r'''"a\"bc"''')
('a\\"bc', 0, 7)
>>> readPyString(r''' a\"bc"''')

>>> readPyString(r''' a\"bc"''', search=True)
('bc', 4, 8)
>>> readPyString(r''' 'a\"bc" ' ''')

>>> readPyString(r''' 'a\"bc" ' ''', search=True)
('a\\"bc" ', 1, 10)
>>> readPyString("'''abc\n'''")
('abc\n', 0, 10)
>>> readPyString(r"'''abc\n''ab\n\'''cde'''")
("abc\\n''ab\\n\\'''cde", 0, 24)
>>> readPyString(r'''""''')
('', 0, 2)
>>> readPyString("''''''")
('', 0, 6)
>>> readPyString("''''")
('', 0, 2)
""" #XXX this line is kludge for python-mode's broken coloring

__test__['formatStrRe'] = r'''
>>> from awmstools import sort
>>> def helper(s):
...     return "\n".join([", ".join(["%r: %r" % (k, v)
...                                  for (k,v) in sort(x.groupdict().items())])
...                       for x in formatStrRe.finditer(s)])
...
>>> print helper("not a %% match!"),
>>> print helper("a single string: %s")
'flag': None, 'name': None, 'precision': None, 'type': 's', 'width': None
>>> print helper("nothing %%%%s a float with precision 3: %%%.3f")
'flag': None, 'name': None, 'precision': '3', 'type': 'f', 'width': None
>>> print helper("nothing %%%%s a float with width 5, precision 3: %%%5.3f")
'flag': None, 'name': None, 'precision': '3', 'type': 'f', 'width': '5'
>>> print helper("nothing %%%%s a float with width -5, precision 3: %%%-5.3f")
'flag': '-', 'name': None, 'precision': '3', 'type': 'f', 'width': '5'
>>> print helper("nothing %%%%s a float with width and precision  in next: %%%*.*f")
'flag': None, 'name': None, 'precision': '*', 'type': 'f', 'width': '*'
>>> print helper("illegal format: %%%-.bf"),
>>> print helper("a couple %(0PaddedFloatW5P1)05.1f %(str)s %(h)h")
'flag': '0', 'name': '0PaddedFloatW5P1', 'precision': '1', 'type': 'f', 'width': '5'
'flag': None, 'name': 'str', 'precision': None, 'type': 's', 'width': None
'flag': None, 'name': 'h', 'precision': None, 'type': 'h', 'width': None
'''

##XXX
                       
                       
def _docTest():
     global _RAN
     try:
         _RAN; return
     except NameError:pass
     _RAN = True
     import doctest, awmsmeta
     global PRETTY_PRINT                 # XXX
     PRETTY_PRINT = False    
     return doctest.testmod(awmsmeta)
     PRETTY_PRINT = True
if __name__ in ("__main__", "__IPYTHON_main__"): _docTest()

#FIXME CONTINUEHERE
class Recorder(type):
    """ """
    def __init__(cls, name, bases, d):
        for n, m in getMethods(d).iteritems(o):
            sig = getFuncSignature(m)
            """\
%(funcDef)s
   if self._recording:
      foo

   %(funcCall)s

            """


# don't litter the namespace on ``from awmstools import *``
__all__ = []
me = sys.modules[__name__]
for n in dir(me):
    if n != me and not isinstance(getattr(me,n), type(me)):
        __all__.append(n)
del me




##############################################################################
################## mlabwrap: transparently wraps matlab(tm) ##################
##############################################################################
##
## o author: Alexander Schmolck (a.schmolck@gmx.net)
## o created: 2002-05-29 21:51:59+00:40
## o last modified: $Date: 2007-05-12 17:40:13 -0400 (Sat, 12 May 2007) $
## o version: see `__version__`
## o keywords: matlab wrapper
## o license: MIT
## o FIXME:
##   - it seems proxies can somehow still 'disappear', maybe in connection
##     with exceptions in the matlab workspace?
##   - add test that defunct proxy-values are culled from matlab workspace
##     (for some reason ipython seems to keep them alive somehwere, even after
##     a zaphist, should find out what causes that!)
##   - add tests for exception handling!
##   - the proxy getitem/setitem only works quite properly for 1D arrays
##     (matlab's moronic syntax also means that 'foo(bar)(watz)' is not the
##     same as 'tmp = foo(bar); tmp(watz)' -- indeed chances are the former
##     will fail (not, apparently however with 'foo{bar}{watz}' (blech)). This
##     would make it quite hard to the proxy thing 'properly' for nested
##     proxies, so things may break down for complicated cases but can be
##     easily fixed manually e.g.: ``mlab._set('tmp', foo(bar));
##     mlab._get('tmp',remove=True)[watz]``
##   - Guess there should be some in principle avoidable problems with
##     assignments to sub-proxies (in addition to the more fundamental,
##     unavoidable problem that ``proxy[index].part = foo`` can't work as
##     expected if ``proxy[index]`` is a marshallable value that doesn't need
##     to be proxied itself; see below for workaround).
## o XXX:
##   - better support of string 'arrays'
##   - multi-dimensional arrays are unsupported
##   - treatment of lists, tuples and arrays with non-numerical values (these
##     should presumably be wrapped into wrapper classes MlabCell etc.)
##   - should test classes and further improve struct support?
##   - should we transform 1D vectors into row vectors when handing them to
##     matlab?
##   - what should be flattend? Should there be a scalarization opition?
##   - ``autosync_dirs`` is a bit of a hack (and maybe``handle_out``, too)...
##   - is ``global mlab`` in unpickling of proxies OK?
##   - hasattr fun for proxies (__deepcopy__ etc.)
##   - check pickling
## o TODO:
##   - delattr
##   - better error reporting: test for number of input args etc.
##   - add cloning of proxies.
##   - pickling for nested proxies (and session management for pickling)
##   - more tests
## o !!!:
##   - matlab complex arrays are intelligently of type 'double'
##   - ``class('func')`` but ``class(var)``

"""
mlabwrap
========

This module implements a powerful and simple to use wrapper that makes using
matlab(tm) from python almost completely transparent. To use simply do:

>>> from mlabwrap import mlab

and then just use whatever matlab command you like as follows:

>>> mlab.plot(range(10), 'ro:')

You can do more than just plotting:

>>> mlab.sort([3,1,2])
array([[ 1.,  2.,  3.]])

N.B.: The result here is a 1x3 matrix (and not a flat lenght 3 array) of type
double (and not int), as matlab built around matrices of type double (see
``MlabWrap._flatten_row_vecs``).

Matlab(tm)ab, unlike python has multiple value returns. To emulate calls like
``[a,b] = sort([3,2,1])`` just do:

>>> mlab.sort([3,1,2], nout=2)
(array([[ 1.,  2.,  3.]]), array([[ 2.,  3.,  1.]]))

For names that are reserved in python (like print) do:

>>> mlab.print_()

You can look at the documentation of a matlab function just by using help,
as usual:

>>> help(mlab.sort)

In almost all cases that should be enough -- if you need to do trickier
things, then get raw with ``mlab._do``, or build your child class that
handles what you want.


Fine points and limitations
---------------------------

- Only 2D matrices are directly supported as return values of matlab
  functions (arbitrary matlab classes are supported via proxy objects --
  in most cases this shouldn't make much of a difference (as these proxy
  objects can be even pickled) -- still this functionality is yet
  experimental).

  One potential pitfall with structs (which are currently proxied) is that
  setting indices of subarrays ``struct.part[index] = value`` might seem
  to have no effect (since ``part`` can be directly represented as a
  python array which will be modified without an effect on the proxy
  ``struct``'s contents); in that case::

    some_array[index] = value; struct.part = some_array``

  will have the desired effect.
  
- Matlab doesn't know scalars, or 1D arrays. Consequently all functions
  that one might expect to return a scalar or 1D array will return a 1x1
  array instead. Also, because matlab(tm) is built around the 'double'
  matrix type (which also includes complex matrices), single floats and
  integer types will be cast to double. Note that row and column vectors
  can be autoconverted automatically to 1D arrays if that is desired (see
  ``_flatten_row_vecs``).

- for matlab(tm) function names like ``print`` that are reserved words in
  python, so you have to add a trailing underscore (e.g. ``mlab.print_``).

- sometimes you will have to specify the number of return arguments of a
  function, e.g. ``a,b,c = mlab.foo(nout=3)``. MlabWrap will normally try to
  figure out for you whether the function you call returns 0 or more values
  (in which case by default only the first value is returned!). For builtins
  this might fail (since unfortunately there seems to be no foolproof way to
  find out in matlab), but you can always lend a helping hand::

    mlab.foo = mlab._make_mlab_command('foo', nout=3, doc=mlab.help('foo'))

  Now ``mlab.foo()`` will by default always return 3 values, but you can still
  get only one by doing ``mlab.foo(nout=1)``

- by default the working directory of matlab(tm) is kept in synch with that of
  python to avoid unpleasant surprises. In case this behavior does instaed
  cause you unpleasant surprises, you can turn it off with::

    mlab._autosync_dirs = False

- you can customize how matlab is called by setting the environment variable
  ``MLABRAW_CMD_STR`` (unless you're using windows, in which case, it seems,
  you'll have to start a matlab session with the required parameters by other
  means -- e.g. by hand and mlabwrap will connect to it when you import it).

- if you don't want to use numpy arrays, but something else that's fine
  too::

    >>> import matrix from numpy.core.defmatrix
    >>> mlab._array_cast = matrix
    >>> mlab.sqrt([[4.], [1.], [0.]])
    matrix([[ 2.],
            [ 1.],
            [ 0.]])

Credits
-------

This is really a wrapper around a wrapper (mlabraw) which in turn is a
modified and bugfixed version of Andrew Sterian's pymat
(http://claymore.engineer.gvsu.edu/~steriana/Python/pymat.html), so thanks go
to him for releasing his package as open source.


See the docu of ``MlabWrap`` and ``MatlabObjectProxy`` for more information.
"""
__docformat__ = "restructuredtext en"
__revision__ = "$Id: _mlabwrap.py 102 2007-05-12 21:40:13Z aschmolck $"
__version__ = "1.0b2"
__author__   = "Alexander Schmolck (A.Schmolck@gmx.net)"
import warnings
from pickle import PickleError
import operator
import os, sys, re
import weakref
import atexit
import numpy
ndarray = numpy.ndarray
DEBUG = False


from tempfile import gettempdir, mkstemp as _mkstemp
mktemp = lambda *args,**kwargs: _mkstemp(*args, **kwargs)[1]
import mlabraw

from awmstools import ipupdate,slurpIn, spitOut, isString
from awmsmeta import gensym

#XXX: nested access
def _flush_write_stdout(s):
    """Writes `s` to stdout and flushes. Default value for ``handle_out``."""
    sys.stdout.write(s); sys.stdout.flush()

class CurlyIndexer(object):
    """A helper class to mimick ``foo{bar}``-style indexing in python."""
    def __init__(self, proxyRef):
        self.proxyRef = proxyRef
    def __getitem__(self, index):
        return self.proxyRef().__getitem__(index, '{}')
    def __setitem__(self, index, value):
        self.proxyRef().__setitem__(index, value, '{}')

def _expound_docstring(doc):
    """Ugly hack to guess ``nargout`` of a (builtin/Mex) matlab function from
       its docstring. FIXME this seems no longer necessary, apparently newer
       versions of matlab also provide a sensible ``nargout`` for builtins.
    """
    callSigRE = re.compile(r"""
    ^\s*
    # opitonally return values, either
    (?:
      (?P<argout>
            # A = FOO...
ppp            (?:[A-Z]+)
          |                     
            # [A,B] = FOO...
            \[
              (?:[A-Z]+,\s*)+[A-Z]+
            \]

      )\s*=\s*
    )?
    # the command name itself, upcased
    (?P<cmd>%s)
    # the (optional) arguments; either
    (?: 
        # FOO BAR QUUX (command syntax; this re doesn't work for
        # pathological cases like `print` and `delete`)
        (?P<cmdargs>(?:\s+[A-Z]+)+)?\s
     |
        # FOO(BAR, ...) (function call syntax)
        (?P<argin>
            \(
            .*
              (?:
               (?:\.\.\.),\s*
               |
               (?:['\w]+),\s*
              )*
            \)
        )
    )
    """ % name.upper(), re.X | re.M | re.I)
    match_at = lambda what: match[callSigRE.groupindex[what]-1]
    maxout = 0
    maxin = 0
    for match in callSigRE.findall(doc[doc.find("\n"):]):
        argout = match_at('argout')
        #FIXME how are infinite nouts specified in docstrings?
        if argout:
            maxout = max(maxout, len(argout.split(',')))
    if maxout == 0:
        # an additional HACK for docs that aren't following the
        # ``foo = bar(...)`` convention
        # XXX: doesn't work for 'DISPLAY(x) is called...' etc.
        if re.search(r'\b%s\(.+?\) (?:is|return)' % name.upper(), doc):
            maxout = 1
    nout = maxout #XXX
    return nout

        
class MlabObjectProxy(object):
    """A proxy class for matlab objects that can't be converted to python
       types.

       !!! Assigning to parts of proxy objects (e.g. ``proxy[index].part =
       [[1,2,3]]``) should *largely* work as expected, the only exception
       would be if ``proxy.foo[index] = 3`` where ``proxy.foo[index]`` is some
       type that can be converted to python (i.e. an array or string, (or
       cell, if cell conversion has been enabled)), because then ``proxy.foo``
       returns a new python object. For these cases it's necessary to do::

         some_array[index] = 3; proxy.foo = some_array

       """
    def __init__(self, mlabwrap, name, parent=None):
        self.__dict__['_mlabwrap'] = mlabwrap
        self.__dict__['_name'] = name
        """The name is the name of the proxies representation in matlab."""
        self.__dict__['_parent'] = parent
        #!!! use a weakref here so that matlab memory will be immediately
        #    reclaimed once the proxy is no longer needed (otherwise we'd have
        #    to wait for the cyclical GC)
        self.__dict__['_'] = CurlyIndexer(weakref.ref(self))
        """To fake matlab's ``obj{foo}`` style indexing."""
    ## methods to make proxies pseduo-ndarray like
    
    @property
    def shape(self):
        return tuple(self._mlabwrap._do('size(%s)' % (self._name)))
    @property
    def ndim(self):
        return int(self.__dict__['_mlabwrap']._do('ndims(%s)' % (self.__dict__['_name'])).item())
    def __len__(self):
        return self.shape[0] #FIXME
    def __iter__(self):
        for i in xrange(len(self)):
            yield numpy.squeeze(self[i]) #FIXME
    def conj(self):
        return self._mlabwrap.conj(self)
    def ravel(self):
        return self._mlabwrap.flat(self) #XXX
    flat = property(ravel)
    @property
    def T(self): return self._mlabwrap.transpose(self) #FIXME
    @property
    def H(self): return self._mlabwrap.ctranspose(self) #FIXME
    @property
    def imag(self): return self._mlabwrap.imag(self)
    @property
    def real(self): return self._mlabwrap.real(self)
    # FIXME ``rdivide``
    # FIXME waht about ``item``? ``max``,``min`` etc?
    
    ## end of pseudo-array support
    def __getstate__(self):
        "Experimental pickling support."
        if self.__dict__['_parent']:
            raise PickleError(
                "Only root instances of %s can currently be pickled." % \
                type(self).__name__)
        tmp_filename = os.path.join(gettempdir(), "mlab_pickle_%s.mat" %
                                    str(self._mlabwrap._session).split()[-1][:-1])
        try:
            mlab.save(tmp_filename, self._name)
            mlab_contents = slurpIn(tmp_filename, binary=1)
        finally:
            if os.path.exists(tmp_filename): os.remove(tmp_filename)

        return {'mlab_contents' : mlab_contents,
                'name': self._name}
        
        
    def __setstate__(self, state):
        "Experimental unpickling support."
        global mlab         #XXX this should be dealt with correctly
        old_name = state['name']
        mlab_name = "UNPICKLED%s__" % gensym('')
        try:
            tmp_filename = mktemp('.mat')
            spitOut(state['mlab_contents'], tmp_filename, binary=1)
            mlab._raw_eval(
              "TMP_UNPICKLE_STRUCT__ = load('%s', '%s');" % (
                tmp_filename, old_name))
            mlab._raw_eval(
              "%s = TMP_UNPICKLE_STRUCT__.%s;" % (mlab_name, old_name))
            mlab._raw_eval("clear TMP_UNPICKLE_STRUCT__;")
            # XXX
            mlab._make_proxy(mlab_name, constructor=lambda *args: self.__init__(*args) or self)
            mlab._raw_eval('clear %s;' % mlab_name)
        finally:
            if os.path.exists(tmp_filename): os.remove(tmp_filename)
            # FIXME clear'ing in case of error
        
    def __repr__(self):
        output = []
        mlab._do('disp(%s)' % self._name, nout=0, handle_out=output.append)
        rep = "".join(output)
        klass = self._mlabwrap._do("class(%s)" % self._name)
##         #XXX what about classes?
##         if klass == "struct":
##             rep = "\n" + self._mlabwrap._format_struct(self._name)
##         else:
##             rep = ""
        return "<%s of matlab-class: %r; internal name: %r; has parent: %s>\n%s" % (
            type(self).__name__, klass,
            self._name, ['yes', 'no'][not self._parent],
            rep)
    def __del__(self):
        if not self._parent:
            self._mlabwrap._raw_eval('clear %s;' % self._name)
    def _get_part(self, to_get):
        print 'get_part: ', to_get
        if self._mlabwrap._var_type(to_get) in self._mlabwrap._mlabraw_can_convert:
            #!!! need assignment to TMP_VAL__ because `mlabraw.get` only works with
            #    'atomic' values like ``foo`` and not e.g. ``foo.bar``.
            self._mlabwrap._raw_eval("TMP_VAL__=%s" % to_get)
            return self._mlabwrap._get('TMP_VAL__', remove=True)
        return type(self)(self._mlabwrap, name=to_get, parent=self)
    def _set_part(self, to_set, value):
        #FIXME s.a.
        if isinstance(value, MlabObjectProxy):
            self._mlabwrap._raw_eval("%s = %s;" % (to_set, value._name))
        else:
            self._mlabwrap._set("TMP_VAL__", value)
            self._mlabwrap._raw_eval("%s = TMP_VAL__;" % to_set)
            self._mlabwrap._raw_eval('clear TMP_VAL__;')
    def __getattr__(self, attr):
        return self._get_part("%s.%s" % (self._name, attr))
    def __setattr__(self, attr, value):
        self._set_part("%s.%s" % (self._name, attr), value)
    #FIXME: those two only work ok for vectors
    def _convert_index(self, index):
        def convert_individual_index(index):
            if isinstance(index, int): # XXX there might be a better type-check
                if index < 0:
                    return "end%+d" % (index+1)
                else:
                    return str(index + 1)
            elif isString(index):
                return "'%s'" % index
            elif isinstance(index, slice):
                if index == slice(None,None,None):
                    return ":"
                else:
                    start, stop, step = index.start, index.stop, index.step
                    if start is None:
                        if (step or 1)  < 0:
                            mstart = 'end'
                        else:
                            mstart = '1'
                    elif start < 0:   mstart = 'end%d' % (start-1)
                    else:             mstart = str(start+1)

                    if stop is None:
                        if (step or 1) < 0:
                            mstop = '1'
                        else:
                            mstop  = 'end'
                    elif stop < 0:    mstop  = 'end%d' % stop
                    else:             mstop  = str(stop)
                    print "DEBUG: ", mstart + ':' + str(step) + ':' + mstop
                    if step is not None:
                        return mstart + ':' + str(step) + ':' + mstop
                    else:
                        return mstart + ':' + mstop
            # XXX could also handle arrays, lists and tuples, but not right now
            else:
                raise TypeError("Unsupported proxy index type: %r." % type(index))
        if isinstance(index, tuple):
            return ",".join(map(convert_individual_index, index))
        else:
            return convert_individual_index(index)

    def __getitem__(self, index, parens='()'):
        """XXX Semi-finished HACK. Matlab decadently allows overloading *2*
           different indexing parens, ``()`` and ``{}``, hence the ``parens``
           option."""
        index = self._convert_index(index)
        return self._get_part("".join([self._name,parens[0],index,parens[1]]))
    def __setitem__(self, index, value, parens='()'):
        index = self._convert_index(index)
        return self._set_part("".join([self._name,parens[0],index,parens[1]]),
                                      value)
    
class MlabConversionError(Exception):
    """Raised when a mlab type can't be converted to a python primitive."""
    pass


class RawEngine (object):
    """Object-oriented interface to the functions defined in the mlabraw
       extension module.
    """
    def __init__(self):
        self._engine = mlabraw.open(os.getenv("MLABRAW_CMD_STR", ""))
        atexit.register(lambda self=self: self.close())
    def eval(self, cmd):
        if DEBUG: print "evalling '%s'"%cmd
        return mlabraw.eval(self._engine, cmd)
    def get(self, name):
        if DEBUG: print "getting '%s'"%name
        return mlabraw.get(self._engine, name)
    def set(self, name, value):
        if DEBUG: print "setting '%s' to %s"%(name, `value`)
        mlabraw.put(self._engine, name, value)
    def close(self):
        try: mlabraw.close(self._engine)
        except: pass
    def __del__(self): self.close()

    
class MlabWrap(object):
    """This class does most of the wrapping work. It manages a single matlab
       session (you can in principle have multiple open sessions if you want,
       but I can see little use for this, so this feature is largely untested)
       and automatically translates all attribute requests (that don't start
       with '_') to the appropriate matlab function calls. The details of this
       handling can be controlled with a number of instance variables,
       documented below."""
    __all__ = [] #XXX a hack, so that this class can fake a module
    def __init__(self):
        """Create a new matlab(tm) wrapper object.
        """
        self._array_cast  = None
        """specifies a cast for arrays. If the result of an
        operation is a numpy array, ``return_type(res)`` will be returned
        instead."""
        self._autosync_dirs=True
        """`autosync_dirs` specifies whether the working directory of the
        matlab session should be kept in sync with that of python."""
        self._flatten_row_vecs = False
        """Automatically return 1xn matrices as flat numpy arrays."""
        self._flatten_col_vecs = False
        """Automatically return nx1 matrices as flat numpy arrays."""
        self._clear_call_args = True
        """Remove the function args from matlab workspace after each function
        call. Otherwise they are left to be (partly) overwritten by the next
        function call. This saves a function call in matlab but means that the
        memory used up by the arguments will remain unreclaimed till
        overwritten."""
        self._session = RawEngine()
        self._proxies = weakref.WeakValueDictionary()
        """Use ``mlab._proxies.values()`` for a list of matlab object's that
        are currently proxied."""
        self._proxy_count = 0
        self._mlabraw_can_convert = ('double', 'char')
        """The matlab(tm) types that mlabraw will automatically convert for us."""
        self._dont_proxy = {'cell' : False}
        """The matlab(tm) types we can handle ourselves with a bit of
           effort. To turn on autoconversion for e.g. cell arrays do:
           ``mlab._dont_proxy["cell"] = True``."""

    def _format_struct(self, varname):
        res = []
        fieldnames = self._do("fieldnames(%s)" % varname)
        size       = numpy.ravel(self._do("size(%s)" % varname))
        return "%dx%d struct array with fields:\n%s" % (
            size[0], size[1], "\n   ".join([""] + fieldnames))
##         fieldnames
##         fieldvalues = self._do(",".join(["%s.%s" % (varname, fn)
##                                          for fn in fieldnames]), nout=len(fieldnames))
##         maxlen = max(map(len, fieldnames))
##         return "\n".join(["%*s: %s" % (maxlen, (`fv`,`fv`[:20] + '...')[len(`fv`) > 23])
##                                        for fv in fieldvalues])
        
    def _var_type(self, varname):
        self._raw_eval("TMP_CLS__ = class(%s);" % varname) #FIXME for funcs we would need ''s
        res_type = self._session.get("TMP_CLS__")
        self._raw_eval("clear TMP_CLS__;") # unlikely to need try/finally to ensure clear
        return res_type
    
    def _make_proxy(self, varname, parent=None, constructor=MlabObjectProxy):
        """Creates a proxy for a variable.

        XXX create and cache nested proxies also here.
        """
        proxy_val_name = "PROXY_VAL%d__" % self._proxy_count
        self._proxy_count += 1
        self._raw_eval("%s = %s;" % (proxy_val_name, varname))
        res = constructor(self, proxy_val_name, parent)
        self._proxies[proxy_val_name] = res
        return res
    
    def _get_cell(self, varname):
        # XXX can currently only handle ``{}`` and 1D cells
        self._raw_eval(
          "TMP_SIZE_INFO__ = \
           [all(size(%(vn)s) == 0), \
           min(size(%(vn)s)) == 1 & ndims(%(vn)s) == 2, \
           max(size(%(vn)s))];" % {'vn':varname})
        is_empty, is_rank1, cell_len = map(int,
                                           self._get("TMP_SIZE_INFO__", remove=True).flat)
        if is_empty:
            return []
        elif is_rank1:
            cell_bits = (["TMP%i%s__" % (i, gensym('_'))
                           for i in range(cell_len)])
            self._raw_eval('[%s] = deal(%s{:});' %
                       (",".join(cell_bits), varname))
            # !!! this recursive call means we have to take care with
            # overwriting temps!!!
            return self._get_values(cell_bits)
        else:
            raise MlabConversionError("Not a 1D cell array")
    def _manually_convert(self, varname, vartype):
        if vartype == 'cell':
            return self._get_cell(varname)
        else:
            raise MlabConversionError('unsupported matlab type: %s' % vartype)
    def _get_values(self, varnames):
        if not varnames: raise ValueError("No varnames") #to prevent clear('')
        res = []
        for varname in varnames:
            res.append(self._get(varname))
        self._raw_eval("clear('%s');" % "','".join(varnames)) #FIXME wrap try/finally?
        return res

    def _raw_eval(self, cmd):
        return self._session.eval(cmd)

    def _raw_get(self, name):
        return self._session.get(name)

    def _raw_set(self, name, value):
        self._session.set(name, value)

    def _do(self, cmd, *args, **kwargs):
        """Semi-raw execution of a matlab command.
        
        Smartly handle calls to matlab, figure out what to do with `args`,
        and when to use function call syntax and not.
        
        If no `args` are specified, the ``cmd`` not ``result = cmd()`` form is
        used in Matlab -- this also makes literal Matlab commands legal
        (eg. cmd=``get(gca, 'Children')``).

        If ``nout=0`` is specified, the Matlab command is executed as
        procedure, otherwise it is executed as function (default), nout
        specifying how many values should be returned (default 1).

        **Beware that if you use don't specify ``nout=0`` for a `cmd` that
        never returns a value will raise an error** (because assigning a
        variable to a call that doesn't return a value is illegal in matlab).
        

        ``cast`` specifies which typecast should be applied to the result
        (e.g. `int`), it defaults to none.

        XXX: should we add ``parens`` parameter?
        """
        handle_out = kwargs.get('handle_out', _flush_write_stdout)
        # HACK
        if self._autosync_dirs:
            self._raw_eval("cd('%s');" % os.getcwd().replace("'", "''"))
        nout =  kwargs.get('nout', 1)
        #XXX what to do with matlab screen output
        argnames = []
        tempargs = []
        try:
            for count, arg in enumerate(args):
                if isinstance(arg, MlabObjectProxy):
                    argnames.append(arg._name)
                else:
                    nextName = 'arg%d__' % count
                    argnames.append(nextName)
                    tempargs.append(nextName)
                    self._raw_set(argnames[-1], arg)

            if args:
                cmd = "%s(%s)%s" % (cmd, ", ".join(argnames),
                                    ('',';')[kwargs.get('show',0)])
            # got three cases for nout:
            # 0 -> None, 1 -> val, >1 -> [val1, val2, ...]
            if nout == 0:
                handle_out(self._raw_eval(cmd))
                return
            # deal with matlab-style multiple value return
            resSL = ((["RES%d__" % i for i in range(nout)]))
            handle_out(self._raw_eval('[%s]=%s;' % (", ".join(resSL), cmd)))
            res = self._get_values(resSL)

            if nout == 1: res = res[0]
            else:         res = tuple(res)
            if kwargs.has_key('cast'):
                if nout == 0: raise TypeError("Can't cast: nout is 0")
                return kwargs['cast'](res)
            else:
                return res
        finally:
            try:
                if len(tempargs) and self._clear_call_args:
                    self._raw_eval("clear('%s');" % "','".join(tempargs))
            except: pass

    def _get(self, name, remove=False):
        """This is really raw, no conversion of [[]] -> [], whatever."""
        # FIXME should this really be needed in normal operation?
        if name in self._proxies: return self._proxies[name]
        varname = name
        vartype = self._var_type(varname)
        if vartype in self._mlabraw_can_convert:
            var = self._raw_get(varname)
            if isinstance(var, ndarray):
                if self._flatten_row_vecs and numpy.shape(var)[0] == 1:
                    var.shape = var.shape[1:2]
                elif self._flatten_col_vecs and numpy.shape(var)[1] == 1:
                    var.shape = var.shape[0:1]
                if self._array_cast:
                    var = self._array_cast(var)
        else:
            var = None
            if self._dont_proxy.get(vartype):
                # manual conversions may fail (e.g. for multidimensional
                # cell arrays), in that case just fall back on proxying.
                try:
                    var = self._manually_convert(varname, vartype)
                except MlabConversionError: pass
            if var is None:
                # we can't convert this to a python object, so we just
                # create a proxy, and don't delete the real matlab
                # reference until the proxy is garbage collected
                var = self._make_proxy(varname)
        if remove:
            self._raw_eval("clear('%s');" % varname)
        return var
    
    def _set(self, name, value):
        if isinstance(value, MlabObjectProxy):
            self._raw_eval("%s = %s;" % (name, value._name))
        else:
            self._raw_set(name, value)

    def _make_mlab_command(self, name, nout, doc=""):
        def mlab_command(*args, **kwargs):
            return self._do(name, *args, **ipupdate({'nout': nout}, kwargs))
        # FIXME should assign __name__
        mlab_command.__doc__ = "\n" + doc
        return mlab_command
            
    # XXX this method needs some refactoring, but only after it is clear how
    # things should be done (e.g. what should be extracted from docstrings and
    # how)
    def __getattr__(self, attr):
        """Magically creates a wapper to a matlab function, procedure or
        object on-the-fly."""
        if re.search(r'\W', attr): # work around ipython <= 0.7.3 bug
            raise ValueError("Attributes don't look like this: %r" % attr)
        if attr.startswith('__'): raise AttributeError, attr
        assert not attr.startswith('_') # XXX
        # FIXME extract this to a method
        # print_ -> print
        if attr[-1] == "_": name = attr[:-1]
        else             : name = attr
        # XXX make sure we get an int out of this (ravel is mainly for `Matrix`)
        typ = int(numpy.ravel(self._do("exist('%s')" % name))[0])
        if typ == 0: # doesn't exist
            raise AttributeError("No such matlab object: %s" % name)
        else:
            doc = self._do("help('%s')" % name)
            # XXX should really find out under what conditions this fails,
            # it's e.g. not clear to me why ``nargout('netcdf')`` won't
            # work.
            try:
                nout = self._do("nargout('%s')" % name)
            except mlabraw.error, msg:
                assert typ != 2
                warnings.warn(
                    "Couldn't ascertain number of output args" + \
                    "for '%s', assume 1." % name)
                nout = 1
        # play it safe only return 1st if nout >= 1
        # XXX are all ``nout>1``s also useable as ``nout==1``s?
        nout = nout and 1
        mlab_command = self._make_mlab_command(name, nout, doc)
        #!!! attr, *not* name, because we might have python keyword name!
        setattr(self, attr, mlab_command)
        return mlab_command


mlab = MlabWrap()
# XXX fixup the `round` builtin; there might be others that could use a hand
mlab.round = mlab._make_mlab_command('round', nout=1, doc=mlab._raw_eval("help('round')"))
MlabError = mlabraw.error

def saveVarsInMat(filename, varNamesStr, outOf=None, **opts):
    """Hacky convinience function to dump a couple of python variables in a
       .mat file. See `awmstools.saveVars`.
    """
    from mlabwrap import mlab
    filename, varnames, outOf = awmstools.__saveVarsHelper(
        filename, varNamesStr, outOf, '.mat', **opts)
    try:
        for varname in varnames:
            mlab._set(varname, outOf[varname])
        mlab._do("save('%s','%s')" % (filename, "', '".join(varnames)), nout=0)
    finally:
        assert varnames
        mlab._do("clear('%s')" % "', '".join(varnames), nout=0)

__all__ = ['mlab', 'saveVarsInMat', 'MlabWrap', 'MlabError']

# Uncomment the following line to make the `mlab` object a library so that
# e.g. ``from mlabwrap.mlab import plot`` will work

## if not sys.modules.get('mlabwrap.mlab'): sys.modules['mlabwrap.mlab'] = mlab

##############################################################################
############## itest: interactive testing support for unittest ###############
##############################################################################
##
## o authors: Alexander Schmolck (a.schmolck@gmx.net), Brian Hawthorne
## o created: 2004-10-09 00:52:25+00:40
## o last modified: $Date$
## o keywords: unit testing; python; interactive development
## o license: MIT
## o XXX: - note there (now?) also is .debug method for TestSuite, but this is
##          still more convenient

"""
itest: enabling interactive unit-testing and debugging
======================================================

Suppose you have a module called ``spam_module.py``, and want to develop,
debug and test it with unit-testing. The traditional edit-run(everything again
from scratch)-debug-cycle is a pain: for example the tests will always be run
in the same order, although after making changes to ``spam_module`` you'd like
to run the first test that failed last time again at the beginning, to see
whether your changes corrected the problem rather than wait for half an hour
till all the tests before have finished. Additionally it's often difficult or
inconvenient to find the exact causes of a test-failure by just looking at the
the test-results print-out, i.e. without the ability to interactively inspect
with pdb what has been going on in the frame where the test failed.

Wouldn't it be much nicer if you could just develop both ``spam_module.py``
and the corresponding tests in a genuinely interactive fashion (automatically
starting a pdb session and jumping to the line in spam_module that failed;
starting off again at the same place after making changes to ``spam_module``
etc)?

Here ipython/emacs/itest come to the rescue.

Here is a template how-to:

    # test_spam_module.py
    
    from unittest import TestCase
    class BarTest(TestCase):
        def testBasic(self):
            assert 6*7 42
            print 'tested 6*7!'
        def testBarness(self):
            assert False
            # ... more tests
            
    # ... more TestCases
    if __name__ == '__main__':
        from itest import main, setPermeable, setRotating
        setRotating();  # start again at last failed testcase
        setPermeable(); # pass exceptions thru
        main()


To use interactively in ipython/emacs::

  In [1]: pdb on

  In [2]: run test_spam_module

This runs the tests, till a failure occurs (say in ``BarTest.testBarness``);
the failure will throw you into the debugger were you than can inspect what
has gone wrong and how (emacs will jump to the right file and line number). 

Edit and fix ``spam_module``; then::

  In [3]: reload(spam_module)

and run the test again::

  In [4]: run test_spam_module

  Resuming testing were we left off...

(Note: if the first import failed, you might need one more ``import
test_spam_module`` before being able to reload)

    
Note that ``testBarness`` is run again *first* although it is second in the list;
that's because due to the ``setRotating()`` we automagically start again were the
first failure occurred (great time-saver for larger ``TestSuite``s).

"""
__docformat__ = "restructuredtext en"
__revision__ = "$Id$"
__version__  = "0.1"
__authors__   = "Alexander Schmolck (A.Schmolck@gmx.net); Brian Hawthorne"
__all__ = [
  'PermeableTestCase', 'setPermeable', 'RotatingTestSuite', 'setRotating', 'clear', 'main']
import sys, os, types
try: set
except NameError: from sets import Set as set
import unittest
# XXX could also do a reload of unittest, or create a dummy-module on-the-fly
unittest.__originalTestCaseRun = unittest.TestCase.run
unittest.__originalTestSuiteRun = unittest.TestSuite.run

# customizable; 'check' and 'bench' are there for NumpyTestCase compatibility,
# but are not needed if numpy.testing isn't used
testPrefixes = 'test check bench'.split()



# the state of what's being tested currently in the interactive session
currentlyTesting = {}


def _magicGlobals(level=1):
    r"""Return the globals of the *caller*'s caller (default), or `level`
    callers up."""
    import inspect
    return inspect.getouterframes(inspect.currentframe())[1+level][0].f_globals


def _updateClass(oldClass, newClass):
    """Destrucitively modify the ``__dict__`` and ``__bases__`` contents of
   `oldClass` to be the same as of `newClass`. This will have the effect that
   `oldClass` will exhibit the same behavior as `newClass`.

    Won't work for classes with ``__slots__`` (which are an abomination
    anyway).
    """
    assert newClass is not oldClass
    import re
    _MethodDescriptorType = type(dict.clear) #FIXME)    
    IGNORED_NAMES = ('__weakref__', '__dict__')
    assert type(oldClass) is type(newClass) is type #FIXME
    dontUpdate = set()
    for name in dir(oldClass):
        if name in IGNORED_NAMES: continue #FIXME
        try:
            delattr(oldClass, name)
        except (AttributeError, TypeError):
            if (isinstance(getattr(oldClass, name),
                           (types.BuiltinMethodType, _MethodDescriptorType)) or 
                re.match('__.*__$',name) or 
                any(hasattr(c,name) for c in oldClass.__bases__)):
                dontUpdate.add(name)
            else:
                raise
    for name in dir(newClass):
        if name in IGNORED_NAMES: continue #FIXME
        if name in newClass.__dict__ and name not in dontUpdate:
##         if (not name.startswith('__') or not name.endswith('__')) and \
##                name not in dontUpdate:
            setattr(oldClass, name, newClass.__dict__[name])
    # XXX should check that this is absolutely correct
    oldClass.__bases__ = newClass.__bases__
    #if dontUpdate: print "###DEBUG couldn't update in %s: %s" % (oldClass.__name__, dontUpdate)

def _without(seq1, seq2):
    r"""Return a list with all elements in `seq2` removed from `seq1`, order
    preserved.

    Examples:

    >>> without([1,2,3,1,2], [1])
    [2, 3, 2]
    """
    d2 = set(seq2)
    return [elt for elt in seq1 if elt not in d2]


def rotate(l, steps=1):
    if len(l):
        steps %= len(l)
        if steps:
            firstPart = l[:steps]
            del l[:steps]
            l.extend(firstPart)
_unique = object()
def getTestMethodName(tc, default=_unique):
    """This hack is to support different versions of unittest older versions
    of unittest (pre python2.4 ?) used a private (double underscore) attribute
    whereas newer ones use a protected one (single underscore). In either case
    it's not really part of the API prope, but that can't be helped.
    """
    if hasattr(tc, '_testMethodName'):
        return tc._testMethodName
    else:
        if default is _unique:
            return getattr(tc, '_TestCase__testMethodName')
        else:
            return getattr(tc, '_TestCase__testMethodName', default)
        
def getTestMethod(tc):
    return getattr(tc, getTestMethodName(tc))

def _permeableTestCaseRun(self, result=None):
    if result is None: result = self.defaultTestResult()
    result.startTest(self)
    testMethod = getTestMethod(self)
    try:
        try:
            self.setUp()
            testMethod()
            result.addSuccess(self)
        finally:
            self.tearDown()
    finally:
        result.stopTest(self)

def setPermeable(permeable=True):
    if permeable:
        unittest.TestCase.run = _permeableTestCaseRun
    else:
        unittest.TestCase.run = unittest.__originalTestCaseRun

def _getTestCaseNames(testCase):
    import operator
    return reduce(operator.add, [unittest.getTestCaseNames(testCase, prefix) for prefix in testPrefixes])
def _rotatingTestSuiteRun(self, result):
    """Drop-in replacement for `TestSuite.run`: idea: """
    print "###DEBUG updating test-suite %s ..." % self
    global currentlyTesting
    testCases = list(set(map(type, self._tests)))
    testCases = filter(lambda x: issubclass(x,unittest.TestCase), testCases) # DEBUG
    # make sure all TestCases subclasses are up-to-date and that if
    # test*methods have been added, they are included
    for testCase in testCases:
        if not issubclass(testCase, unittest.TestCase):
            import warnings
            warnings.warn('test is not a testcase, not sure this will be handled right: %r' % testCase)
        testKey = repr(testCase)
        if testKey in currentlyTesting:
            maybeOldTestCase=getattr(sys.modules[testCase.__module__], testCase.__name__)
            if testCase is not maybeOldTestCase: # FIXME
                _updateClass(testCase, maybeOldTestCase)
                print "##DEBUG updated testCase", testCase
        else:
            currentlyTesting[testKey] = testCase
            print "##DEBUG added testCase", testCase
        # if the TestCase subclass has been updated with new methods,
        # add them to ``self._tests``
        newTestCaseNames = _without(_getTestCaseNames(testCase),
                                    filter(None,[getTestMethodName(test,None) for test in self._tests]))
        print "##DEBUG added new TestCaseNames", newTestCaseNames
        self._tests.extend(map(testCase, newTestCaseNames))
    for test in self._tests[:]:
        if result.shouldStop:
            break
        test(result)
        if result.wasSuccessful():
            rotate(self._tests)
            print "##DEBUG rotated self._tests", self._tests
    return result

def setRotating(rotating=True):
    if rotating:
        unittest.TestSuite.run =  _rotatingTestSuiteRun
    else:
        unittest.TestSuite.run =  unittest.__originalTestSuiteRun

def clear():
    global currentlyTesting
    currentlyTesting.clear()

def main(*args,**kwargs):
    global currentlyTesting
    callersFilename = os.path.abspath(_magicGlobals()['__file__'])
    print "###DEBUG callersFilename", callersFilename
    if len(sys.argv) < 1:
        print "#DEBUG fixing up sys.argv from", sys.argv
        sys.argv = [callersFilename]
    if callersFilename in currentlyTesting:
        print "###DEBUG tested this before", callersFilename        
        main = currentlyTesting[callersFilename]
    else:
        print "###DEBUG creating new test suite", callersFilename, currentlyTesting
        _rt = unittest.main.runTests
        unittest.main.runTests = lambda *a,**kw: None
        try:
            main = currentlyTesting[callersFilename] = unittest.main(*args, **kwargs)
        finally:
            unittest.main.runTests = _rt
    main.runTests()
        

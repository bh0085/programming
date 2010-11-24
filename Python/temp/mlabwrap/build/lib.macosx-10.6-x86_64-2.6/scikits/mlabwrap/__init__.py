from _mlabwrap import mlab, saveVarsInMat, MlabWrap, MlabError

def test(level=1, verbosity=2, permeable=True, rotating=True):
    from numpy.testing import NumpyTest
    from scikits.testing import setPermeable, setRotating
    setPermeable(permeable); setRotating(rotating)
    NumpyTest().test(level=level, verbosity=verbosity)

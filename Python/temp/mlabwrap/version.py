MODULE_NAME = None   # name of this module, taken from dir if not specified
version = '1.9'      # release version of the module
release = False      # if False, add svn-revision to version number
if not release:
    version += '.dev'
    import os
    thisDir = os.path.dirname(__file__)
    MODULE_NAME = MODULE_NAME or os.path.split(thisDir)[-1]
    svn_version_file = os.path.join(thisDir, '__svn_version__.py')
    if os.path.isfile(svn_version_file):
        import imp
        svn = imp.load_module(MODULE_NAME + '.__svn_version__',
                              open(svn_version_file),
                              svn_version_file,
                              ('.py','U',1))
        version += svn.version
__all__ = 'version release'.split()

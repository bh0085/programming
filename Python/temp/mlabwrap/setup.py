#!/usr/bin/env python
##############################################################################
########################### setup.py for mlabwrap ############################
##############################################################################
## o author: Alexander Schmolck (a.schmolck@gmx.net)
## o created: 2003-08-07 17:15:22+00:40
## o last modified: $Date: 2008-04-15 04:57:33 -0400 (Tue, 15 Apr 2008) $

####################################################################
##### VARIABLES YOU MIGHT HAVE TO CHANGE FOR YOUR INSTALLATION #####
##### (if setup.py fails to guess the right values for them)   #####
####################################################################
import os
MATLAB_VERSION = os.getenv("MATLAB_VERSION") # e.g: 6 (one of (6, 6.5, 7, 7.3))
MATLAB_DIR=os.getenv("MATLAB") # e.g: '/usr/local/matlab'; 'c:/matlab6'
PLATFORM_DIR=None           # e.g: 'glnx86'; r'win32/microsoft/msvc60'
EXTRA_COMPILE_ARGS=None     # e.g: ['-G']

# hopefully these 3 won't need modification
MATLAB_LIBRARIES=None       # e.g: ['eng', 'mx', 'mat', 'mi', 'ut']
SUPPORT_MODULES= ["awmstools", "awmsmeta"] # set to [] if already 
                                           # installed
# DON'T FORGET TO DO SOMETHING LIKE:
#   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/MATLAB_DIR/extern/lib/glnx86/

########################### WINDOWS ONLY ###########################
#  Option 1: Visual Studio
#  -----------------------
#  only needed for Windows Visual Studio (tm) build
#  (adjust if necessary if you use a different version/path of VC)
VC_DIR='C:/Program Files/Microsoft Visual Studio .NET 2003/vc7'
# NOTE: You'll also need to adjust PLATFORM_DIR accordingly 
#
#  Option 2: Borland C++
#  ---------------------
#  uncomment (and adjust if necessary) the following lines to use Borland C++
#  instead of VC:
#
#VC_DIR=None
#PLATFORM_DIR="win32/borland/bc54"


####################################################################
### NO MODIFICATIONS SHOULD BE NECESSARY BEYOND THIS POINT       ###
####################################################################
# *******************************************************************

import sys
import setuptools
from numpy.distutils.core import setup, Extension
import os.path, glob
import re
from tempfile import mkstemp as _mkstemp
mktemp = lambda *args,**kwargs: _mkstemp(*args, **kwargs)[1]
#if sys.version_info < (2,5):
#    print >> sys.stderr, "You need at least python 2.5"
#    sys.exit(1)
import numpy
PYTHON_INCLUDE_DIR = numpy.get_include()


def configuration(parent_package='scikits',top_path=None):
    from numpy.distutils.misc_util import Configuration
    config = Configuration('mlabwrap',parent_package,top_path)
##     config.add_subpackage('distutils')
##     config.add_data_dir('doc')
    #config.add_data_dir('tests')
    config.make_svn_version_py(delete=False) #FIXME DEBUG
    return config

def matlab_params(matlab_command_str):
    param_fname = mktemp()
    startup = "fid = fopen('%s', 'wt');" % param_fname + \
              r"fprintf(fid, '%s|%s|%s|', version, matlabroot, computer);" + \
              "fclose(fid); quit"
    try:
        print "MATLAB_CMD_STR=",matlab_command_str
        os.system(matlab_command_str % startup)
        fh = None; fh = open(param_fname)
        ver, pth, platform = fh.readlines()[0].split('|')[:3]
        print "MATLAB_PARAMS:", ver,pth,platform
        return (float(re.match(r'\d+.\d+',ver).group()),
                pth.rstrip(), platform.rstrip().lower())
    finally:
        if fh: fh.close()
        try:
            os.remove(param_fname)
        except WindowsError, msg: # XXX 
            print >>sys.stderr, "XXX Windows specific problem: please remove tempfile by hand:\n", msg

# windows
WINDOWS=sys.platform.startswith('win')
if None in (MATLAB_VERSION, MATLAB_DIR, PLATFORM_DIR):
    cmd = os.getenv('MLABRAW_CMD_STR', 'matlab') + ' -nodesktop -nosplash -r "%s"'
    if not WINDOWS:
        cmd+=' >/dev/null'
    if len(sys.argv) > 1 and sys.argv[1] not in ("dist","clean"):
        queried_version, queried_dir, queried_platform_dir = matlab_params(cmd)
    else:
        queried_version, queried_dir, queried_platform_dir = ["WHATEVER"]*3
    MATLAB_VERSION = MATLAB_VERSION or queried_version
    MATLAB_DIR = MATLAB_DIR or queried_dir
    PLATFORM_DIR = PLATFORM_DIR or queried_platform_dir
if WINDOWS:
    WINDOWS=True
    EXTENSION_NAME = 'mlabraw'
    MATLAB_LIBRARIES = MATLAB_LIBRARIES or 'libeng libmx'.split()
    CPP_LIBRARIES = [] #XXX shouldn't need CPP libs for windoze
# unices
else:
    EXTENSION_NAME = 'mlabrawmodule'
    if not MATLAB_LIBRARIES:
        if MATLAB_VERSION >= 6.5:
            MATLAB_LIBRARIES = 'eng mx mat ut'.split()
        else:
            MATLAB_LIBRARIES = 'eng mx mat mi ut'.split()
    CPP_LIBRARIES = ['stdc++'] #XXX strangely  only needed on some linuxes
    if sys.platform.startswith('sunos'):
        EXTRA_COMPILE_ARGS = EXTRA_COMPILE_ARGS or ['-G']
        
        

if MATLAB_VERSION >= 7 and not WINDOWS:
    MATLAB_LIBRARY_DIRS = [MATLAB_DIR + "/bin/" + PLATFORM_DIR]
else:
    MATLAB_LIBRARY_DIRS = [MATLAB_DIR + "/extern/lib/" + PLATFORM_DIR]
print "MATLAB_VERSION, MATLAB_LIBRARY_DIRS:", MATLAB_VERSION, MATLAB_LIBRARY_DIRS
MATLAB_INCLUDE_DIRS = [MATLAB_DIR + "/extern/include"] #, "/usr/include"
if WINDOWS:
    if VC_DIR:
        MATLAB_LIBRARY_DIRS += [VC_DIR + "/lib"]
        MATLAB_INCLUDE_DIRS += [VC_DIR + "/include", VC_DIR + "/PlatformSDK/include"]
    else:
        print "Not using Visual C++; fiddling paths for Borland C++ compatibility"
        MATLAB_LIBRARY_DIRS = [mld.replace('/','\\') for mld in  MATLAB_LIBRARY_DIRS]
elif [mld for mld in MATLAB_LIBRARY_DIRS if os.getenv('LD_LIBRARY_PATH',"").find(mld) == -1]:
    print >> sys.stderr, """
    DON'T FORGET TO DO SOMETHING LIKE:
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:%s
    """ % (":".join(MATLAB_LIBRARY_DIRS))
DEFINE_MACROS=[]
if MATLAB_VERSION >= 6.5:
    DEFINE_MACROS.append(('_V6_5_OR_LATER',1))
if MATLAB_VERSION >= 7.3:
    DEFINE_MACROS.append(('_V7_3_OR_LATER',1))
setupArgs= dict( # Distribution meta-data
    name = "mlabwrap",
##     version = "1.1",
    description = "A high-level bridge to matlab",
    author = "Alexander Schmolck",
    author_email = "A.Schmolck@gmx.net",
##  licence="MIT"  #FIXME
    namespace_packages=['scikits'],
    packages=setuptools.find_packages(),
    zip_safe = False, #FIXME
    install_requires=['numpy'],
    test_suite="tests/test_mlabwrap",
##     py_modules = ["mlabwrap"] + SUPPORT_MODULES,
    url='http://mlabwrap.sourceforge.net',
    ext_modules = [
    Extension('scikits/mlabwrap/' + EXTENSION_NAME, ['scikits/mlabwrap/mlabraw.cpp'],
              define_macros=DEFINE_MACROS,
              library_dirs=MATLAB_LIBRARY_DIRS ,
              libraries=MATLAB_LIBRARIES + CPP_LIBRARIES,
                     include_dirs=MATLAB_INCLUDE_DIRS + (PYTHON_INCLUDE_DIR and [PYTHON_INCLUDE_DIR] or []),
                     extra_compile_args=EXTRA_COMPILE_ARGS,
                     ),
           ]
       )
setupArgs.update(configuration(top_path='').todict())
from version import version
setup(version=version,**setupArgs)

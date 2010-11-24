#! /usr/bin/env python
__revision__ = '$Id: setup.py 9706 2008-02-25 20:53:45Z matt $'

import os
import sys
import os.path
import unittest
from distutils.core import setup, Command

sys.path.insert(0, 'src')
import musicbrainz2

class TestCommand(Command):
	description = 'run all test cases'
	user_options = [ ]
	
	def initialize_options(self): pass

	def finalize_options(self): pass

	def run(self):
		files = [ ]
		for f in os.listdir('test'):
			elems = os.path.splitext(f)
			if f != '__init__.py' and elems[1] == '.py':
				files.append('test.' + elems[0])

		tests = unittest.defaultTestLoader.loadTestsFromNames(files)
		t = unittest.TextTestRunner()
		t.run(tests)


class GenerateDocsCommand(Command):
	description = 'generate the API documentation'
	user_options = [ ]

	def initialize_options(self): pass

	def finalize_options(self): pass

	def run(self):
		from distutils.spawn import find_executable, spawn
		bin = find_executable('epydoc')
		if not bin:
			print>>sys.stderr, 'error: epydoc not found'
			sys.exit(1)
		noPrivate = '--no-private'
		verbose = '-v'
		cmd = (bin, noPrivate, verbose,
			os.path.join('src', 'musicbrainz2'))

		spawn(cmd)


long_description = """\
An interface to the MusicBrainz XML web service
===============================================

python-musicbrainz2 provides simple, object oriented access to the
MusicBrainz web service. It is useful for applications like CD rippers,
taggers, media players, and other tools that need music metadata.

The MusicBrainz Project (see http://musicbrainz.org) collects music
metadata and is maintained by its large and constantly growing user
community.

Most of this package works on python-2.3 and later without further
dependencies. If you want to generate DiscIDs from an audio CD in the
drive, you need ctypes (already included in python-2.5) and libdiscid.
"""

trove_classifiers = [
	'Development Status :: 5 - Production/Stable',
	'Intended Audience :: Developers',
	'License :: OSI Approved :: BSD License',
	'Operating System :: OS Independent',
	'Programming Language :: Python',
	'Topic :: Database :: Front-Ends',
	'Topic :: Multimedia :: Sound/Audio :: CD Audio :: CD Ripping',
	'Topic :: Software Development :: Libraries :: Python Modules',
	'Topic :: Text Processing :: Markup :: XML',
]

setup_args = {
	'name':		'python-musicbrainz2',
	'version':	musicbrainz2.__version__,
	'description':	'An interface to the MusicBrainz XML web service',
	'long_description': long_description,
	'author':	'Matthias Friedrich',
	'author_email':	'matt@mafr.de',
	'url':		'http://musicbrainz.org/products/python-musicbrainz2/',
	'download_url':	'http://ftp.musicbrainz.org/pub/musicbrainz/python-musicbrainz2/',
	'classifiers':	trove_classifiers,
	'license':	'BSD',
	'packages':	[ 'musicbrainz2', 'musicbrainz2.data' ],
	'package_dir':	{ 'musicbrainz2': 'src/musicbrainz2' },
	'scripts':	[ 'bin/mb-submit-disc' ],
	'cmdclass':	{ 'test': TestCommand, 'docs': GenerateDocsCommand },
}

(ver_major, ver_minor) = sys.version_info[0:2]

setup(**setup_args)

# EOF

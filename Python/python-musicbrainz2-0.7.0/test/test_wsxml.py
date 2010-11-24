"""Tests for the MbXmlParser class."""
import unittest
from musicbrainz2.wsxml import MbXmlParser, ParseError, _makeAbsoluteUri
import StringIO
import os.path

VALID_DATA_DIR = os.path.join('test-data', 'valid')
INVALID_DATA_DIR = os.path.join('test-data', 'invalid')

VALID_ARTIST_DIR = os.path.join(VALID_DATA_DIR, 'artist')
INVALID_ARTIST_DIR = os.path.join(INVALID_DATA_DIR, 'artist')


class BaseParserTest(unittest.TestCase):
	"""Test the most basic cases: empty and invalid documents."""
	
	def __init__(self, name):
		unittest.TestCase.__init__(self, name)


	def testEmptyValid(self):
		tests = ('empty_1.xml', 'empty_2.xml')

		for f in self._makeFiles(VALID_ARTIST_DIR, tests):
			try:
				MbXmlParser().parse(f)
			except ParseError, e:
				self.fail(f.name + ' ' + e.msg)


	def testEmptyInvalid(self):
		tests = ('empty_1.xml', 'empty_2.xml', 'empty_3.xml')

		for f in self._makeFiles(INVALID_ARTIST_DIR, tests):
			p = MbXmlParser()
			try:
				MbXmlParser().parse(f)
			except ParseError:
				pass
			else:
				self.fail(f.name + ' ' + f.name)


	def testMakeAbsoluteUri(self):
		self.assert_(_makeAbsoluteUri('http://mb.org/artist/', None) is None)
		self.assertEquals('http://mb.org/artist/some_id',
			_makeAbsoluteUri('http://mb.org/artist/', 'some_id'))
		self.assertEquals('http://mb.org/artist/some_id',
			_makeAbsoluteUri('http://mb.org/artist/',
				'http://mb.org/artist/some_id'))
		self.assertEquals('http://mb.org/ns/mmd-1.0#name',
			_makeAbsoluteUri('http://mb.org/ns/mmd-1.0#', 'name'))
		self.assertEquals('http://mb.org/ns/mmd-1.0#name',
			_makeAbsoluteUri('http://mb.org/ns/mmd-1.0#',
				'http://mb.org/ns/mmd-1.0#name'))


	def _makeFiles(self, dir, basenames):
		files = [ ]
		for b in basenames:
			files.append( file(os.path.join(dir, b)) )

		return files


# EOF

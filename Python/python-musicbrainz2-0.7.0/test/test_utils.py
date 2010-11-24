"""Tests for the utils module."""
import unittest
import musicbrainz2.model as m
import musicbrainz2.utils as u

class UtilsTest(unittest.TestCase):
	
	def __init__(self, name):
		unittest.TestCase.__init__(self, name)


	def testExtractUuid(self):
		artistPrefix = 'http://musicbrainz.org/artist/'
		uuid = 'c0b2500e-0cef-4130-869d-732b23ed9df5'
		mbid = artistPrefix + uuid

		self.assertEquals(u.extractUuid(None), None)
		self.assertEquals(u.extractUuid(uuid), uuid)
		self.assertEquals(u.extractUuid(mbid), uuid)
		self.assertEquals(u.extractUuid(mbid, 'artist'), uuid)

		# not correct, but not enough data to catch this
		self.assertEquals(u.extractUuid(uuid, 'release'), uuid)

		self.assertRaises(ValueError, u.extractUuid, mbid, 'release')
		self.assertRaises(ValueError, u.extractUuid, mbid, 'track')
		self.assertRaises(ValueError, u.extractUuid, mbid+'/xy', 'artist')

		invalidId = 'http://example.invalid/' + uuid
		self.assertRaises(ValueError, u.extractUuid, invalidId)


	def testExtractFragment(self):
		fragment = 'Album'
		uri = m.NS_MMD_1 + fragment

		self.assertEquals(u.extractFragment(None), None)
		self.assertEquals(u.extractFragment(fragment), fragment)
		self.assertEquals(u.extractFragment(uri), fragment)
		self.assertEquals(u.extractFragment(uri, m.NS_MMD_1), fragment)

		prefix = 'http://example.invalid/'
		self.assertRaises(ValueError, u.extractFragment, uri, prefix)


	def testExtractEntityType(self):
		prefix = 'http://musicbrainz.org'
		uuid = 'c0b2500e-0cef-4130-869d-732b23ed9df5'

		mbid1 = prefix + '/artist/' + uuid
		self.assertEquals(u.extractEntityType(mbid1), 'artist')

		mbid2 = prefix + '/release/' + uuid
		self.assertEquals(u.extractEntityType(mbid2), 'release')

		mbid3 = prefix + '/track/' + uuid
		self.assertEquals(u.extractEntityType(mbid3), 'track')

		mbid4 = prefix + '/label/' + uuid
		self.assertEquals(u.extractEntityType(mbid4), 'label')

		mbid5 = prefix + '/invalid/' + uuid
		self.assertRaises(ValueError, u.extractEntityType, mbid5)

		self.assertRaises(ValueError, u.extractEntityType, None)
		self.assertRaises(ValueError, u.extractEntityType, uuid)

		invalidUri = 'http://example.invalid/foo'
		self.assertRaises(ValueError, u.extractEntityType, invalidUri)
		

	def testGetCountryName(self):
		self.assertEquals(u.getCountryName('DE'), 'Germany')
		self.assertEquals(u.getCountryName('FR'), 'France')

	def testGetLanguageName(self):
		self.assertEquals(u.getLanguageName('DEU'), 'German')
		self.assertEquals(u.getLanguageName('ENG'), 'English')

	def testGetScriptName(self):
		self.assertEquals(u.getScriptName('Latn'), 'Latin')
		self.assertEquals(u.getScriptName('Cyrl'), 'Cyrillic')

	def testGetReleaseTypeName(self):
		self.assertEquals(u.getReleaseTypeName(m.Release.TYPE_ALBUM),
			'Album')
		self.assertEquals(u.getReleaseTypeName(m.Release.TYPE_COMPILATION), 'Compilation')

# EOF

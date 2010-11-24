"""Tests for subclasses of IFilter."""
import unittest
from musicbrainz2.model import Release
from musicbrainz2.webservice import ReleaseFilter


class ReleaseFilterTest(unittest.TestCase):
	def testBasic(self):
		f = ReleaseFilter(title='Under the Pink')
		params = f.createParameters()
		self.assert_( ('title', 'Under the Pink') in params )

	def testReleaseTypes(self):
		f = ReleaseFilter(artistName='Tori Amos', releaseTypes=(
			Release.TYPE_ALBUM, Release.TYPE_OFFICIAL))
		params = f.createParameters()

		self.assertEquals(len(params), 2)
		self.assert_( ('artist', 'Tori Amos') )
		self.assert_( ('releasetypes', 'Album Official') )

	def testQuery(self):
		try:
			f1 = ReleaseFilter(title='Pink', query='xyz')
			self.fail('title and query are mutually exclusive')
		except ValueError:
			pass
		except:
			self.fail('invalid exception')

		# the following shouldn't throw exceptions:
		f2 = ReleaseFilter(title='Pink', limit=10, offset=20)
		f3 = ReleaseFilter(query='Pink', limit=10, offset=20)


# EOF

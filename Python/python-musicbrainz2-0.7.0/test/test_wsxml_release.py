"""Tests for parsing releases using MbXmlParser."""
import unittest
from musicbrainz2.wsxml import MbXmlParser, ParseError
from musicbrainz2.model import VARIOUS_ARTISTS_ID, NS_MMD_1, \
	Relation, ReleaseEvent
import StringIO
import os.path

VALID_DATA_DIR = os.path.join('test-data', 'valid')
INVALID_DATA_DIR = os.path.join('test-data', 'invalid')

VALID_RELEASE_DIR = os.path.join(VALID_DATA_DIR, 'release')

def makeId(relativeUri):
	return 'http://musicbrainz.org/release/' + relativeUri

class ParseReleaseTest(unittest.TestCase):

	def __init__(self, name):
		unittest.TestCase.__init__(self, name)


	def testReleaseBasic(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Little_Earthquakes_1.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )
		self.assertEquals(release.getId(),
			makeId('02232360-337e-4a3f-ad20-6cdd4c34288c'))
		self.assertEquals(release.getTitle(), 'Little Earthquakes')
		self.assertEquals(release.getTextLanguage(), 'ENG')
		self.assertEquals(release.getTextScript(), 'Latn')

		self.assertEquals(len(release.getTypes()), 2)
		self.assert_(NS_MMD_1 + 'Album' in release.getTypes())
		self.assert_(NS_MMD_1 + 'Official' in release.getTypes())


	def testReleaseFull(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Little_Earthquakes_2.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )
		self.assertEquals(release.getId(),
			makeId('02232360-337e-4a3f-ad20-6cdd4c34288c'))

		self.assertEquals(release.getArtist().getName(), 'Tori Amos')

		events = release.getReleaseEventsAsDict()
		self.assertEquals(len(events), 3)
		self.assertEquals(events['GB'], '1992-01-13')
		self.assertEquals(events['DE'], '1992-01-17')
		self.assertEquals(events['US'], '1992-02-25')

		date = release.getEarliestReleaseDate()
		self.assertEquals(date, '1992-01-13')
		event = release.getEarliestReleaseEvent()
		self.assertEquals(event.date, date)
		self.assertEquals(event.country, 'GB')

		discs = release.getDiscs()
		self.assertEquals(len(discs), 3)
		self.assertEquals(discs[0].getId(), 'ILKp3.bZmvoMO7wSrq1cw7WatfA-')
		self.assertEquals(discs[1].getId(), 'ejdrdtX1ZyvCb0g6vfJejVaLIK8-')
		self.assertEquals(discs[2].getId(), 'Y96eDQZbF4Z26Y5.Sxdbh3wGypo-')

		tracks = release.getTracks()
		self.assertEquals(len(tracks), 12)
		self.assertEquals(tracks[0].getTitle(), 'Crucify')
		self.assertEquals(tracks[4].getTitle(), 'Winter')


	def testReleaseRelations(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Highway_61_Revisited_1.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )
		self.assertEquals(release.getId(),
			makeId('d61a2bd9-81ac-4023-bd22-1c884d4a176c'))

		(rel1, rel2) = release.getRelations(Relation.TO_URL)

		self.assertEquals(rel1.getTargetId(),
			'http://en.wikipedia.org/wiki/Highway_61_Revisited')
		self.assertEquals(rel1.getDirection(), Relation.DIR_NONE)
		self.assertEquals(rel2.getTargetId(),
			'http://www.amazon.com/gp/product/B0000024SI')


	def testVariousArtistsRelease(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Mission_Impossible_2.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )

		artistId = release.getArtist().getId()
		self.assertEquals(artistId, VARIOUS_ARTISTS_ID)

		events = release.getReleaseEventsAsDict()
		self.assertEquals(len(events), 1)
		self.assertEquals(events['EU'], '2000')

		track14 = release.getTracks()[14]
		self.assertEquals(track14.getTitle(), 'Carnival')
		self.assertEquals(track14.getArtist().getName(), 'Tori Amos')


	def testIncompleteReleaseEvent(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Under_the_Pink_1.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )
		self.assertEquals(release.getTitle(), 'Under the Pink')

		events = release.getReleaseEvents()
		self.assertEquals(len(events), 1)
		self.assertEquals(events[0].getDate(), '1994-01-28')


	def testReleaseEvents(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Under_the_Pink_3.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()

		self.failIf( release is None )
		self.assertEquals(release.getTitle(), 'Under the Pink')

		events = release.getReleaseEvents()
		self.assertEquals(len(events), 1)
		e1 = events[0]
		self.assertEquals(e1.date, '1994-01-31')
		self.assertEquals(e1.catalogNumber, '82567-2')
		self.assertEquals(e1.barcode, '07567825672')
		self.assertEquals(e1.format, ReleaseEvent.FORMAT_CD)

		self.failIf( e1.label is None )
		self.assertEquals(e1.label.name, 'Atlantic Records')


	def testTags(self):
		f = os.path.join(VALID_RELEASE_DIR, 'Highway_61_Revisited_2.xml')
		md = MbXmlParser().parse(f)
		release = md.getRelease()
		
		self.failIf( release is None )
		self.assertEquals(release.getTag('rock').count, 100)
		self.assertEquals(release.getTag('blues rock').count, 40)
		self.assertEquals(release.getTag('folk rock').count, 40)
		self.assertEquals(release.getTag('dylan').count, 4)
		

	def testResultAttributes(self):
		f = os.path.join(VALID_RELEASE_DIR, 'search_result_1.xml')
		md = MbXmlParser().parse(f)

		self.assertEquals(md.releaseResultsOffset, 0)
		self.assertEquals(md.releaseResultsCount, 234)


# EOF

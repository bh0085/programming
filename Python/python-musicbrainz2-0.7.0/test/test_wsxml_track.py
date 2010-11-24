"""Tests for parsing tracks using MbXmlParser."""
import unittest
from musicbrainz2.wsxml import MbXmlParser, ParseError
from musicbrainz2.model import NS_MMD_1, NS_REL_1, Relation
import StringIO
import os.path

VALID_DATA_DIR = os.path.join('test-data', 'valid')
INVALID_DATA_DIR = os.path.join('test-data', 'invalid')

VALID_TRACK_DIR = os.path.join(VALID_DATA_DIR, 'track')

def makeId(relativeUri, resType='track'):
	return 'http://musicbrainz.org/%s/%s' % (resType, relativeUri)


class ParseTrackTest(unittest.TestCase):

	def __init__(self, name):
		unittest.TestCase.__init__(self, name)


	def testTrackBasic(self):
		f = os.path.join(VALID_TRACK_DIR, 'Silent_All_These_Years_1.xml')
		md = MbXmlParser().parse(f)
		track = md.getTrack()

		self.failIf( track is None )
		self.assertEquals(track.getTitle(), 'Silent All These Years')
		self.assertEquals(track.getDuration(), 253466)


	def testTrackRelations(self):
		f = os.path.join(VALID_TRACK_DIR, 'Silent_All_These_Years_2.xml')
		md = MbXmlParser().parse(f)
		track = md.getTrack()

		self.failIf( track is None )
		self.assertEquals(track.getTitle(), 'Silent All These Years')
		self.assertEquals(track.getDuration(), 253466)

		trackRels = track.getRelations(Relation.TO_TRACK)
		self.assertEquals(len(trackRels), 1)
		rel1 = trackRels[0]
		self.assertEquals(rel1.getType(), NS_REL_1 + 'Cover')
		self.assertEquals(rel1.getDirection(), Relation.DIR_BACKWARD)
		self.assertEquals(rel1.getTargetId(),
			makeId('31e1c0c4-967f-435e-b09a-35ee079ee234', 'track'))
		self.assert_( rel1.getBeginDate() is None )
		self.assert_( rel1.getEndDate() is None )

		self.failIf( rel1.getTarget() is None )
		self.assertEquals(rel1.getTarget().getId(),
			makeId('31e1c0c4-967f-435e-b09a-35ee079ee234'))
		self.assertEquals(rel1.getTarget().getArtist().getId(),
			makeId('5bcd4eaa-fae7-465f-9f03-d005b959ed02', 'artist'))


	def testTrackFull(self):
		f = os.path.join(VALID_TRACK_DIR, 'Silent_All_These_Years_4.xml')
		md = MbXmlParser().parse(f)
		track = md.getTrack()

		self.failIf( track is None )
		self.assertEquals(track.getTitle(), 'Silent All These Years')
		self.assertEquals(track.getDuration(), 253466)

		artist = track.getArtist()
		self.failIf( artist is None )
		self.assertEquals(artist.getId(),
			makeId('c0b2500e-0cef-4130-869d-732b23ed9df5', 'artist'))
		self.assertEquals(artist.getType(), NS_MMD_1 + 'Person')
		self.assertEquals(artist.getName(), 'Tori Amos')
		self.assertEquals(artist.getSortName(), 'Amos, Tori')

		puids = track.getPuids()
		self.assertEquals(len(puids), 7)
		self.assertEquals(puids[0], 'c2a2cee5-a8ca-4f89-a092-c3e1e65ab7e6')
		self.assertEquals(puids[6], '42ab76ea-5d42-4259-85d7-e7f2c69e4485')
		
		isrcs = track.isrcs
		self.assertEquals(len(isrcs), 1)
		self.assertEquals(isrcs[0], 'USPR37300012')

		releases = track.getReleases()
		self.assertEquals(len(releases), 1)
		self.assertEquals(releases[0].getTitle(), 'Little Earthquakes')
		self.assertEquals(releases[0].getTracksOffset(), 2)

	def testSearchResults(self):
		f = os.path.join(VALID_TRACK_DIR, 'search_result_1.xml')
		md = MbXmlParser().parse(f)

		self.assertEquals(md.trackResultsOffset, 7)
		self.assertEquals(md.trackResultsCount, 100)

		results = md.getTrackResults()
		self.assertEquals(len(results), 3)

		self.assertEquals(results[0].getScore(), 100)
		track1 = results[0].getTrack()
		self.assertEquals(track1.getTitle(), 'Little Earthquakes')

# EOF

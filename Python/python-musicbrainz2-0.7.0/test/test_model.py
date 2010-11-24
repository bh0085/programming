"""Tests for various model classes."""
import unittest
from musicbrainz2.model import Artist, Release, Track, Relation, Tag, NS_REL_1

class MiscModelTest(unittest.TestCase):
	
	def __init__(self, name):
		unittest.TestCase.__init__(self, name)

	def testAddRelation(self):
		rel = Relation(NS_REL_1+'Producer', Relation.TO_RELEASE, 'a_id',			attributes=[NS_REL_1+'Co'])
		artist = Artist('ar_id', 'Tori Amos', 'Person')
		artist.addRelation(rel)

		rel2 = artist.getRelations(Relation.TO_RELEASE)[0]
		self.assertEquals(rel.getType(), rel2.getType())
		self.assertEquals(rel.getTargetType(), rel2.getTargetType())
		self.assertEquals(rel.getTargetId(), rel2.getTargetId())
		self.assertEquals(rel.getAttributes(), rel2.getAttributes())
		self.assertEquals(rel.getBeginDate(), rel2.getBeginDate())
		self.assertEquals(rel.getEndDate(), rel2.getEndDate())

		self.assertEquals(artist.getRelationTargetTypes(),
			[ Relation.TO_RELEASE ])

		# works because we only have one relation
		self.assertEquals(artist.getRelations(),
			artist.getRelations(Relation.TO_RELEASE))

		rel3 = artist.getRelations(Relation.TO_RELEASE,
			NS_REL_1 + 'Producer')
		self.assertEquals(len(rel3), 1)

		rel4 = artist.getRelations(Relation.TO_RELEASE,
			NS_REL_1 + 'Producer', [NS_REL_1 + 'Co'])
		self.assertEquals(len(rel4), 1)

		rel5 = artist.getRelations(Relation.TO_RELEASE,
			NS_REL_1 + 'Producer', [NS_REL_1 + 'NotThere'])
		self.assertEquals(len(rel5), 0)

		rel6 = artist.getRelations(Relation.TO_RELEASE,
			NS_REL_1 + 'Producer', [NS_REL_1 + 'Co'], 'none')
		self.assertEquals(len(rel6), 1)

		rel6 = artist.getRelations(Relation.TO_RELEASE,
			NS_REL_1 + 'Producer', [NS_REL_1 + 'Co'], 'forward')
		self.assertEquals(len(rel6), 0)


	def testTrackDuration(self):
		t = Track()
		self.assert_( t.getDuration() is None )
		self.assert_( t.getDurationSplit() == (0, 0) )
		t.setDuration(0)
		self.assert_( t.getDurationSplit() == (0, 0) )
		t.setDuration(218666)
		self.assert_( t.getDurationSplit() == (3, 39) )

	def testReleaseIsSingleArtist(self):
		r = Release()
		r.setArtist(Artist(id_=1))
		r.addTrack(Track())
		r.addTrack(Track())
		self.assert_( r.isSingleArtistRelease() )

		r.getTracks()[0].setArtist(Artist(id_=7))
		r.getTracks()[1].setArtist(Artist(id_=8))
		self.assert_( r.isSingleArtistRelease() == False )

		r.getTracks()[0].setArtist(Artist(id_=1))
		r.getTracks()[1].setArtist(Artist(id_=1))
		self.assert_( r.isSingleArtistRelease() )

	def testTags(self):
		a = Artist()
		a.addTag(Tag('foo', 1))
		a.addTag(Tag('bar', 2))
		a.addTag(Tag('bar', 5))

		self.assertEquals(len(a.tags), 2)
		self.assertEquals(a.getTag('foo').count, 1)
		self.assertEquals(a.getTag('bar').count, 7)


class TagTest(unittest.TestCase):
	
	def test__str__(self):
		self.assertEquals("foo", str(Tag(u"foo")))
		self.assertRaises(UnicodeEncodeError, str, Tag(u"f\u014do"))
	
	def test__unicode__(self):
		self.assertEquals(u"foo", unicode(Tag(u"foo")))
		self.assertEquals(u"f\u014do", unicode(Tag(u"f\u014do")))

# EOF

#! /usr/bin/env python
#
# Retrieving an artist's relations to other artists and URLs.
#
# Usage:
#	python getrelations.py artist-id
#
# Interesting Artist IDs for testing:
#	http://musicbrainz.org/artist/ea4dfa26-f633-4da6-a52a-f49ea4897b58
#	http://musicbrainz.org/artist/172e1f1a-504d-4488-b053-6344ba63e6d0
#	http://musicbrainz.org/artist/c0b2500e-0cef-4130-869d-732b23ed9df5
#
# $Id: getrelations.py 7496 2006-05-09 16:52:40Z matt $
#
import sys
import logging
import musicbrainz2.webservice as ws
import musicbrainz2.model as m

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


if len(sys.argv) < 2:
	print "Usage: getrelations.py artist-id"
	sys.exit(1)

q = ws.Query()

try:
	# The result should include all relations to other artists and also
	# relations to URLs.
	#
	inc = ws.ArtistIncludes(artistRelations=True, releaseRelations=True,
		urlRelations=True)
	artist = q.getArtistById(sys.argv[1], inc)
except ws.WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


print "Id         :", artist.id
print "Name       :", artist.name
print


#
# Get the artist's relations to URLs (m.Relation.TO_URL) having the relation
# type 'http://musicbrainz.org/ns/rel-1.0#Wikipedia'. Note that there could
# be more than one relation per type. We just print the first one.
#
urls = artist.getRelationTargets(m.Relation.TO_URL, m.NS_REL_1+'Wikipedia')
if len(urls) > 0:
	print 'Wikipedia:', urls[0]
	print


#
# List discography pages for an artist.
#
for rel in artist.getRelations(m.Relation.TO_URL, m.NS_REL_1+'Discography'):
	print 'Discography:', rel.targetId
	print

#
# If the artist is a group, list all members.
#
if artist.type == m.Artist.TYPE_GROUP:
	allMembers = artist.getRelations(m.Relation.TO_ARTIST,
			m.NS_REL_1+'MemberOfBand')

	uri = m.NS_REL_1+'Additional' 
	coreMembers = [r for r in allMembers if uri not in r.attributes]
	additionalMembers = [r for r in allMembers if uri in r.attributes]

	print 'Group members:'
	for rel in coreMembers:
		start = rel.beginDate or 'foundation'
		end = rel.endDate or 'end'
		print '\t%s (%s to %s)' % (rel.target.name, start, end)

	print
	print 'Additional members:'
	for rel in additionalMembers:
		print '\t', rel.target.name


#
# List all releases for which this artist has acted as the producer.
#
releases = artist.getRelationTargets(m.Relation.TO_RELEASE,
		m.NS_REL_1+'Producer')
print
print 'Credited as producer for:'
for r in releases:
	print '\t', r.title

# EOF

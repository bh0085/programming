#! /usr/bin/env python
#
# This shows the web service interaction needed for a typical CD ripper.
#
# Usage:
#	python ripper.py
#
# $Id: ripper.py 201 2006-03-27 14:43:13Z matt $
#
import sys
import logging
import musicbrainz2.disc as mbdisc
import musicbrainz2.webservice as mbws


# Activate logging.
#
logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


# Setup a Query object.
#
service = mbws.WebService()
query = mbws.Query(service)

# Read the disc in the drive
#
try:
	disc = mbdisc.readDisc()
except mbdisc.DiscError, e:
	print "Error:", e
	sys.exit(1)


# Query for all discs matching the given DiscID.
#
try:
	filter = mbws.ReleaseFilter(discId=disc.getId())
	results = query.getReleases(filter)
except mbws.WebServiceError, e:
	print "Error:", e
	sys.exit(2)


# No disc matching this DiscID has been found.
#
if len(results) == 0:
	print "Disc is not yet in the MusicBrainz database."
	print "Consider adding it via", mbdisc.getSubmissionUrl(disc)
	sys.exit(0)


# Display the returned results to the user.
#
print 'Matching releases:'

for result in results:
	release = result.release
	print 'Artist  :', release.artist.name
	print 'Title   :', release.title
	print


# Select one of the returned releases. We just pick the first one.
#
selectedRelease = results[0].release


# The returned release object only contains title and artist, but no tracks.
# Query the web service once again to get all data we need.
#
try:
	inc = mbws.ReleaseIncludes(artist=True, tracks=True, releaseEvents=True)
	release = query.getReleaseById(selectedRelease.getId(), inc)
except mbws.WebServiceError, e:
	print "Error:", e
	sys.exit(2)


# Now display the returned data.
#
isSingleArtist = release.isSingleArtistRelease()

print "%s - %s" % (release.artist.getUniqueName(), release.title)

i = 1
for t in release.tracks:
	if isSingleArtist:
		title = t.title
	else:
		title = t.artist.name + ' - ' +  t.title

	(minutes, seconds) = t.getDurationSplit()
	print " %2d. %s (%d:%02d)" % (i, title, minutes, seconds)
	i+=1


# All data has been retrieved, now actually rip the CD :-)
#

# EOF

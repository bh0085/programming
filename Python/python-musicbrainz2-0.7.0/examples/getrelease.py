#! /usr/bin/env python
#
# Retrieve a release by ID and display it.
#
# Usage:
#	python getrelease.py release-id
#
# Interesting releases IDs for testing:
#	http://musicbrainz.org/release/290e10c5-7efc-4f60-ba2c-0dfc0208fbf5
#	http://musicbrainz.org/release/fa9f1bdd-495f-41b9-8944-1a766da29120
#
# $Id: getrelease.py 9320 2007-08-11 08:47:35Z matt $
#
import sys
import logging
import musicbrainz2.webservice as ws
import musicbrainz2.utils as u

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


if len(sys.argv) < 2:
	print "Usage: getrelease.py release-id"
	sys.exit(1)

q = ws.Query()

try:
	# Additionally to the release itself, we want the server to include
	# the release's artist, all release events, associated discs and
	# the track list.
	#
	inc = ws.ReleaseIncludes(artist=True, releaseEvents=True, labels=True,
			discs=True, tracks=True)
	release = q.getReleaseById(sys.argv[1], inc)
except ws.WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


print "Id          :", release.id
print "Title       :", release.title
print "ASIN        :", release.asin
print "Lang/Script :", release.textLanguage, '/', release.textScript


# Print the main artist of this release.
#
if release.artist:
	print
	print "Artist:"
	print "  Id        :", release.artist.id
	print "  Name      :", release.artist.name
	print "  SortName  :", release.artist.sortName


# Release events are the dates and times when a release took place.
# We also have the catalog numbers and barcodes for some releases.
#
if len(release.releaseEvents) > 0:
	print
	print "Released (earliest: %s):" % release.getEarliestReleaseDate()

for event in release.releaseEvents:
	print "  %s %s" % (u.getCountryName(event.country), event.date),

	if event.catalogNumber:
		print '#' + event.catalogNumber,

	if event.barcode:
		print 'EAN=' + event.barcode,

	if event.label:
		print '(' + event.label.name + ')',

	print


if len(release.discs) > 0:
	print
	print "Discs:"

for disc in release.discs:
	print "  DiscId: %s (%d sectors)" % (disc.id, disc.sectors)


if len(release.tracks) > 0:
	print
	print "Tracks:"

for track in release.tracks:
	print "  Id        :", track.id
	print "  Title     :", track.title
	print "  Duration  :", track.duration
	print

# EOF

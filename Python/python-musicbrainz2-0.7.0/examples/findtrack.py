#! /usr/bin/env python
# 
# Search for a track by title (and optionally by artist name).
#
# Usage:
#	python findtrack.py 'track name' ['artist name']
#
# $Id: findtrack.py 201 2006-03-27 14:43:13Z matt $
#
import sys
import logging
from musicbrainz2.webservice import Query, TrackFilter, WebServiceError

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
	

if len(sys.argv) < 2:
	print "Usage: findtrack.py 'track name' ['artist name']"
	sys.exit(1)

if len(sys.argv) > 2:
	artistName = sys.argv[2]
else:
	artistName = None

q = Query()

try:
	f = TrackFilter(title=sys.argv[1], artistName=artistName)
	results = q.getTracks(f)
except WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


for result in results:
	track = result.track
	print "Score     :", result.score
	print "Id        :", track.id
	print "Title     :", track.title
	print "Artist    :", track.artist.name
	print

# EOF

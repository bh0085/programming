#! /usr/bin/env python
#
# Search for an artist by name.
#
# Usage:
#	python findartist.py 'artist-name'
#
# $Id: findartist.py 8779 2007-01-07 10:01:52Z matt $
#
import sys
import logging
from musicbrainz2.webservice import Query, ArtistFilter, WebServiceError

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
	

if len(sys.argv) < 2:
	print "Usage: findartist.py 'artist name'"
	sys.exit(1)

q = Query()

try:
	# Search for all artists matching the given name. Limit the results
	# to the 5 best matches. The offset parameter could be used to page
	# through the results.
	#
	f = ArtistFilter(name=sys.argv[1], limit=5)
	artistResults = q.getArtists(f)
except WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


# No error occurred, so display the results of the search. It consists of
# ArtistResult objects, where each contains an artist.
#
for result in artistResults:
	artist = result.artist
	print "Score     :", result.score
	print "Id        :", artist.id
	print "Name      :", artist.name
	print "Sort Name :", artist.sortName
	print

#
# Now that you have artist IDs, you can request an artist in more detail, for
# example to display all official albums by that artist. See the 'getartist.py'
# example on how achieve that.
#

# EOF

#! /usr/bin/env python
# 
# Read a CD in the disc drive and calculate a MusicBrainz DiscID.
#
# Usage:
#	python discid.py
#
# $Id: discid.py 201 2006-03-27 14:43:13Z matt $
#
import sys
from musicbrainz2.disc import readDisc, getSubmissionUrl, DiscError

try:
	# Read the disc in the default disc drive. If necessary, you can pass
	# the 'deviceName' parameter to select a different drive.
	#
	disc = readDisc()
except DiscError, e:
	print "DiscID calculation failed:", str(e)
	sys.exit(1)

print 'DiscID      :', disc.id
print 'First Track :', disc.firstTrackNum
print 'Last Track  :', disc.lastTrackNum
print 'Length      :', disc.sectors, 'sectors'

i = disc.firstTrackNum
for (offset, length) in disc.tracks:
	print "Track %-2d    : %8d %8d" % (i, offset, length)
	i += 1

print 'Submit via  :', getSubmissionUrl(disc)

# EOF

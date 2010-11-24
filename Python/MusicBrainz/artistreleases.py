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

import musicbrainz2.webservice as ws
import musicbrainz2.model as m
import musicbrainz2.utils as u
	

if len(sys.argv) < 2:
	print "Usage: artistreleases.py 'artist name' ['album name']"
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

result = artistResults[0]
print "Artist Name: ", result.artist.name

#for result in artistResults:
#	artist = result.artist
#	print "Score     :", result.score
#	print "Id        :", artist.id
#	print "Name      :", artist.name
#	print "Sort Name :", artist.sortName
#	print
#
#
# Now that you have artist IDs, you can request an artist in more detail, for
# example to display all official albums by that artist. See the 'getartist.py'
# example on how achieve that.
#

q = ws.Query()

try:
	# The result should include all official albums.
	#
	inc = ws.ArtistIncludes(
		releases=(m.Release.TYPE_OFFICIAL, m.Release.TYPE_ALBUM),
		tags=True)
	artist = q.getArtistById(result.artist.id, inc)
except ws.WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


print


if len(artist.getReleases()) == 0:
	print "No releases found."

i = 0
releasearr = artist.getReleases()

import re

if len(sys.argv) < 3:
    for release in releasearr:
        print i, ": ", release.title
        i=i+1
    var = raw_input("Enter a selection: ")
    releasesfound=[releasearr[int(var)]]
else:
    searchstr = sys.argv[2]
    targets = '[^a-zA-Z0-9]'
    searchstr = re.sub(targets,'.*',searchstr)
    searchgeneral= re.compile(searchstr,re.I | re.M)
    count = 0
    idxfound = -1
    releasesfound = []
    for i in releasearr:
        if len(re.findall(searchgeneral,i.title)) != 0:
            releasesfound.append(i)
    if len(releasesfound) == 0 :
        print "No matching releases were found..."
        sys.exit(1)

for release in releasesfound:
    rid = release.id
    try:
	inc = ws.ReleaseIncludes(artist=True, releaseEvents=True, labels=True,
                                 discs=True, tracks=True)
	release = q.getReleaseById(rid, inc)
    except ws.WebServiceError, e:
	print 'Error:', e
	sys.exit(1)
    import subprocess
    proc =subprocess.Popen('cat ufb_index.csv', shell = True, stdout=subprocess.PIPE)
    out = proc.communicate()[0]
    print "Tracks found on ", release.title, ":"
    print
    for track in release.tracks:
        searchstr = track.title
        targets = '[^a-zA-Z0-9]'
        searchstr = re.sub(targets,'.*',searchstr)
        searchstr = "^[^a-zA-Z0-9]" + searchstr + ".*"
        searchgeneral= re.compile(searchstr,re.I | re.M)
        searchresults= re.findall(searchgeneral, out)
        if len(searchresults) != 0:
            strfound = searchresults[0]
            strfound = re.sub(re.compile('^"'),'',strfound)
            strfound = re.sub(re.compile('".*$'),'',strfound)
            print strfound
    print
    print
print "Shall I open a song file?"
print
fbdir = '/Volumes/Media/Music/Misc/ultimate_fake_book'
import os
os.chdir(fbdir)
searchstr = raw_input("Song Name (blank to exit): ")
if len(searchstr) == 0:
    sys.exit(1)

targets = '[^a-zA-Z0-9]'
searchstr = re.sub(targets,'.*',searchstr)
searchstr = "^[^a-zA-Z0-9]*" + searchstr + ".*"
searchgeneral= re.compile(searchstr,re.I | re.M)

proc = subprocess.Popen("ls",shell = True, stdout=subprocess.PIPE)
out = proc.communicate()[0]

searchresults= re.findall(searchgeneral, out)
if len(searchresults) != 0:
    if len(searchresults) > 1:
        count = 0
        for result in searchresults:
            print result
        print
        mustFindExtension = True
        while mustFindExtension:
            ext = raw_input("Choose an extension or substring (e.g. .rb2):")
            targets = '[^a-zA-Z0-9]'
            ext = re.sub(targets,'.*',ext)
            for result in searchresults:
                regext = re.compile(ext)
                found = re.findall(regext,result)
                if len(found) !=0:
                    mustFindExtension = False
                    break
            print "Sorry, I couldn't find that extension"
    else:
       result = searchresults[0]
    execstring = "open " + "'"+result +"'"
    print "..."
    print
    print execstring
    print
    subprocess.Popen(execstring, shell = True)
    print "Success, Opening song!"
else:
    print
    print "Sorry... do to some error I couldn't load that song. Weird."

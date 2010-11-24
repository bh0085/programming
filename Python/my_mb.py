from mutagen.flac import FLAC
import os
import re

def dir_flac_mbid(dir):
    if not os.path.isdir(dir):
        print "Directory does not exist"
        return -1
    for root, dirs, files in os.walk(dir):
        for f in files:
            ext_re = re.compile(".*\.flac")
            if re.search(ext_re,f):
                path = os.path.join(root,f)
                flac = FLAC(path)
                if flac.has_key('musicbrainz_albumid'):
                    return flac['musicbrainz_albumid'][0]
    return -1

def dir_flac_year(dir):
    if not os.path.isdir(dir):
        print "Directory does not exist"
        return -1
    for f in os.listdir(dir):
        ext_re = re.compile(".*\.flac")
        if re.search(ext_re,f):
            path = os.path.join(dir,f)
            flac = FLAC(path)
            if flac.has_key('date'):
                year_re = re.compile('[0-9]{4}')
                date = flac['date'][0]
                year =  (re.search(year_re,date)).group()
                return year
    return -1


from musicbrainz2.webservice import Query, ArtistFilter, WebServiceError
import musicbrainz2.webservice as ws

def mb_release_dictionary(release_id):
    q = ws.Query()
    try:
        inc = ws.ReleaseIncludes(artist=True, releaseEvents=True, labels=True,
                                 discs=True, tracks=True)
        release = q.getReleaseById(release_id, inc)
    except ws.WebServiceError, e:
        print 'Error:', e
        return(-1)
    d = {}
    early_event = release.getEarliestReleaseEvent()
    early_date = early_event.date
    year_re = re.compile('[0-9]{4}')
    early_year = (re.search(year_re,early_date)).group()
    

    #"We are assuming... that this is a CD and the original release"
    d['artist'] = release.artist.name
    d['album'] = release.getTitle()
    d['country']=country = early_event.getCountry()
    d['orig_year'] = early_year
    d['type'] = u'CD'
    return d

   

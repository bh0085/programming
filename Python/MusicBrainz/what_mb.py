import MultipartPostHandler, urllib2, cookielib
import sys, os
from musicbrainz2.webservice import Query, ArtistFilter, WebServiceError
import musicbrainz2.webservice as ws

from metatorrent import decode
import pdb
import re
from mutagen.flac import FLAC


def submitlog(logfile):

    cookies = cookielib.CookieJar()
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies),
                                  MultipartPostHandler.MultipartPostHandler)
    p0 = { "username" : "bh0085", "password" : "dinobot1w"}
    p1 = { "action" : 'takeupload', 'log':logfile }

    f0 = opener.open("http://what.cd/login.php",p0)
    f1 = opener.open("http://what.cd/logchecker.php", p1)
    d0 = f0.read()
    d1 = f1.read()
    return d1

def submitupload(sub):
    cookies = cookielib.CookieJar()
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies),
                                  MultipartPostHandler.MultipartPostHandler)
    p0 = { "username" : "bh0085", "password" : "dinobot1w"}

    f0 = opener.open("http://what.cd/login.php",p0)
    f1 = opener.open("http://what.cd/upload.php", sub)
    d0 = f0.read()
    d1 = f1.read()
    f1 = open("upload.html",'w')
    f1.writelines(d1)
    f1.close()

def getsubmission(tfile):
    data = open(tfile).read()
    torrent = decode(data)
    tname = torrent['info']['name']

    for file in torrent["info"]["files"]:
        name = "/".join(file["path"])
        flac_re = re.compile(".flac")
        if flac_re.search(name) != None:
            flacname=name
            log_re = re.compile(".log")
        if log_re.search(name) !=None:
            logname=name
    
    fpath = os.path.join(tname,flacname)
    lpath = os.path.join(tname,logname)

    audio = FLAC(fpath)
    print audio.keys()
    if not audio.has_key('musicbrainz_albumid'):
        print "ReleaseID tag is not set. Has this flac been tagged by picard?"
        return(-1)

    albumid = audio['musicbrainz_albumid'][0]
    print albumid

    q = ws.Query()
    try:
        inc = ws.ReleaseIncludes(artist=True, releaseEvents=True, labels=True,
                                 discs=True, tracks=True)
        release = q.getReleaseById(albumid, inc)
    except ws.WebServiceError, e:
        print 'Error:', e
        return(-1)

    this_date = audio['date']
    early_event = release.getEarliestReleaseEvent()
    early_date = early_event.date
    year_re = re.compile('[0-9]{4}')
    early_year = (re.search(year_re,early_date)).group()
    

    print "We are assuming... that this is a CD and the original release"
    release_artist = release.artist.name
    release_album = release.getTitle()
    release_country = early_event.getCountry()
    release_year = early_year
    release_type = u'CD'
    release_label=unicode(early_event._label.name)
    release_log = open(lpath,'rb')
    release_torrent=open(fpath,'rb')


    track_infos = []
    track_infos.append(u'[b][size=4]'+release_artist+u' - '+release_album+u'[/size][/b]')
    track_infos.append(u'[b]Release:[/b]	'+unicode(release_year))
    track_infos.append(u'[b]Country:[/b]	'+unicode(release_country))
    track_infos.append(u'[b]Type:[/b]	'+unicode(release_type))
    track_infos.append(u'[b][size=3]Tracklist:[/size][/b]')
    tcount = 1
    for t in release.getTracks():
        minutes,seconds = divmod(t.getDuration()/1000,60)
        istr = u'[b]'+unicode(tcount)+u'[/b]'+ "  "+ t.getTitle() +"  ("+ unicode(minutes)+":"+unicode(seconds)+")"
    
        track_infos.append(istr)
        tcount = tcount +1

    nl="""
"""
    release_album_description = unicode(nl).join(track_infos)
    
#Fill in submission with gathered data.
    sub ={}

    #should implement multiple artists but not sure how to do that with urllib:
    #for key in release_artists.get_keys():
    #    release_artist = key
    #    importance = release_artists[key]
    #    sub['artists'] = release_artist
    #    sub['importance'] = importance

    sub['artists']=release_artist
    sub['importance'] = importance
    sub['year']=release_orig_year
    sub['title']=release_album
    sub['record_label']=release_label
    sub['format'] =u'FLAC'
    sub['bitrate']=u'Lossless'
    
    sub['releasetype']=u'1'
    sub['media']=u'CD'
    sub['album_desc'] = release_album_description

    sub['submit'] = u'true'

    sub['logfiles']=release_log
    sub['file_input']=release_torrent

    return(sub)

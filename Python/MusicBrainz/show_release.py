def show_release():
    from musicbrainz2.webservice import Query, ArtistFilter, WebServiceError

    import string
    import musicbrainz2.webservice as ws
    import musicbrainz2.model as m
    import musicbrainz2.utils as u
	
    q = Query()
    inc = ws.ReleaseIncludes(artist=True, releaseEvents=True, labels=True,
                                 discs=True, tracks=True)
    rid = u'http://musicbrainz.org/release/52ec1af7-28a1-42e3-896a-0eddc8e338d5.html'
    release = q.getReleaseById(rid, inc)
    tracks = release.tracks
    
    for t in tracks:
        #print dir(t)
        minutes,seconds = divmod(t.duration/1000,60)
        print t.title, '-', string.join([str(minutes),':',str(seconds)],'')
    
        

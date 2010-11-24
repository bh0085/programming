"""Tests for webservice.Query."""
import unittest
from musicbrainz2.model import Tag
from musicbrainz2.model import Rating
from musicbrainz2.webservice import Query, IWebService, AuthenticationError, RequestError


class FakeWebService(IWebService):

	def __init__(self):
		self.data = []

	def post(self, entity, id_, data, version='1'):
		self.data.append((entity, id_, data, version))
		
class FakeBadAuthWebService(IWebService):
	def post(self, entity, id_, data, version='1'):
		raise AuthenticationError()

class FakeBadRequestWebService(IWebService):
	def post(self, entity, id_, data, version='1'):
		raise RequestError()

class QueryTest(unittest.TestCase):

	def testSubmitUserTags(self):
		ws = FakeWebService()
		q = Query(ws)
		t1 = [u"foo", u"bar", u"f\u014do"]
		t2 = [Tag(u"foo"), Tag(u"bar"), Tag(u"f\u014do")]

		prefix = 'http://musicbrainz.org/artist/'
		uri = prefix + 'c0b2500e-0cef-4130-869d-732b23ed9df5'

		q.submitUserTags(uri, t1)
		q.submitUserTags(uri, t2)

		self.assertEquals(len(ws.data), 2)
		self.assertEquals(ws.data[0], ws.data[1])

		q.submitUserRating(uri, Rating(5))
		q.submitUserRating(uri, 5)

		self.assertEquals(len(ws.data), 4)
		self.assertEquals(ws.data[2], ws.data[3])
		
	def testSubmitIsrc(self):
		tracks2isrcs = {
					    '6a47088b-d9e0-4088-868a-394ee3c6cd33':'NZABC0800001', 
					    'b547acbc-58c6-4a31-9806-e2348db3a167':'NZABC0800002'
		}
		ws = FakeWebService()
		q = Query(ws)
		
		q.submitISRCs(tracks2isrcs)
		
		self.assertEquals(len(ws.data), 1)
		req = ws.data[0]
		qstring = 'isrc=6a47088b-d9e0-4088-868a-394ee3c6cd33+NZABC0800001&isrc=b547acbc-58c6-4a31-9806-e2348db3a167+NZABC0800002'
		self.assertEquals(req[0], 'track')
		self.assertEquals(req[2], qstring)
		
	def testSubmitIsrcBadUser(self):
		ws = FakeBadAuthWebService()
		q = Query(ws)
		
		self.assertRaises(AuthenticationError, q.submitISRCs, {})
	
	def testSubmitIsrcBadTrack(self):
		ws = FakeBadRequestWebService()
		q = Query(ws)
		
		self.assertRaises(RequestError, q.submitISRCs, {})
		
	def testSubmitPuid(self):
		tracks2puids = {
					    '6a47088b-d9e0-4088-868a-394ee3c6cd33':'c2a2cee5-a8ca-4f89-a092-c3e1e65ab7e6', 
					    'b547acbc-58c6-4a31-9806-e2348db3a167':'c2a2cee5-a8ca-4f89-a092-c3e1e65ab7e6'
		}
		ws = FakeWebService()
		q = Query(ws, clientId='test-1')
		
		q.submitPuids(tracks2puids)
		
		self.assertEquals(len(ws.data), 1)
		req = ws.data[0]
		qstring = 'client=test-1&puid=6a47088b-d9e0-4088-868a-394ee3c6cd33+c2a2cee5-a8ca-4f89-a092-c3e1e65ab7e6&puid=b547acbc-58c6-4a31-9806-e2348db3a167+c2a2cee5-a8ca-4f89-a092-c3e1e65ab7e6'
		self.assertEquals(req[0], 'track')
		self.assertEquals(req[2], qstring)
		
	def testSubmitPuidBadUser(self):
		ws = FakeBadAuthWebService()
		q = Query(ws, clientId='test-1')
		
		self.assertRaises(AuthenticationError, q.submitPuids, {})

	def testSubmitPuidBadTrack(self):
		ws = FakeBadRequestWebService()
		q = Query(ws, clientId='test-1')
		
		self.assertRaises(RequestError, q.submitPuids, {})
		
	def testSubmitNoClient(self):
		ws = FakeWebService()
		q = Query(ws)
		
		self.assertRaises(AssertionError, q.submitPuids, None)
	
# EOF

"""Tests for parsing user elements using MbXmlParser."""
import unittest
from musicbrainz2.wsxml import MbXmlParser, ParseError
from musicbrainz2.model import NS_MMD_1, NS_EXT_1
import StringIO
import os.path

VALID_DATA_DIR = os.path.join('test-data', 'valid')
INVALID_DATA_DIR = os.path.join('test-data', 'invalid')

VALID_USER_DIR = os.path.join(VALID_DATA_DIR, 'user')


class ParseUserTest(unittest.TestCase):

	def __init__(self, name):
		unittest.TestCase.__init__(self, name)


	def testUser(self):
		f = os.path.join(VALID_USER_DIR, 'User_1.xml')
		md = MbXmlParser().parse(f)
		userList = md.getUserList()

		self.assertEquals(len(userList), 1)

		user = userList[0]
		self.failIf( user is None )
		self.assertEquals(user.getName(), 'matt')
		self.assertEquals(user.getShowNag(), False)

		types = user.getTypes()
		self.assertEquals(len(types), 2)
		self.assert_( NS_EXT_1 + 'AutoEditor' in types )
		self.assert_( NS_EXT_1 + 'RelationshipEditor' in types )


# EOF

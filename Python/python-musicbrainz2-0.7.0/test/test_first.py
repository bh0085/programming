import unittest

class First(unittest.TestCase):
	def testRun(self):
		self.assert_( True )


def suite():
	suite = unittest.makeSuite(First)
	return suite

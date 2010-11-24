#! /usr/bin/env python
#
# Display data about a MusicBrainz user (user name and password required).
#
# Usage:
#	python user.py
#
# $Id: getuser.py 201 2006-03-27 14:43:13Z matt $
#
import sys
import logging
import getpass
from musicbrainz2.webservice import WebService, WebServiceError, Query

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


user = raw_input('User name: ')
passwd = getpass.getpass('Password: ')

try:
	ws = WebService(host='musicbrainz.org', port=80,
		username=user, password=passwd)
	q = Query(ws)

	user = q.getUserByName(user)

except WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


print 'Name            :', user.name
print 'ShowNag         :', user.showNag
print 'Types           :', ' '.join(user.types)

# EOF

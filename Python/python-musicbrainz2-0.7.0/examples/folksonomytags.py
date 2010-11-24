#! /usr/bin/env python
#
# This queries the tags a user has applied to an entity and submits a changed
# list of tags to the MusicBrainz server.
#
# Usage:
#    python tag.py
#
# $Id: folksonomytags.py 9714 2008-03-01 09:05:48Z matt $
#
import getpass
import sys
import logging
import musicbrainz2.webservice as mbws
from musicbrainz2.model import Tag
from musicbrainz2.utils import extractUuid

MB_HOST = 'test.musicbrainz.org'

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


# Get the username and password
username = raw_input('Username: ')
password = getpass.getpass('Password: ')

# Ask for a MBID to tag.
mbid = raw_input('Enter an absolute MB ID: ')

# Set the authentication for the webservice (only needed for tag submission).
service = mbws.WebService(host=MB_HOST, username=username, password=password)

# Create a new Query object which will provide
# us an interface to the MusicBrainz web service.
query = mbws.Query(service)

# Read and print the current tags for the given MBID
tags = query.getUserTags(mbid)
print
print 'Current tags: '
print ', '.join([tag.value for tag in tags])


# Ask the user for new tags and submit them
tag_str = raw_input('Enter new tags: ')
new_tags = [Tag(tag.strip()) for tag in tag_str.split(',')]

query.submitUserTags(mbid, new_tags)

print 'Tags submitted.'

# EOF

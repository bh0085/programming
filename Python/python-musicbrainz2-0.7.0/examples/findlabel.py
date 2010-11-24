#! /usr/bin/env python
#
# Search for a label by name.
#
# Usage:
#	python findlabel.py 'label-name'
#
# $Id: findlabel.py 9316 2007-08-11 07:38:14Z matt $
#
import sys
import logging
from musicbrainz2.webservice import Query, LabelFilter, WebServiceError

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
	

if len(sys.argv) < 2:
	print "Usage: findlabel.py 'label name'"
	sys.exit(1)

q = Query()

try:
	# Search for all labels matching the given name. Limit the results
	# to the 5 best matches. The offset parameter could be used to page
	# through the results.
	#
	f = LabelFilter(name=sys.argv[1], limit=5)
	labelResults = q.getLabels(f)
except WebServiceError, e:
	print 'Error:', e
	sys.exit(1)


# No error occurred, so display the results of the search. It consists of
# LabelResult objects, where each contains a label.
#
for result in labelResults:
	label = result.label
	print "Score     :", result.score
	print "Id        :", label.id
	print "Name      :", label.name
	print "Sort Name :", label.sortName
	print

#
# Now that you have label IDs, you can request a label directly to get more
# detail. See 'getlabel.py' for an example on how to do that.
#

# EOF

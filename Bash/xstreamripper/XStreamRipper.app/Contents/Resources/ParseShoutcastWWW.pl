#!/usr/bin/perl -w

# Input: curl www.shoutcast.com
# Output: Text file of format: URL\nRADIO STATION NAME\n...
#
# Simon Liu, 23 Oct 2002

# slurp entire input into one variable
local $/ = undef;
$slurp = <STDIN>;

# regexp to search for URL $1 and RADIO STATION NAME $2
while ( $slurp =~ /<a href=\"(\/sbin\/shoutcast-playlist\.pls.*?)\".*?<a.*?href=\".*?\">(.*?)<\/a>.*?>(\d+)<\/f/giso ) {
    print "http://www.shoutcast.com", $1, "\n", "[", $3, " kbps] ", $2, "\n";
}


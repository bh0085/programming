#! /usr/bin/bash
ts="AAA";
as="001";
title="TITLE=$ts \n";
artist="ARTIST=$as \n";
end_of_record=".\n";
meta_data="${title}${artist}${end_of_record}";
echo -e "$meta_data"

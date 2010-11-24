#!/bin/bash

old_IFS=${IFS}
new_IFS='
'
IFS=$new_IFS

find . -name ".DS_Store" -delete
for f in `find . -type d -maxdepth 1`;
do
    mktorrent -a "http://tracker.what.cd:34000/d95f93d9a238d190d0df5334f2072cf8/announce" -p "$f"
done
IFS=$old_IFS
exit 0
#!/bin/bash

function rosa_scp
 {
     # Create the files as needed -- not as good as raw emacs, but
     for f in "$@"
     do
	 #scp=`which scp`
	 scpargs="scp "\""$f"\"' bh0085@rosa.feralhosting.com:/home/bh0085/torrents/downloads/'
	 expec_str="spawn "${scpargs}" ; expect assword ; send din0b0t\n ; interact"
	 expect -c "$expec_str"
     done
 }



cd ${rosa_drop_directory}
for f in *
do
    echo "Moving $f to rosa"
    newname="`echo "$f" | sed 's/[^a-zA-Z0-9\.]//g'`"
    echo $newname
    mv "$f" "$newname"
    rosa_scp "$newname"
    #rm "$f"
done

echo "Delete transferred files? (y/n)"
read yesno
if [[ ${yesno} == y ]]
then
    for f in *
    do
	rm "$f"
    done
fi


exit 0


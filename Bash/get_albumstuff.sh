echo "Provide album art for this release? (y/n)"
read yesno
if [[ $yesno == y ]]
    echo "Copy the image url to the clipboard and hit enter"
    read
    url="`pbpaste`"
    echo $url
    ext=`echo "$url"|awk -F . '{print $NF}'`
    name="cover."${ext}
    echo $name
    wget "${url}" -O $name
    echo "Trim image whitespace? (y/n)"
    read yesno
    if [[ $yesno == y ]]
    then
	convert -trim $name $name
	echo "Trimmed Whitespace"
    fi
else
    url="`no image url`"
fi

echo "Reviews" > reviews.txt
count=1
while [ true ]
do
    echo "Now, copy an album review to the clipboard and hit enter"
    read
    review="`pbpaste`"
    echo "Enter a review description? (Or Leave Blank)"
    read revdes
    if [[ $revdes == "" ]]
    then
	revdes="Review "${count}":"
    fi
    count=count+1
    echo "" >> reviews.txt
    echo "" >> reviews.txt
    echo '[description]'${revdes}'[\description]'>>reviews.txt
    echo "" >> reviews.txt
    echo '[review]' >> reviews.txt
    echo "${review}" >> reviews.txt
    echo '[\review]' >> reviews.txt
    echo "Enter another review? (y/n)"
    read yesno
    if [[ $yesno != y ]]
    then
	break
    fi
done
echo "" >> reviews.txt
echo "" >> reviews.txt
echo "album art url:: ${url}" >> reviews.txt

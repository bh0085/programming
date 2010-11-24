i=0
while [ $i -le 4 ]
do
    var="TITLE=ATBC $i  
ARTIST=001
.
"
    echo -e "$var"
    sleep 2
    i=$(($i+1))
done

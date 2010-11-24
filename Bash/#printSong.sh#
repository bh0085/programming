hour=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
min=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*[0-9]*:\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
sec=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*[0-9]*:[0-9]*:\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
hora=$(((hour+6)%24))
horaf=`printf %02d $hora`
horapf=`printf %02d $(($hora-1))`
secs=$((sec + 60*min + 3600*hora))
lines=`cat canal| wc -l`
maxline=0
lastgood=0
linepast=0
linefirst=`cat canal| grep -n "${horapf}:.*${horaf}.*hora" | grep -o '^[0-9]*'`
for ((i=$linefirst;i<=lines;i++));
do
    line=`cat canal|sed -n "$i p"`
    chars=`echo $line|grep -0 ":[0-9]\{2\}:"|wc -c`
    if [ $chars -gt 1 ]
	then
	curhor=`echo $line|grep -o "^[0-9]\{2\}" |grep -o "[0-9]\{2\}"|sed 's/0\([0-9]\)/\1/'`
	curmin=`echo $line|grep -o ":[0-9]\{2\}:"   |grep -o "[0-9]\{2\}"|sed 's/0\([0-9]\)/\1/'`
	cursec=`echo $line|grep -o ":.*:[0-9]\{2\}" |grep -o "[0-9]\{2\}$"|sed 's/0\([0-9]\)/\1/'`
	cursecs=$((curhor*3600 + curmin*60 + cursec))
	if [ $cursecs -gt $secs ]
	    then
	    linepast=$i
	    break
	fi
	lastgood=$i
    fi
done

red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'  	    

finalline=$(($linepast))
lines=`cat canal|sed -n "$lastgood,$finalline p"`
line1=`echo "$lines"|grep "^[\ ]*[0-9]\{2\}:[0-9]\{2\}:"`

l1markers=`echo "$line1"|sed "s/\ \ \([0-z]\)/@\ \1/g"`
m1=`echo "$l1markers"| sed -n 's/\(^[^@]*@[^@]*@\).*/\1/p' |wc -c`
m2=`echo "$l1markers"| sed -n 's/\(^[^@]*@[^@]*@[^@]*@\).*/\1/p' |wc -c`
m3=`echo "$l1markers"| sed -n 's/\(^[^@]*@[^@]*@[^@]*@[^@]*@\).*/\1/p' |wc -c`
m4=`echo "$l1markers"| sed -n 's/\(.*\)/\1/p' |wc -c`
m1=$((m1))
m2=$((m2-1))
m3=$((m3-1))
m4=$((m4-1))
d1=$((m2-m1-1))
d2=$((m3-m2-1))
d3=$((m4-m3-1))
song=`echo "$lines"| sed -n "s/^.\{$m1\}\(.\{$d1\}\).*/\1/p"`
echo "$lines"
if [ $d2 -ge 0 ]
then
    artist=`echo "$lines"| sed -n "s/^.\{$m2\}\(.\{$d2\}\).*/\1/p"`
fi
if [ $m3 -ge 0 ]
then
    additional=`echo "$lines"| sed -n "s/^.\{$m3\}\(.*\)/\1/p"`
fi
    artist=`echo $artist`
    song=`echo $song`
    additional=`echo $additional`
echo -e "Song:    " "${red}$song${NC}" 
echo -e "Artist:  " "${blue}$artist${NC}" 
echo -e "Info:    " "${cyan}$additional${NC}"
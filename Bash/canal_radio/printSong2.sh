elinks -source http://blogs.canalsur.es/parrilla_cfl/ >csource
cat csource |  
sed -n '
/<td/ {
  /\/td/ !{
    b addnext
  }
  /\td/    {
    p
  }
}
b
:addnext
N
s/\n/\ /
p
' |
sed -n '
s/&#[0-9]*;//g
s/<[^>]*>//gp
' >cs

withnum=`cat cs|grep -n ":[0-9]\{2\}:"`
numlines=`echo "$withnum"|wc -l`

hour=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
min=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*[0-9]*:\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
sec=`date|sed 's/^[a-zA-Z\ ]*[0-9]\{1,2\}[\ ]*[0-9]*:[0-9]*:\([0-9]*\).*/\1/'|sed 's/0\([0-9]\)/\1/'`;
hora=$((($hour+6)%24))
horaf=`printf %02d $hora`
horapf=`printf %02d $(($hora-1))`
secs=$(($sec + 60*$min + 3600*$hora))

for ((i=1;i<=$numlines;i++));
do
    line=`echo "$withnum"|sed -n "$i p"`
    curhor=`echo "$line"|sed -e "s/^[0-9]*:\([0-9]\{2\}\).*/\1/"                  -e 's/0\([0-9]\)/\1/'`
    curmin=`echo "$line"|sed -e "s/^[0-9]*:[0-9]*:\([0-9]\{2\}\).*/\1/"           -e 's/0\([0-9]\)/\1/'`
    cursec=`echo "$line"|sed -e "s/^[0-9]*:[0-9]*:[0-9]*:\([0-9]\{2\}\).*/\1/"    -e 's/0\([0-9]\)/\1/'`
    cursecs=$(($curhor*3600 + $curmin*60 + $cursec))
    if [ $cursecs -gt $secs ]
       then
       linepast=$i
       break
    fi
    lastgood=$i
done
num1=`echo "$withnum"|sed -n "$lastgood s/\(^[0-9]*\).*/\1/p"`
num2=`echo "$withnum"|sed -n "$linepast s/\(^[0-9]*\).*/\1/p"`
final=`cat cs|sed -n "$num1,$(($num2-1)) p"`
starttime=`echo "$final"|sed -n "1 p"`
song=`echo "$final"|sed -n "2 p"`
artist=`echo "$final"|sed -n "3 p"`
extra=`echo "$final"|sed -n "4 p"`

red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'  

echo -e "${red}$artist ${NC}- ${blue}$song${NC}"

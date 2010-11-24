cat=0;
doEdit=0;
string="http://localhost/~bh0085/mediawiki/index.php?"
while getopts ":ce" Option
do
  case $Option in
    c     ) cat=1;;
    e     ) doEdit=1;;
    *     ) echo "Unimplemented option chosen.";;   # Default.
  esac
done
shift $(($OPTIND - 1))

string=$string"title="

if [ $cat != 0 ]; then
    string=$string"Category:"
fi
string=$string$1
if [ $doEdit != 0 ]; then
    string=$string'&action=edit'
fi
open $string
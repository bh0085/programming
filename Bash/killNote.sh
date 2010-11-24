if [ $# -eq 1 ]
then
    cat $notepad | sed -n "/^$1/ p" > $notepad
fi
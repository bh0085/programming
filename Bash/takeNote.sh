if [ $# -ne 2 ]
then
    priority=5
else 
    priority=$2
fi
echo "-- $priority -- $1" >>  ~/Programming/Bash/notepad

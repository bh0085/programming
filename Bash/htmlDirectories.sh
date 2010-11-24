if [ $# -ge 1 ]
    then
    file=$1
    cd /Users/bh0085/Programming/Bash/
    fIn=`cat $file`
    echo "<html>" > htmlOut
    echo '<head>' >>htmlOut
    echo '<title> page Title </title>' >> htmlOut
    echo '</head>'>>htmlOut
    echo '<body style="font-size:30px; color:orange">' >>htmlOut
    cat $file | sed 's/::/<br \/>/g' >> htmlOut
    echo "</body>" >>htmlOut
    echo "</html>" >>htmlOut
fi

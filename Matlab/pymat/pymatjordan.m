function pymatjordan()
    data = pymatread();
    arr = data.array;
    size(arr)
    
    [j,v] = jordan(arr);
    output.j = j;
    output.v = v;
    pymatwrite(output);
    exit();
function pymatwrite(data)
    path = getenv('PYMAT_PATH');
    save(strcat(path, '/matlab.mat'),'data');
    
    
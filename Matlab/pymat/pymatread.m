function [readval] = pymatread()
    path = getenv('PYMAT_PATH');
    readval = load(strcat(path, '/python.mat'));
    
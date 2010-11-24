function pymatshow(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    path = getenv('PYMAT_PATH')
    loaded = load(strcat(path, '/python.mat'))
    img = loaded.image
    imshow(img)
    
    outfile = strcat(path, 'matlab.mat')
    save(outfile, 'loaded')
    exit()
    
end


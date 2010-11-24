function trishow(x, y, z)


tri = delaunay(x,y);
trisurf(tri,x,y,z); 

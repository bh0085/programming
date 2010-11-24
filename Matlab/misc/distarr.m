function out = distarr(sx,sy)
if nargin < 2
   sy = sx;
end

n=sx*sy;
x=mod(0:n-1,sx);
y=floor((0:n-1)/sx);
out=reshape(sqrt(x.^2 + y.^2),sx,sy); 
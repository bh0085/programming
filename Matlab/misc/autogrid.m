function [xout,yout,zout] = autogrid(x,y,z,res)
if nargin < 4, res = 100; end
if length(res) == 1, res = [res,res]; end
xmin = (min(x));
ymin = (min(y));
xmax = (max(x));
ymax = (max(y));
xstep= (xmax - xmin)/res(1);
ystep= (ymax - ymin)/res(2);

rangeX=(xmin):xstep:(xmax);
rangeY=(ymin):ystep:(ymax);

[xout,yout]=meshgrid(rangeX',rangeY');

zout=griddata(x,y,z,xout,yout,'linear');

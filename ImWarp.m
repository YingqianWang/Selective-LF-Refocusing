%% This function shifts the image by (x,y) using filtering
function  OpIm = ImWarp(IpIm, x, y)
sm = max(abs(floor(x))+1, abs(floor(y))+1);
Mask = zeros(2*sm+1, 2*sm+1);
X = floor(x); fx = x-X;
Y = floor(y); fy = y-Y;
Center = sm + 1;
Mask(Center+X, Center+Y) = 1-fx-fy;
Mask(Center+X+1, Center+Y) = fx;
Mask(Center+X, Center+Y+1) = fy;
OpIm = imfilter(IpIm, Mask',  'symmetric' );
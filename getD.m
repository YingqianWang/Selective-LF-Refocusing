%% To get the corresponding refocusing shift for each sub-image
function D = getD(slope, m)
M = m*m;
VVec = linspace(-0.5,0.5, m) *(m-1)*slope;
UVec =  linspace(-0.5,0.5, m) *(m-1)*slope;
UMat = repmat(UVec, 1, m);
VMat = repmat(VVec, m, 1);
D = zeros(M,2);
for i = 1:M
    D(i,:) = [VMat(i),UMat(i)];
 end
 
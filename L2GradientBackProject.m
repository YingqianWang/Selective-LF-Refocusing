%% This function calculates the gradients of the L2 fidelity term
%% Please refer to our previous IEEE Access Paper for details
%% Title: Fast Convergence Strategy for Multi-Image Superresolution via Adaptive Line Search

function Gback = L2GradientBackProject( Xn, y, D, Gau, spf, Wn ) 

Zn = imfilter(Xn, Gau, 'symmetric');
[~, ~, M] = size(y);
 
HRsd = zeros( size( y ) );
LW = zeros( size( y ) );
for k = 1 :M
  Z =  ImWarp(Zn, D(k,2), D(k,1));
  W = ImWarp(Wn, D(k,2), D(k,1));
  HRsd( :, :, k ) = imresize(Z, 1/spf);
  LW( :, :, k ) = imresize(W, 1/spf);
end

temp = LW.*(HRsd-double(y));
HR = zeros(size(Xn));

for k = 1 : M
 HR(:,:,k) = imresize(temp(:,:,k), spf);
 HR(:,:,k) =  ImWarp(HR(:,:,k), -D(k,2), -D(k,1));
 HR(:,:,k) = imfilter(HR(:,:,k), Gau, 'symmetric');
end
Gback = sum(HR,3);
end



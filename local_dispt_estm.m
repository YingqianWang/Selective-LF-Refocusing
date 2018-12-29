%% This function estimates the local disparity and reliability
function [Disparity, Reliability] = local_dispt_estm(Image, SLOPE, threshold)

[row, col, M] = size(Image);
m = sqrt(M);
SizeSlope = size(SLOPE);
slope_begin = SLOPE(1);
slope_end = SLOPE(SizeSlope(2));
Var = zeros(SizeSlope(2), row, col);                                % image variance while refocusing under different slopes
AVG   = fspecial('average',[7, 7]);                                 % kernel of the average filter
for ns = 1 : SizeSlope(2)
    slope = SLOPE(ns);
    D = getD(slope, m);                                             % get the corresponding refocusing shift for each sub-image
    
    for k = 1 :M
        shifted_Im(:,:,k) = ImWarp(Image(:,:,k), -D(k,2), -D(k,1)); % shift the sub-images with the selected slope value
    end

    temp = var(double(shifted_Im) ,0, 3);                           % equation (2) in the IEEE Access paper
    Var(ns, :, :) = sqrt(temp);                                     % equation (3) in the IEEE Access paper
    Var(ns,:,:) = imfilter(Var(ns,:,:), AVG, 'replicate');          % equation (3) in the IEEE Access paper
   
end
[~, Index] = sort(Var);                                             % sort Var in 'slope' direction
temp = squeeze(Index(1,:,:)); % equation (4) in the IEEE Access paper, select the slope corresponding to minimum Var
Disparity = ScaleAdjust(temp, slope_begin, slope_end);              % map the index to disparity based on the slope range

% To calculate the Reliability according to equation (5)-(9)
A = ones(row,col);
Varsvar = var(Var, 0, 1);                                           % equation (5) in the IEEE Access paper, the second-order variance 
W = squeeze(Varsvar(1, :, :));
Lw = log((W+10^-4)/(min(W(:))+10^-4));                              % equation (6) in the IEEE Access paper
eta = Lw/max(max(Lw));                                              % equation (7) in the IEEE Access paper
Reliability = A./(1+exp(-15*(eta-threshold*A)));                    % equation (9) in the IEEE Access paper

% Note that, the decaying factor should be set to -15, not 15 which is performed in the IEEE Access paper
end

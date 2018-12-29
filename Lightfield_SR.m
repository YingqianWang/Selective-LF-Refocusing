%% This function super-resolves the focused region using the bokeh image as a regularization term

function ImZ = Lightfield_SR(LF_Image,Disparity,slope,I_bokeh,lambda_b,NoI,a,b)

[U, V, ~, ~, ~] = size(LF_Image);
m = U;
M = U*V;

%% Parameter Initialization
Gau = fspecial('gaussian', [3, 3], 0.1);                     % Gaussian kernel of the point spread function
spf = 2;                                                     % sampling factor
beta = 0.1;                                                  % step size
lambda_BTV = 0.2;                                            % weight of the BTV regularization term

D = spf * getD(slope, m);   % The left column of D corresponds to the column-shift of images, 
                            % whereas the right column of D corresponds to the row-shift of images
                            % Note that the shifts is proportion to the sampling factor

% Reshape the LF for refocusing
for u = 1 : U
    for v = 1 : V
        k = m*(u-1)+v;
        Image(:, :, :, k) = squeeze(LF_Image(u, v, :, :, :));
    end
end

for color = 1:3
    
    y = squeeze( Image(:,:,color,:));
    for i = 1 :M
        HR(:,:,i) = imresize(y(:,:,i), spf, 'bicubic');         % get initial HR image using bicubic interpolation
        HR(:,:,i) =ImWarp(HR(:,:,i), -D(i,2), -D(i,1));         % warp the sub-images to refocus
    end
    HRitp = sum(HR,3)/ M;                                       % shift-and-sum refocusing approach
    
    I = L2SD(y,spf,Gau,slope,HRitp,beta,lambda_b,lambda_BTV,NoI,squeeze(I_bokeh(:,:,color)),Disparity,a,b); % LFSR
    ImZ(:,:,color) = I ;
    
end


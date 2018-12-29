%% This function renders the bokeh in out-of-focus regions
function I_bokeh = bokeh_rendering(LF_Image, Disparity, slope, K)

[u, v, row, col, ~] = size(LF_Image);
cu = 0.5*(u+1);
cv = 0.5*(v+1);
I_center = squeeze(LF_Image(cu, cv, :, :, :));
I_bokeh = I_center;                                 % Set the initial bokeh image as the center-view sub-image

delta_Dis = Disparity - slope*ones(size(Disparity));% Equation (5)
Radius = K*delta_Dis;
Rmax = max(abs(Radius(:)));                         % maximum radius of CoC in the image.
Patchsize = ceil(2*Rmax);                           % ensure that Patch radius is larger than Rmax
if (Patchsize/2 == round(Patchsize/2))              % ensure that Patchsize is an odd number
    Patchsize = Patchsize + 1;
end

pr = (Patchsize+1)/2;                               % Patch radius
Patch = zeros(size(Patchsize, Patchsize));
ONE = ones(size(Patch));
ZERO = zeros(size(Patch));

% Calculate the weight of the anisotropic filter
for i = 1 : Patchsize
    for j = 1 : Patchsize
        Patch(i, j) = sqrt((pr-i)^2+(pr-j)^2);        
    end
end

% Render the bokeh with an anisotropic filter
parfor i = pr : row-pr+1
    for j = pr : col-pr+1
        
        RPatch = squeeze(Radius(i-pr+1 : i+pr-1, j-pr+1 : j+pr-1));
        Mask = ( ONE.*double(abs(RPatch)-Patch>0.5*ONE) + ZERO.*double(Patch-abs(RPatch)>0.5*ONE) ...
             +(abs(RPatch)-Patch+0.5*ONE).*double(abs(RPatch)-Patch<=0.5*ONE).*double(Patch-abs(RPatch)<=0.5*ONE) )...
             .*((abs(RPatch(pr,pr)) < K) * double(RPatch - RPatch(pr,pr)*ONE > -0.2*Rmax*ONE)...
             + double(abs(RPatch(pr,pr)) >= K) * ONE);
        
        Mask = Mask/sum(Mask(:));
        for color = 1 : 3
            IPatch = squeeze(I_center(i-pr+1 : i+pr-1, j-pr+1 : j+pr-1, color));
            I_bokeh(i, j, color) = sum(double(IPatch(:)).*Mask(:));
        end
    end
end


for color = 1 : 3       % Dealing with image boundaries
    I_bokeh( :, 1:pr-1, color) = repmat(I_bokeh( :, pr, color), 1, pr-1);
    I_bokeh( :, col-pr+2:end, color) =repmat(I_bokeh( :, col-pr+1, color), 1, pr-1);
    I_bokeh( 1:pr-1, :, color) = repmat(I_bokeh( pr, :, color), pr-1, 1);
    I_bokeh( row-pr+2:end, :, color) = repmat(I_bokeh( row-pr+1, :, color), pr-1, 1);
end


%%    Codes of Our IEEE Signal Processing Letters PAPER 'Selective Light Field
%%    Refocusing for Camera Arrays Using Bokeh Rendering and Superresolution'

%%    Corresponding Contributor: Yingqian Wang (email: wangyingqian16@nudt.edu.cn)
%%    Author Afflications: National University of Defense Technology, China

%%    TERMS OF USE :
%%    Any scientific work that makes use of our code should appropriately cite our SPL paper.

clear all
clc

%% Read the input and form the Light Field
path = '../data/Dolls/';
files = dir(fullfile( path,'*.png'));
M= length(files);                       % total number of sub-images
m = sqrt(M);                            % size of the camera array, e.g., m = 3 for a 3*3 camera array

slope_begin = -4;    slope_end = 0;     % slope range of Scene Dolls
depth_res = 20;                         % depth resolution, i.e., the total number of depth layers
SLOPE = linspace(slope_begin, slope_end, depth_res);

for u = 1 : m
    for v = 1 : m
        k = (u-1)*m+v;
        I = imread([path,'/',files(k).name]);
        Image(:,:,k) =rgb2gray(I);   % use gray-scale image for disparity estimation
        LF_Image(u,v,:,:,:) = I;
    end
end

%% Disparity (or Depth) Estimation
% This approach corresponds to our previous IEEE ACCESS Paper Titled:
% Disparity Estimation for Camera Arrays using Reliability Guided Disparity Propagation

[temp, Reliability] = local_dispt_estm(Image, SLOPE, 0.5);    % Estimate the local disparity and reliability
Local_Disparity = ScaleAdjust (temp,slope_begin, slope_end);  % Scale Adjustment
Disparity = RGDP_optm(Local_Disparity, Reliability);          % RGDP optimization

%% Selective Light Field Refocusing

f = 3;                              % The Index of the in-focus plane (range from 1 to depth_res)
NoI = 10;                           % Number of Iteration
a = 15;                             % Decaying factor in sigmoid transformation
b = 0.3;                            % Threshold in sigmoid transformation
K = 3;                              % Bokeh intensity
lambda_b = 5;                       % Weight of bokeh regularization term

I_bokeh = bokeh_rendering(LF_Image,Disparity,SLOPE(f),K);                   % Bokeh Rendering Approach

ImZ = Lightfield_SR(LF_Image,Disparity,SLOPE(f),I_bokeh,lambda_b,NoI,a,b);  % Bokeh-regularized SR

figure; imshow(uint8(ImZ)); title('Wang2018Selective');
saveas(gcf, ['../results/', 'Wang2018Selective.png'])





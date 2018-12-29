%% This function corresponds to a Patchsize*Patchsize median filter
function OutputIm = medianfilter(InputIm, Patchsize)
[r, c] = size(InputIm);
OutputIm = InputIm;
radius = (Patchsize-1)/2;
for i = 1 : r-Patchsize+1
    for j = 1 : c-Patchsize+1
        Patch = InputIm(i : i+Patchsize-1, j : j+Patchsize-1);
        med = median(Patch(:));
        OutputIm(i+radius, j+radius) = med;
    end
end
%% Boundary operation
OutputIm(1:radius, :) = repmat(OutputIm(radius+1, :), radius, 1);
OutputIm(r-radius+1:r, :) = repmat(OutputIm(r-radius, :), radius, 1);
OutputIm(:, 1:radius) = repmat(OutputIm(:, radius+1), 1, radius);
OutputIm(:, c-radius+1:c) = repmat(OutputIm(:, c-radius), 1, radius);
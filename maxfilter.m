%% The designed maximum filter is used to dilate Reliability
function OutputIm = maxfilter(InputIm, Patchsize)
[r, c] = size(InputIm);
OutputIm = InputIm;
for i = 1 : r-Patchsize+1
    for j = 1 : c-Patchsize+1
        Patch = InputIm(i : i+Patchsize-1, j : j+Patchsize-1);
        OutputIm(i+(Patchsize-1)/2, j+(Patchsize-1)/2) = max(Patch(:));
    end
end
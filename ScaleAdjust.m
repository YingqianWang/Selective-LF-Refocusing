%% To adjust the scale of I to interval [a, b]
function Z = ScaleAdjust(I, a, b)
minI = min(I(:));
maxI = max(I(:));
A = ones(size(I));
Z = a*A + (I-minI*A)*(b-a)/(maxI-minI);
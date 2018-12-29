%% This function calculates the gradients of the BTV regularization term
%% Please refer to our previous IEEE Access Paper for details
%% Title: Fast Convergence Strategy for Multi-Image Superresolution via Adaptive Line Search

function L = Gradient_BTV(X, alpha, P)

L = 0;
for l = -P : P
    for m = 0 : P
        if(l + m >=0)
        temp1 = ImWarp(X, l, m);
        temp2 = alpha^(abs(m)+abs(l))*sign(X-temp1);
        temp3 = ImWarp(temp2, -l, -m);
        L = L + (temp2 - temp3);
        end
    end
end
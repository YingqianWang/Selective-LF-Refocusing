%% This function super-resolves the focused region by using the steepest descent approach
%% with an L2-norm fidelity term, a BTV regularization term, and a bokeh regularization term

function  I =  L2SD(y,spf,Gau,slope,HRitp,beta,lambda_b,lambda_BTV,NoI,I_bokeh,Disparity,a,b)
[~,~,M] = size(y);
iter = 1;
X= double(HRitp);
I_bokeh = double(imresize(I_bokeh, spf));
Disparity = imresize(Disparity, spf);
D = spf * getD(slope, sqrt(M));
ONE = ones(size(Disparity));
eta_p = abs(Disparity-slope*ONE) / (max(Disparity(:))-min(Disparity(:)));  % according to Step 1 in w_b calculation
W_b = ONE ./ (ONE + exp(-a*(eta_p-b*ONE)));                                % according to Step 2 in w_b calculation
W = ONE ./ (ONE + exp(a*(eta_p-b*ONE)));

%% iterative reconstruction process
while (iter<=NoI)
    Gback = L2GradientBackProject(X,y,D,Gau,spf,W);                     % The gradient of the fidelity term
    J_b = W_b.*(X-I_bokeh);                                             % Residuals of the bokeh regularization term
    J_BTV = Gradient_BTV(X, 0.7, 3);                                    % The gradient of the BTV regularization term
    deltaF = (ONE-W_b).*Gback + lambda_b * J_b + lambda_BTV * J_BTV;    % Integration of these terms
    X = X -beta*deltaF;
    iter=iter+1;
end
I = X;
end

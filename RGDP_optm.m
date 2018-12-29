%% Refine the Disparity map using RGDP

function Final_Disparity = RGDP_optm(Disparity, Reliability)

[row, col] = size(Disparity);
Masksize = 2*ceil(0.005*max(row, col))+1;           % size of the filter kernel

bg = (Masksize+1)/2;                                % beginning coordinate of filtering
r_end = row - (Masksize-1)/2;                       % ending coordinate of filtering in row direction
c_end = col - (Masksize-1)/2;                       % ending coordinate of filtering in column direction
r = (Masksize-1)/2;                                 % radius of the filter kernel

beta = 0.1;                                         % step size of correction

Disparity = medianfilter (Disparity, Masksize);     % using median filter to preprocess the local disparity

Z = Disparity;
Zf = Disparity;
W = Reliability;

%% Reliability Guided Disparity Downflow (Algorithm 1)

for k = 1 : 10
    for i = bg : r_end
        for j = bg : c_end
            PatchZ = Z(i-r : i+r, j-r : j+r);
            WPatchZ= W(i-r : i+r, j-r : j+r);
            MaskZ = WPatchZ/sum(WPatchZ(:));
             Zf(i, j) = sum(PatchZ(:).*MaskZ(:));
        end
    end
    % boundaries are handled by replication
    Zf(:, 1:bg-1) = repmat(Zf(:,bg), 1, r);
    Zf(:, c_end+1:end) =repmat(Zf(:,c_end), 1, r);
    Zf(1:bg-1, :) = repmat(Zf(bg,:), r, 1);
    Zf(r_end+1:end, :) = repmat(Zf(r_end,:), r, 1);
    
    % Reliability-weighted correction
    deltaZ = 2*(1-W).*(Z-Zf);
    Z = Z - beta*deltaZ;
end

W1 = W; % record the undilated Reliability as W1

%%  Reliability dilation
for k = 1 : 10
   W = maxfilter(W, 3); % use the designed maximum filter to dilate Reliability
end

%% Reliability Guided Disparity Backflow (Algorithm 2)
Doubt = ones(size(W)) - W;
for k = 1 : 10
    
    for i = bg : r_end
        for j = bg : c_end
            PatchZ = Z(i-r : i+r, j-r : j+r);
            WPatchZ= Doubt(i-r : i+r, j-r : j+r);
            MaskZ = WPatchZ/sum(WPatchZ(:));
            Zf(i, j) = sum(PatchZ(:).*MaskZ(:));            
        end
    end
    
    % boundaries are handled by replication
    Zf(:, 1:bg-1) = repmat(Zf(:,bg), 1, r);
    Zf(:, c_end+1:end) =repmat(Zf(:,c_end), 1, r);
    Zf(1:bg-1, :) = repmat(Zf(bg,:), r, 1);
    Zf(r_end+1:end, :) = repmat(Zf(r_end,:), r, 1);
    
    % Reliability-weighted correction
    deltaZ = 2*(W-W1).*(Z - Zf);
    Z = Z - beta*deltaZ;
    
end

Final_Disparity = Z;

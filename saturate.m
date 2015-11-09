function [err,prc] = saturate(err,prc)
    if nargin < 2
        prc = prctile(err,50);
    end
    mask = (err > prc);
    err(mask) = prc; 
end

% err = log(1+err);
% err = err./max(err);
% err = ((err - min(err)) / (max(err)-min(err))) * (0.995 - 0.005) + 0.005;
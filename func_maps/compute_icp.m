function [C_out,idxs] = compute_icp(Phis,As,C_in,params)
%
% params.tol, default value = 5e-06
%

Phis.query = Phis.query(:,1:params.k);
Phis.target = Phis.target(:,1:params.k);

params_ann = struct;
params_ann.algorithm = 'linear'; % use 'kmeans' for some speedup
params_ann.trees = 8;
params_ann.checks = 64;
params_ann.centers_init = 'kmeanspp';
params_ann.iterations = -1;

kN = size(Phis.target,1);

% flann_search(target, query)
[idxs, dists] = flann_search(Phis.target', C_in * Phis.query', 1, params_ann);

err = sum(sqrt(dists));
err = err / (kN * size(C_in,1));

if params.flag_verbose
    fprintf('[i] iter: %3.0f, MSE: %3.2f\n', 0, err);
end

if params.max_iters == 0
    C_out = C_in;
    idxs = idxs';
    return
end

% Start iterations

C_prev = C_in;
err_prev = err;
idxs_prev = idxs;

for i = 1:params.max_iters
    
    [U,~,V] = svd(Phis.query' * Phis.target(idxs,:));
    C_out = U * V';
    C_out = C_out';
    
    [idxs, dists] = flann_search(Phis.target', C_out * Phis.query', 1, params_ann);
    
    err = sum(sqrt(dists));
    err = err / (kN * size(C_in,1));
    
    if params.flag_verbose
        fprintf('[i] iter: %3.0f, MSE: %3.2f\n', i, err);
    end
    
    if err > err_prev
        if params.flag_verbose
            fprintf('[i] local optimum reached, quitting...\n');
        end
        C_out = C_prev;
        idxs = idxs_prev;
        break;
    end
    
    if (err_prev - err) < params.tol 
        if params.flag_verbose
            fprintf('[i] local optimum reached, quitting...\n');
        end
        break;
    end
    
    err_prev = err;
    C_prev = C_out;
    idxs_prev = idxs;
    
end

idxs = idxs';

end

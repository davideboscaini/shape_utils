function [D, matches] = run_icp(M, N, C_init, max_iters)

verbose = 1;

if verbose
    fprintf('Running ICP...\n');
end

ann_params = struct;
ann_params.algorithm = 'linear'; %use 'kmeans' for some speedup
ann_params.trees = 8;
ann_params.checks = 64;
ann_params.centers_init = 'kmeanspp';
ann_params.iterations = -1;

kN = size(N.phi,1);

% flann_search(target, query)
[matches, dists] = flann_search(N.phi', C_init*M.phi', 1, ann_params);

err = sum(sqrt(dists));
err = err / (kN*size(C_init,1));

if verbose
    fprintf('(0) MSE: %.2e\n', err);
end

if max_iters == 0
    D = C_init;
    matches = matches';
    return
end

% Start iterations

D_prev = C_init;
err_prev = err;
matches_prev = matches;

% figure, plot_cloud([],N.phi(:,2:4),'b.'); axis equal; hold on; plot_cloud([],M.phi(:,2:4),'r.');
% figure, plot_cloud([],N.phi(:,2:4),'b.'); axis equal; hold on; pp = M.phi*C_init';plot_cloud([],pp(:,2:4),'r.');

for i=1:max_iters
    
    [U,~,V] = svd(M.phi' * N.phi(matches,:));
    D = U * V';
    D = D';
    
%         figure, plot_cloud([],N.phi(:,2:4),'b.'); axis equal; hold on; pp = M.phi*D';plot_cloud([],pp(:,2:4),'r.');
    
    [matches, dists] = flann_search(N.phi', D*M.phi', 1, ann_params);
    
    err = sum(sqrt(dists));
    err = err / (kN*size(C_init,1));
    
    if verbose
        fprintf('(%d) MSE: %.2e\n', i, err);
    end
    
    if err > err_prev
        if verbose
            fprintf('Local optimum reached.\n');
        end
        D = D_prev;
        matches = matches_prev;
        break;
    end
    
    if (err_prev - err) < 5e-6
        if verbose
            fprintf('Local optimum reached.\n');
        end
        break;
    end
    
    err_prev = err;
    D_prev = D;
    matches_prev = matches;
    
end

matches = matches';

end

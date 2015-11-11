function run_compute_eigendec(paths,params)

if nargin < 2
    params.k = 100;
    params.shift = 'SM';
end

% shape instances
tmp = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the shape instances
parfor idx_shape = 1:length(names)
    
    % re-assigning structs variables to avoid parfor errors
    paths_ = paths;
    params_ = params;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    if ~params_.flag_recompute
        % avoid unnecessary computations
        if exist(fullfile(paths_.output,[name,'.mat']),'file')
            fprintf('[i] shape %s already processed, skipping\n',name);
            continue;
        end
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load LB operator
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    W = tmp.W;
    A = tmp.A;
    
    % compute the eigendecomposition
    [Phi,Lambda] = eigs(W,A,params_.k,params_.shift);

    % re-order the eigenvectors according to the eigenvalues
    Lambda = diag(abs(Lambda));
    [Lambda,idxs] = sort(Lambda);
    Phi = Phi(:,idxs);
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),Phi,Lambda);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,Phi,Lambda) 
save(path,'Phi','Lambda','-v7.3');
end

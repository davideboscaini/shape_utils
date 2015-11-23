function run_compute_geod_patches(paths,params)

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
            fprintf('[i] shape ''%s'' already processed, skipping\n',name);
            continue;
        end
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current eigendecomposition
    %tmp = load(fullfile(paths_.input,[name,'.mat']));
    %shape = tmp.shape;
    % [M, ~] = compute_extraction(shape, params_);
    
    M = compute_geod_patches(name,paths_,params_);
    
    % make a big matrix out of all the various M_i
    % each matrix in the cell array is stacked row after row.
    % this allows a more efficient moltiplication and handling in theano
    M = sparse(cat(1,M{:}));
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),M);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,M)
save(path,'M','-v7.3')
end

function run_compute_sihks(paths,params)

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
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    Phi = tmp.Phi;
    Lambda = tmp.Lambda;
    
    % compute the heat kernel signature (HKS)
    desc = compute_sihks(Phi,Lambda,params_);
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),desc);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,desc)
save(path,'desc','-v7.3')
end

function run_compute_lbo(paths)

% shape instances
tmp = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the shape instances
parfor idx_shape = 1:length(names)
    
    % re-assigning structs variables to avoid parfor errors
    paths_ = paths;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % avoid unnecessary computations
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape ''%s'' already processed, skipping\n',name);
        continue;
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute the Laplace-Beltrami operator
    [W,A] = compute_lbo(shape);
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),W,A);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,W,A)
save(path,'W','A','-v7.3');
end

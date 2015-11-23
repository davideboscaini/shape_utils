function run_compute_range_map(paths,params)

% dataset instances
tmp   = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
parfor idx_shape = 1:length(names)
    
    %
    params_ = params; 
    paths_ = paths;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    %
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape %s already processed, skipping\n',name);
        continue;
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp   = load(fullfile(paths.input,[name,'.mat']));
    shape = tmp.shape;
    
    %
    view_angles = linspace(0,2*pi,params_.n_view_angles);
    
    for idx_view_angle = 1:params_.n_view_angles
        
        params_.view_angle = view_angles(idx_view_angle);
        
        [shape,idxs] = compute_range_map(shape,params_);
    
        % saving
        if ~exist(paths_.output,'dir')
            mkdir(paths_.output);
        end
        par_save(fullfile(paths_.output,[name,'_',sprintf('%03.0f',idx_view_angle),'.mat']),shape,idxs);
    
    end
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,shape,idxs)
save(path,'shape','idxs','-v7.3');
end

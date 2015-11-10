function run_compute_albo(paths,params)

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
    
    % avoid unnecessary computations
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape %s already processed, skipping\n',name);
        continue;
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp = load(fullfile(paths.input,[name,'.mat']));
    shape = tmp.shape;
    
    % TO BE REMOVED IN A FUTURE VERSION
    % shape = rescale_shape(shape,params_.scale_factor);
    
    for idx_angle = 1:length(params_.angles)
        
        % current angle
        angle = params_.angles(idx_angle);
        
        % compute the anisotropic Laplace-Beltrami operator
        [W,A] = calc_ALB(shape,angle,params_);
        
        % saving
        paths_.output_ = fullfile(paths_.output,sprintf('alpha=%03.0f',params_.alpha),sprintf('angle=%03.0f',rad2deg(angle)));
        if ~exist(paths_.output_,'dir')
            mkdir(paths_.output_);
        end
        par_save(fullfile(paths_.output_,[name,'.mat']),W,A);
        
    end
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,W,A)
save(path,'W','A','-v7.3');
end

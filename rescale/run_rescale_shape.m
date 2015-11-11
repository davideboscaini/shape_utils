function run_rescale_shape(paths,params)
%
% run_rescale_shape(paths,params)
%    rescales the given shapes
%
% inputs:
%    paths, struct containing the following fields
%       input, path to the folder containing the input shapes
%       output, path to the folder where to save the rescaled shapes
%    params, struct containing the following fields
%       flag_compute_scale_factor
%

if nargin < 2
    params.flag_compute_scale_factor_to_unit_diam = 1;
    params.flag_compute_scale_factor_to_200_diam = 0;
    params.avoid_geods = 0;
    params.flag_recompute = 1;
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
            fprintf('[i] shape ''%s'' already processed, skipping\n',name);
            continue;
        end
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute scale factor
    if params_.flag_compute_scale_factor_to_unit_diam
        params_.scale_factor = compute_scale_factor_to_unit_diam(shape,params_);
    elseif params_.flag_compute_scale_factor_to_200_diam
        params_.scale_factor = compute_scale_factor_to_200_diam(shape,params_);
    end
        
    % rescale shape
    shape = rescale_shape(shape,params_.scale_factor);
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),shape);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,shape)
save(path,'shape','-v7.3')
end

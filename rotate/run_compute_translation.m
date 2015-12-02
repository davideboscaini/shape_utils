function run_compute_translation(paths,params)
%
% run_compute_translation(paths,params)
%    translate the given shapes according to the input parameters
%
% inputs:
%    paths, struct containing the following fields
%       input, path to the folder containing the shapes
%       output, path to the folder where to save the translated shapes
%    params, struct containing the following fields
%       theta, rotation angle
%       idxs, in which order to consider the coordinates
%       signs, which sign to assign to the coordinates
%

% if nargin < 2
%     flag_params = 0;
% else
%     flag_params = 1;
% end

% dataset instances
tmp   = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
n_shapes = length(names);
for idx_shape = 1:n_shapes
    
    paths_ = paths;
    params_ = params;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    %
    if ~params_.flag_recompute
        if exist(fullfile(paths_.output,[name,'.mat']),'file')
            fprintf('[i] shape ''%s'' already processed, skipping\n',name);
            continue;
        end
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,n_shapes);
    time_start = tic;
    
    % load current shape
    tmp   = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;

    %
    %if flag_params
    %    shape = compute_translation(shape,params_);
    %else
    shape = compute_translation(shape);
    %end
    
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

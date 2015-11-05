function run_compute_geods(paths)
%
% run_compute_geods(paths)
%    computes the geodesic distances for the given shapes
%
% inputs:
%    paths, struct containing the following fields
%       input, path to the folder containing the shapes
%       output, path to the folder where to save the descriptors computed
%

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
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load shape
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute geodesic distances
    idxs = [1:length(shape.X)]';
    geods = compute_geods(shape,idxs);
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),geods);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,geods)
save(path,'geods','-v7.3');
end

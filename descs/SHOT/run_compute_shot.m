function run_compute_shot(path_input,path_output,params)
%
% run_compute_shot(??)
%    computes ...
%
% inputs:
%    paths,
%       input,
%       output,
%    params,
%
%

%
if nargin < 3
    flag_params = 0;
else
    flag_params = 1;
end

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
n_shapes = length(names);
for idx_shape = 1:n_shapes
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    %
    if exist(fullfile(path_output,[name,'.mat']),'file')
        fprintf('[i] shape ''%s'' already processed, skipping\n',name);
        continue;
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,n_shapes);
    time_start = tic;
    
    % load current shape
    tmp   = load(fullfile(path_input,[name,'.mat']));
    shape = tmp.shape;
    
    %
    if flag_params
        desc = compute_shot(shape,params);
    else
        desc = compute_shot(shape);
    end
    
    % saving
    if ~exist(path_output,'dir')
        mkdir(path_output);
    end
    par_save(fullfile(path_output,[name,'.mat']),desc);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path_output,desc)
save(path_output,'desc','-v7.3')
end

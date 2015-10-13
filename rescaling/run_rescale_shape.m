function run_rescale_shape(path_input,path_saving,params)
%
% run_rescale_shape(path_input,path_saving,params)
%    ...
%
% inputs:
%    path_folder, path of the folder containing the files to convert
%    path_saving, 
%    params, str 
%

if nargin < 3
    params.flag_compute_scale_factor = 1;
    params.avoid_geods               = 0;
end

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
for idx_shape = 1:length(names)
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    %
    if exist(fullfile(path_saving,[name,'.mat']),'file');
        fprintf('[i] shape %s already processed, skipping\n',name);
        continue;
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp = load(fullfile(path_input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute scale factor
    if params.flag_compute_scale_factor
        params.scale_factor = compute_scale_factor_to_unit_diam(shape,params);
    end
        
    % rescale shape
    shape = rescale_shape(shape,params.scale_factor);
    
    % saving
    if ~exist(path_saving,'dir')
        mkdir(path_saving);
    end
    par_save(fullfile(path_saving,[name,'.mat']),shape);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,shape)
save(path,'shape','-v7.3')
end

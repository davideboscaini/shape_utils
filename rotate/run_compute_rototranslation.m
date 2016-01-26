function run_compute_rototranslation(paths,params)
%
% run_compute_rototranslation(??)
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
if (isfield(params,'theta') && isfield(params,'idxs') && isfield(params,'signs'))
    flag_params_roto = 1;
else
    flag_params_roto = 0;
end
if isfield(params,'displacement')
    flag_params_trasl = 1;
else
    flag_params_trasl = 0;
end

% dataset instances
tmp = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
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
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp   = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;
    
    %
    if flag_params_roto
        shape = compute_rotation(shape,params_);
    else
        shape = compute_rotation(shape);
    end
    
    if flag_params_trasl
        shape = compute_translation(shape,params_);
    else
        shape = compute_translation(shape);
    end
    
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

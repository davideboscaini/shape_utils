function run_compute_wks(path_input,path_output,params)
%
% run_compute_wks(??)
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
n_desc = params.n_desc;

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
n_shapes = length(names);
parfor idx_shape = 1:n_shapes
    
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
    
    % load current eigen-decomposition
    tmp    = load(fullfile(path_input,[name,'.mat']));
    Phi    = tmp.Phi;
    Lambda = tmp.Lambda;
    
    %
    desc = compute_wks(Phi,Lambda,n_desc);
    
    % saving
    if ~exist(path_output,'dir')
        mkdir(path_output);
    end
    par_save(fullfile(path_output,[name,'.mat']),desc);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,desc)
save(path,'desc','-v7.3')
end

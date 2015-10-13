function run_compute_eigendec(path_input,path_saving,params)

if nargin < 3
    params.k = 100;
    params.shift = 'SM';
end

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
parfor idx_shape = 1:length(names)
    
    % current shape
    name = names{idx_shape}(1:end-4);
    if exist(fullfile(path_saving,[name,'.mat']), 'file')
        fprintf('[i] shape %s already processed, skipping\n', name)
        continue
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load LB operator
    tmp = load(fullfile(path_input,[name,'.mat']));
    W = tmp.W;
    A = tmp.A;
    
    %
    [Phi,Lambda] = eigs(W,A,params.k,params.shift);

    %
    Lambda        = diag(abs(Lambda));
    [Lambda,idxs] = sort(Lambda);
    Phi           = Phi(:,idxs);
    
    % saving
    if ~exist(path_saving,'dir')
        mkdir(path_saving);
    end
    par_save(fullfile(path_saving,[name,'.mat']),Phi,Lambda);
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,Phi,Lambda) 
save(path,'Phi','Lambda','-v7.3');
end

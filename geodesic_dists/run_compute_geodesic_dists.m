function run_compute_geodesic_dists(path_input,path_saving)

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% loop over the dataset instances
parfor idx_shape = 1:length(names)
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load shape
    tmp = load(fullfile(path_input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute geodesic distances
    idxs = [1:length(shape.X)]';
    geods = compute_geodesic_dists(shape,idxs);
    
    % saving
    if ~exist(path_saving,'dir')
        mkdir(path_saving);
    end
    par_save(fullfile(path_saving,[name,'.mat']),geods);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,geods)
save(path,'geods','-v7.3');
end

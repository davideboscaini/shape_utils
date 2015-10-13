function run_compute_lbos(path_input,path_saving)

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
    
    % load current shape
    tmp   = load(fullfile(path_input,[name,'.mat']));
    shape = tmp.shape;
    
    %
    [W,A] = calc_LB(shape);
    
    % saving
    if ~exist(path_saving,'dir')
        mkdir(path_saving);
    end
    par_save(fullfile(path_saving,[name,'.mat']),W,A);
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,W,A)
save(path,'W','A','-v7.3');
end

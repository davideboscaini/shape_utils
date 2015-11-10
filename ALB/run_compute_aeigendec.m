function run_compute_aeigendec(paths,params)

% angle instances
tmp = dir(fullfile(paths.input,sprintf('alpha=%03.0f',params.alpha)));
names_angles = {tmp.name}; clear tmp;
names_angles = setdiff(names_angles,{'.','..'});

% loop over the angle instances
for idx_angle = 1:length(names_angles)
    
    % current angle
    name_angle = names_angles{idx_angle};
    
    % display info
    fprintf('[i] processing angle %3.0f (%3.0d/%3.0d)...\n',str2num(name_angle(end-2:end)),idx_angle,length(names_angles));
    
    % shape instances
    tmp = dir(fullfile(paths.input,sprintf('alpha=%03.0f',params.alpha),name_angle,'*.mat'));
    names_shapes = sortn({tmp.name}); clear tmp;
    
    % loop over the shape instances
    parfor idx_shape = 1:length(names_shapes)
        
        % re-assigning structs variables to avoid parfor errors
        paths_ = paths;
        params_ = params;
        
        % current shape
        name_shape = names_shapes{idx_shape}(1:end-4);
        
        % avoid unnecessary computations
        if exist(fullfile(paths_.output,sprintf('alpha=%03.0f',params_.alpha),sprintf('angle=%03.0f',str2num(name_angle(end-2:end))),[name_shape,'.mat']),'file')
            fprintf('[i] shape %s already processed, skipping\n',name_shape);
            continue;
        end
        
        % display info
        fprintf('[i] \tprocessing shape ''%s'' (%3.0d/%3.0d)... ',name_shape,idx_shape,length(names_shapes));
        time_start = tic;
        
        % load current lbo
        tmp = load(fullfile(paths_.input,sprintf('alpha=%03.0f',params_.alpha),sprintf('angle=%03.0f',str2num(name_angle(end-2:end))),[name_shape,'.mat']));
        W = tmp.W;
        A = tmp.A;
        
        % compute the eigendecomposition
        [Phi,Lambda] = eigs(W,A,params_.k,params_.shift);
        
        % re-order the eigenvectors according to the eigenvalues
        Lambda = diag(abs(Lambda));
        [Lambda,idxs] = sort(Lambda);
        Phi = Phi(:,idxs);
        
        % saving
        paths_.output_ = fullfile(paths_.output,sprintf('alpha=%03.0f',params_.alpha),sprintf('angle=%03.0f',str2num(name_angle(end-2:end))));
        if ~exist(paths_.output_,'dir')
            mkdir(paths_.output_);
        end
        par_save(fullfile(paths_.output_,[name_shape,'.mat']),Phi,Lambda);
        
        % display infos
        fprintf('%2.0fs\n',toc(time_start));
        
    end
    
end

end

function par_save(path,Phi,Lambda)
save(path,'Phi','Lambda','-v7.3');
end

function run_compute_subsampling(path_input,n,path_saving,params)
%
% run_compute_subsampling(path_input,n,path_saving,params)
%    computes ...
%
% inputs:
%    path_folder, path of the folder containing the files to convert
%    n,
%    params,
%

if nargin < 4
    params.vertices  = n;
    params.verbose   = 1;
    params.placement = 0;
    params.penalty   = 1;
    params.preserve_triangulation = 0;
end

% dataset instances
tmp   = dir(fullfile(path_input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

if params.preserve_triangulation
    
    % find shape with minimum number of vertices
    n_verts = zeros(length(names),1);
    for idx_shape = 1:length(names)
        name = names{idx_shape}(1:end-4);
        % load current shape
        tmp   = load(fullfile(path_input,[name,'.mat']));
        shape = tmp.shape;
        n_verts(idx_shape) = length(shape.X);
    end
    [~,idx_shape_min_verts] = min(n_verts);
    
    %
    name_shape_min_verts = names{idx_shape_min_verts}(1:end-4);
    tmp = load(fullfile(path_input,[name_shape_min_verts,'.mat']));
    shape = tmp.shape;
    shape_sub = compute_subsampling(shape,n,params);
    errs = L2_distance([shape_sub.X,shape_sub.Y,shape_sub.Z]',[shape.X,shape.Y,shape.Z]');
    [vals,idxs] = min(errs,[],2);
    %idxs = idxs(vals==0);
    TRIV = shape_sub.TRIV;
    
end

% loop over the dataset instances
for idx_shape = 1:length(names)
    
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
    
    if params.preserve_triangulation
        shape_sub.X    = shape.X(idxs);
        shape_sub.Y    = shape.Y(idxs);
        shape_sub.Z    = shape.Z(idxs);
        shape_sub.TRIV = TRIV;
        shape = shape_sub;
    else
        shape = compute_subsampling(shape,n,params);
    end
    
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

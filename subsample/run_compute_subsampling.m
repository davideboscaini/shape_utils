function run_compute_subsampling(paths,params)
%
% run_compute_subsampling(paths,params)
%    subsamples ...
%
% inputs:
%    paths, 
%    params,
%

if nargin < 2
    params.vertices = 1000;
    params.verbose = 1;
    params.placement = 0;
    params.penalty = 1;
    params.preserve_triangulation = 0;
end

% dataset instances
tmp = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

if params.preserve_triangulation
    
    % find shape with minimum number of vertices
    n_verts = zeros(length(names),1);
    for idx_shape = 1:length(names)
        name = names{idx_shape}(1:end-4);
        % load current shape
        tmp   = load(fullfile(paths.input,[name,'.mat']));
        shape = tmp.shape;
        n_verts(idx_shape) = length(shape.X);
    end
    [~,idx_shape_min_verts] = min(n_verts);
    
    %
    name_shape_min_verts = names{idx_shape_min_verts}(1:end-4);
    tmp = load(fullfile(paths.input,[name_shape_min_verts,'.mat']));
    shape = tmp.shape;
    shape_sub = compute_subsampling(shape,params);
    errs = L2_distance([shape_sub.X,shape_sub.Y,shape_sub.Z]',[shape.X,shape.Y,shape.Z]');
    [vals,idxs] = min(errs,[],2);
    % idxs = idxs(vals==0);
    TRIV = shape_sub.TRIV;
    
end

% loop over the shape instances
for idx_shape = 1:length(names)
    
    % re-assigning structs variables to avoid parfor errors
    paths_ = paths;
    params_ = params;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % avoid unnecessary computations
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape ''%s'' already processed, skipping\n',name);
        continue;
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp = load(fullfile(paths_.input,[name,'.mat']));
    shape = tmp.shape;
    
    % compute the subsampling
    if params_.preserve_triangulation
        shape_sub = struct;
        shape_sub.X = shape.X(idxs);
        shape_sub.Y = shape.Y(idxs);
        shape_sub.Z = shape.Z(idxs);
        shape_sub.TRIV = TRIV;
        shape = shape_sub;
    else
        shape = compute_subsampling(shape,params_);
        %[F_,V_] = reducepatch(shape.TRIV,[shape.X,shape.Y,shape.Z],params_.faces);
        %shape.TRIV = F_;
        %shape.X = V_(:,1);
        %shape.Y = V_(:,2);
        %shape.Z = V_(:,3);
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

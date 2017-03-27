function run_compute_range_map(paths,params)

% dataset instances
tmp   = dir(fullfile(paths.input,'*.mat'));
names = sortn({tmp.name}); clear tmp;

% rotation matrices
R_x = @(theta) [1,0,0; 0,cos(theta),-sin(theta); 0,sin(theta),cos(theta)];
R_y = @(theta) [cos(theta),0,sin(theta); 0,1,0; -sin(theta),0,cos(theta)];
R_z = @(theta) [cos(theta),-sin(theta),0; sin(theta),cos(theta),0; 0,0,1];

% loop over the dataset instances
for idx_shape = 1:length(names)
    
    %
    params_ = params;
    paths_  = paths;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    %
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape %s already processed, skipping\n',name);
        continue;
    end
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load current shape
    tmp   = load(fullfile(paths.input,[name,'.mat']));
    shape_in = tmp.shape;
    
    angles = linspace(0,2*pi,params_.n_angles);
    for idx_angles = 1:length(angles)
        
        % rotate the shape according to the input parameters
        vertices = [shape_in.X-mean(shape_in.X),shape_in.Y-mean(shape_in.Y),shape_in.Z-min(shape_in.Z)];
        vertices = vertices * (params.coeff_x * R_x(angles(idx_angles)) + params.coeff_y * R_y(angles(idx_angles)) + params.coeff_z * R_z(angles(idx_angles)));
        vertices = [vertices(:,1)+mean(vertices(:,1)),vertices(:,2)+mean(vertices(:,2)),vertices(:,3)+min(vertices(:,3))];
        shape_.X = vertices(:,1);
        shape_.Y = vertices(:,2);
        shape_.Z = vertices(:,3);
        shape_.TRIV = shape_in.TRIV;
        
        % compute range maps
        [shape,depth,idxs] = compute_range_map(shape_,params_);
        
        %
        x_factor = min(shape.Z) ./ 999;
        tmp      = shape.Z ./ x_factor;
        shape.Z(find(abs(tmp-999)<1e-06)) = 0; % NaN;
        
        % saving
        if ~exist(paths_.output,'dir')
            mkdir(paths_.output);
        end
        par_save(fullfile(paths_.output,name,sprintf('%s_%03.0f.mat',name,idx_angles)),shape,depth,idxs);
        
    end
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,shape,depth,idxs)
save(path,'shape','depth','idxs','-v7.3');
end

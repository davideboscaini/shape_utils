function run_compute_isc(paths,params)

n_angles = params.n_angles;
n_tvals = params.n_tvals;

% shape instances
names_ = dir(fullfile(paths.input,'*.mat'));
names = sortn({names_.name}); clear names_;

% loop over the shape instances
for idx_shape = 1:length(names)
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % load input desc
    tmp = load(fullfile(paths.input,[name,'.mat']));
    desc_in = tmp.desc; clear tmp;
    
    % load (spectral) patches
    tmp = load(fullfile(paths.patches,[name,'.mat']));
    P = tmp.P; clear tmp;
    
    % compute output desc
    desc_out = cell(n_angles,n_tvals);
    for idx_angle = 1:n_angles
        for idx_tval = 1:n_tvals
            desc_out{idx_angle,idx_tval} = P{idx_angle,idx_tval} * desc_in;
        end
    end
    
    desc = reshape(cell2mat(desc_out),size(desc_in,1),size(desc_in,2)*n_tvals*n_angles);
    % desc = bsxfun(@rdivide,desc,sqrt(sum(desc.^2,2)));
    
    % saving
    if ~exist(paths.output,'dir')
        mkdir(paths.output);
    end
    par_save(fullfile(paths.output,[name,'.mat']),desc);
    
    % display infos
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,desc)
save(path,'desc','-v7.3');
end

% obsolete:
% desc_out = zeros(size(desc_in,1),size(desc_in,2),length(tvals),length(angles));
% for idx_tval = 1:length(tvals)
%     for idx_angle = 1:length(angles)
%         desc_out(:,:,idx_tval,idx_angle) = patches{idx_tval,idx_angle} * desc_in;
%     end
% end

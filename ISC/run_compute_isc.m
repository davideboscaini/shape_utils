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
    
    %desc_in = ones(6890,1);
    
    % load (spectral) patches
    tmp = load(fullfile(paths.patches,[name,'.mat']));
    M = tmp.M; clear tmp;
    
    %
%     desc = M * desc_in;
%     desc = reshape(desc,size(desc_in,2),n_angles,n_tvals,size(desc_in,1));
%     desc = permute(desc,[4,1,3,2]);
    
%     isc = M * desc_in;
%     isc = permute(reshape(isc', size(desc_in,2), n_angles, n_tvals, size(desc_in,1)), [4,1,3,2]);
%     isc = abs(fft(isc, [], 4));
%     isc_all = zeros(size(desc_in,1), n_angles*n_tvals*size(desc_in,2));
%     for j = 1 : N
%         isc_all(j,:) = reshape(isc_(j,:,:,:),1,[]);
%     end
    
    %
    desc = M * desc_in;
    desc = permute(reshape(desc', size(desc_in,2), n_angles, n_tvals, size(desc_in,1)), [4,1,3,2]);
    
    %    
    if params.flag_abs_fft
        desc = abs(fft(desc,[],4));
    end
    
%     tic
%     
%     isc = zeros(size(desc_in,1), n_angles*n_tvals*size(desc_in,2));
%     for j = 1 : size(desc_in,1)
%         isc(j,:) = reshape(desc(j,:,:,:),1,[]);
%     end
%     desc = isc;
%     toc
%     
%     tic
    desc = reshape(desc,size(desc_in,1),size(desc_in,2)*n_tvals*n_angles);
%     toc
    
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

% obsolete
% % compute output desc
% desc_out = cell(n_angles,n_tvals);
% for idx_angle = 1:n_angles
%     for idx_tval = 1:n_tvals
%         desc_out{idx_angle,idx_tval} = P{idx_angle,idx_tval} * desc_in;
%     end
% end
% desc = reshape(cell2mat(desc_out),size(desc_in,1),size(desc_in,2)*n_tvals*n_angles);
% desc = bsxfun(@rdivide,desc,sqrt(sum(desc.^2,2)));

% (very) obsolete:
% desc_out = zeros(size(desc_in,1),size(desc_in,2),length(tvals),length(angles));
% for idx_tval = 1:length(tvals)
%     for idx_angle = 1:length(angles)
%         desc_out(:,:,idx_tval,idx_angle) = patches{idx_tval,idx_angle} * desc_in;
%     end
% end
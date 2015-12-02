function run_compute_icp(names,idxs,paths,params)

% load the target shape data
tmp = load(fullfile(paths.shapes,[names.target,'.mat']));
shapes.target = tmp.shape;
tmp = load(fullfile(paths.lbos,[names.target,'.mat']));
Ws.target = tmp.W;
As.target = tmp.A;
tmp = load(fullfile(paths.eigendec,[names.target,'.mat']));
Phis.target = tmp.Phi(:,1:params.k);
Lambdas.target = tmp.Lambda;
tmp = load(fullfile(paths.geods,[names.target,'.mat']));
geods.target = tmp.geods;

% load the color map
tmp = load(fullfile(paths.cmap,'color_map.mat'));
cmap = tmp.color_map;

% query instances
tmp = importdata(fullfile(paths.names_query,[names.query_input_file,'.txt']),'\n');
names.queries = tmp;

% loop over the shape instances
parfor idx_shape = 1:length(names.queries)
    
    % re-assigning structs variables to avoid parfor errors
    names_ = names;
    paths_ = paths;
    params_ = params;
    shapes_ = shapes;
    Ws_ = Ws;
    As_ = As;
    Phis_ = Phis;
    Lambdas_ = Lambdas;
    geods_ = geods;
    idxs_ = idxs;
    Fs_ = struct;
    
    % current shape
    names_.query = names_.queries{idx_shape}(1:end-4);
    
    if ~params_.flag_recompute
        % avoid unnecessary computations
        if exist(fullfile(paths_.output,[names_.query,'.mat']),'file')
            fprintf('[i] shape ''%s'' already processed, skipping\n',names_.query);
            continue;
        end
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',names_.query,idx_shape,length(names_.queries));
    time_start = tic;
    
    % load the query shape data
    tmp = load(fullfile(paths_.shapes,[names_.query,'.mat']));
    shapes_.query = tmp.shape;
    tmp = load(fullfile(paths_.lbos,[names_.query,'.mat']));
    Ws_.query = tmp.W;
    As_.query = tmp.A;
    tmp = load(fullfile(paths_.eigendec,[names_.query,'.mat']));
    Phis_.query = tmp.Phi(:,1:params_.k);
    Lambdas_.query = tmp.Lambda;
    tmp = load(fullfile(paths_.geods,[names_.query,'.mat']));
    geods_.query = tmp.geods;
    
    n = size(Ws_.query,1);
    
    % load the predictions
    tmp = load(fullfile(paths_.preds,[names_.query,'.mat']));
    pred = tmp.pred;
    [~,idxs_.pred] = max(pred,[],2);
    C = tmp.C;
    
    % show the quality of the predicted correspondence
    params_.color_map = cmap;
    params_.flag_saving = 0;
    plot_corrs(shapes_,names_,idxs_,paths_,params_);
    drawnow;
    
    % prediction accuracy
    accuracy = mean(idxs_.pred==idxs_.gt);
    fprintf('[i] input accuracy: %3.2f\n',accuracy*100);
    
    % 
    [C,idxs_.pred] = compute_icp(Phis_,As_,C,params_);
    pred = sparse(1:n,idxs_.pred,1,n,n);
    
    % show the quality of the refined correspondence
    params_.color_map = cmap;
    params_.flag_saving = 0;
    plot_corrs(shapes_,names_,idxs_,paths_,params_);
    drawnow;
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[names_.query,'.mat']),C,pred);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

end

function par_save(path,C,pred)
save(path,'C','pred','-v7.3')
end

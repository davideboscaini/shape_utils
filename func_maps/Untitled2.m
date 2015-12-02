clear;
close all;
clc;

% names
names.target           = 'tr_reg_000';
names.query_input_file = 'FAUST_registrations_query';
names.preds            = 'iccv';
% idxs
idxs.gt = [1:6890]';
% paths
paths.main        = '\\10.40.0.28\datasets\learning_func_maps_data';
paths.shapes      = fullfile(paths.main,'datasets\FAUST_registrations\meshes\diam=200');
paths.lbos        = fullfile(paths.main,'datasets\FAUST_registrations\data\diam=200\lbos');
paths.eigendec    = fullfile(paths.main,'datasets\FAUST_registrations\data\diam=200\eigendec\k=1000');
paths.geods       = fullfile(paths.main,'datasets\FAUST_registrations\data\diam=200\geods');
paths.cmap        = fullfile(paths.main,'datasets\FAUST_registrations\data');
paths.names_query = fullfile(paths.main,'datasets\FAUST_registrations\data'); 
paths.preds       = fullfile(paths.main,'dumps',names.preds);
% params
params.solver         = 'pinv';
params.k              = 1000;
params.q              = 6890/2;
params.flag_area      = 1;
params.flag_recompute = 1;
% output folder
paths.output = fullfile(paths.main,'corrs',[names.preds,'_func_map'],...
    sprintf('k=%04.0f_q=%04.0f_area=%d_solver=%s',params.k,params.q,params.flag_area,params.solver));

run_compute_func_map(names,idxs,paths,params);

%
% paths
paths.preds = paths.output;
% params
params.max_iters      = 10;
params.tol            = 5e-07;
params.flag_area      = 1;
params.flag_recompute = 1;
params.flag_verbose   = 1;
% output folder
paths.output = fullfile(paths.main,'corrs',[names.preds,'_icp'],...
    sprintf('k=%04.0f_q=%04.0f_area=%d_solver=%s',params.k,params.q,params.flag_area,params.solver));

run_compute_icp(names,idxs,paths,params);

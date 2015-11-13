function run_compute_format_conversion(paths,params)
%
% run_convert_format(paths,params)
%    converts the given shapes to the desired mesh format
%
% inputs:
%    paths, struct containing the following fields
%       input, path to the folder containing the shapes
%       output, path to the folder where to save the converted files
%    params, struct containing the following fields
%       format_in, extension of the file to convert
%       format_out, desired extension of the output file
%

% shape instances
names_ = dir(fullfile(paths.input,['*.',params.format_in]));
names = sortn({names_.name}); clear names_;

% loop over the shape instances
parfor idx_shape = 1:length(names)
    
    % re-assigning structs variables to avoid parfor errors
    paths_ = paths;
    params_ = params;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    if ~params_.flag_recompute
        % avoid unnecessary computations
        if exist(fullfile(paths_.output,[name,'.',params_.format_out]),'file')
            fprintf('[i] shape ''%s'' already processed, skipping\n',name);
            continue;
        end
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % convert format
    compute_format_conversion(name,paths,params)
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end

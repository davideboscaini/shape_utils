function run_compute_format_conversion(path_folder,format_in,format_out)
%
% run_convert_format(name,path_folder,format_in,format_out)
%    converts all the 'format_in' files present in 'path_folder' to 'format_out' ones
%
% inputs:
%    path_folder, path of the folder containing the files to convert
%    format_in,   extension of the files to convert
%    format_out,  desired extension of the output files
%

% dataset instances
names_ = dir(fullfile(path_folder,['*.',format_in]));
names  = sortn({names_.name}); clear names_;

% loop over the dataset instances
for idx_shape = 1:length(names)
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % display infos
    fprintf('[i] processing shape ''%s'' (%3.0d/%3.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % convert format
    convert_format(name,path_folder,format_in,format_out);
    
    % display info
    fprintf('%2.0fs\n',toc(time_start));
    
end



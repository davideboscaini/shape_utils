function compute_format_conversion(name,path_folder,format_in,format_out)
%
% convert_format(name,path_folder,format_in,format_out)
%    converts 'format_in' file in 'path_folder' to 'format_out' ones
%
% inputs:
%    name,        name of the file to convert (without extension)
%    path_folder, path of the folder containing the file to convert
%    format_in,   extension of the file to convert
%    format_out,  desired extension of the output file
%

% read the mesh in input
if strcmp(format_in,'mat')
    tmp      = load(fullfile(path_folder,[name,'.mat']));
    shape    = tmp.shape; clear tmp;
    vertices = [shape.X,shape.Y,shape.Z];
    faces    = shape.TRIV;
elseif strcmp(format_in,'off')
    [vertices_,faces_] = read_off(fullfile(path_folder,[name,'.off']));
    vertices = vertices_'; clear vertices_;
    faces    = faces_'; clear faces_;
elseif strcmp(format_in,'ply')
    [vertices_,faces_] = read_ply(fullfile(path_folder,[name,'.ply']));
    vertices = vertices_'; clear vertices_;
    faces    = faces_'; clear faces_;
elseif strcmp(format_in,'obj')
    [vertices_,faces_] = read_obj(fullfile(path_folder,[name,'.obj']));
    vertices = vertices_'; clear vertices_;
    faces    = faces_'; clear faces_;
else
    error('[e] the input format is not supported');
end

% convert to the mesh in output
if strcmp(format_out,'mat')
    shape.X    = vertices(:,1);
    shape.Y    = vertices(:,2);
    shape.Z    = vertices(:,3);
    shape.TRIV = faces;
    save(fullfile(path_folder,[name,'.mat']),'shape');
elseif strcmp(format_out,'off')
    write_off(fullfile(path_folder,[name,'.off']),vertices,faces);
elseif strcmp(format_out,'ply')
    write_ply(vertices,faces,fullfile(path_folder,[name,'.ply']));
else
    error('[e] the output format is not supported');
end

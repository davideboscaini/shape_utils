function shape_out = compute_rotation(shape_in,params)
%
% shape_out = compute_rotation(shape_in,params)
%    rotates the input shape according to the given parameters
%
% inputs:
%    shape_in, struct containing the following fields 
%       X, Y, Z, shape coordinates 
%       TRIV, triangular mesh connectivity
%    params [optional], struct containing the following fields 
%       theta, rotation angle
%       idxs, in which order to consider the coordinates
%       signs, which sign to assign to the coordinates
%
% output:
%    shape_out
%

if nargin < 2
    theta = 180;
    idxs = [1,3,2];
    signs = [-1,1,1];
else
    theta = params.theta;
    idxs = params.idxs;
    signs = params.signs;
end

R = [cosd(theta),-sind(theta);sind(theta),cosd(theta)];

vertices_in = [shape_in.X,shape_in.Y,shape_in.Z];
vertices_out = [[signs(1)*vertices_in(:,idxs(1)), signs(2)*vertices_in(:,idxs(2))]*R, signs(3)*vertices_in(:,idxs(3))];

shape_out.X = vertices_out(:,1);
shape_out.Y = vertices_out(:,2);
shape_out.Z = vertices_out(:,3);

if isfield(shape_in,'TRIV')
    shape_out.TRIV = shape_in.TRIV;
end

function [shape_out, displacement] = compute_translation(shape_in,params)
%
% shape_out = compute_translation(shape_in,displacement)
%    translates the input shape according to the given parameters
%
% inputs:
%    shape_in, struct containing the following fields 
%       X, Y, Z, shape coordinates 
%       TRIV, triangular mesh connectivity
%    params [optional], struct containing the following field
%       displacement, shift along each coordinate dimensions
%
% output:
%    shape_out
%

if nargin < 2
    displacement = [-mean(shape_in.X),-mean(shape_in.Y),-min(shape_in.Z)];
else
    displacement = params.displacement;
end

shape_out.X = shape_in.X + displacement(1);
shape_out.Y = shape_in.Y + displacement(2);
shape_out.Z = shape_in.Z + displacement(3);

if isfield(shape_in,'TRIV')
    shape_out.TRIV = shape_in.TRIV;
end

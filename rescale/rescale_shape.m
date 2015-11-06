function shape = rescale_shape(shape,scale_factor)
%
% shape = rescale_shape(shape,scale_factor)
%    rescale the input shape by the provided scale factor   
% 
% inputs:
%    shape, struct containing the following fields 
%           X, Y, Z, shape coordinates
%           TRIV, triangular mesh connectivity
%    scale_factor, scalar value
%
% output:
%    shape, rescaled shape
%

vertices = [shape.X,shape.Y,shape.Z];

vertices_mean = mean(vertices,1);
% original version: 
% vertices_mean = mean([...
%     max(shape.X), min(shape.X)
%     max(shape.Y), min(shape.Y)
%     max(shape.Z), min(shape.Z)],2)';

vertices = bsxfun(@minus,vertices,vertices_mean) * scale_factor;
% original version:
% vertices = bsxfun(@minus,vertices,vertices_mean) * scale_factor;
% vertices = bsxfun(@plus,vertices,vertices_mean);

shape.X = vertices(:,1);
shape.Y = vertices(:,2);
shape.Z = vertices(:,3);

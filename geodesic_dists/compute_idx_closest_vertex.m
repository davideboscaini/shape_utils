function idx = compute_idx_closest_vertex(shape,target)
%
% idx = compute_idx_closest_vertex(shape,target)
%    given a point in R^3, computes the index of the closest vertex on the input shape
%
% inputs:
%    shape, struct containing the fields 'X', 'Y', 'Z' and 'TRIV'
%    target, point in R^3
% output:
%    idx, index of the closest vertex to the input point
%

vertices = [shape.X,shape.Y,shape.Z];

[~,idx] = min(sum((vertices - repmat(target,size(vertices,1),1)).^2,2));
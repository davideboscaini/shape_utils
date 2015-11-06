function scale_factor = compute_scale_factor_to_unit_diam(shape,params)
%
% scale_factor = compute_scale_factor_to_unit_diam(shape,params)
%    compute the scale factor to rescale the input shape s.t.
%    its diameter will be 1
%
% inputs:
%    shape, struct containing the following fields
%           X, Y, Z, shape coordinates
%           TRIV, triangular mesh connectivity
%    params, struct containing the following field
%            avoid_geods, if 1 avoids the (computationally expensive)
%                         geodesic distances in favour of Euclidean ones
%
% output:
%    scale_factor, scalar value
%

if nargin < 2
    params.avoid_geods = 0;
end

if params.avoid_geods
    
    vertices = [shape.X,shape.Y,shape.Z];
    bounding_box_diag = norm(min(vertices,[],1) - max(vertices,[],1));
    scale_factor = 1./bounding_box_diag;
    
else
    
    params.q = 10;
    params.flag_dist = 'geod';
    params.flag_random = 1;
    idxs = compute_FPS(shape,params);
    
    params.thresh = 1e+12;
    params.n_dists = params.q;
    geods = compute_geodesic_dists(shape,idxs,params);
    scale_factor = 1./max(geods(:));
    
end

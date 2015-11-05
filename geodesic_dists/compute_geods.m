function geods = compute_geods(shape,idxs,params)
%
% dists = compute_geods(shape,idxs,params)
%    computes the geodesic distances from the selected vertices 
%    of the input shape to the rest of the shape 
%
% inputs:
%    shape, struct containing the following fields 
%           X, Y, Z, shape coordinates 
%           TRIV, triangular mesh connectivity
%    idxs, indices of source vertices from which to compute the distances
%    params, struct containing the following fields
%            thresh, maximum distance value to compute, 
%                    distances greater than thresh will not be computed
%            n_dists, number of distances to compute
% output:
%    geods, geodesic distances from input vertices idxs
%           to the rest of the shape vertices
%

n = size(shape.X,1);

if nargin < 3
    params.thresh = 1e+12;
    params.n_dists = n;
end

f = fastmarchmex('init',int32(shape.TRIV-1),double(shape.X(:)),double(shape.Y(:)),double(shape.Z(:)));

geods = zeros(n,params.n_dists);

for i = 1:params.n_dists

    srcs = Inf(n,1);
    
    if params.n_dists == 1
        srcs(idxs) = 0;
    else
        srcs(idxs(i)) = 0;
    end
    
    geods(:,i) = fastmarchmex('march',f,double(srcs),double(params.thresh));

end

fastmarchmex('deinit',f);

if params.n_dists == n 
    geods = (geods + geods')/2;
end

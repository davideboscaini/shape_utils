function idxs = compute_FPS(shape,params)
%
% idxs = compute_FPS(shape,params)
%    computes the Farthest Point Sampling (FPS) on the input shape
%    according to the desired metric (Euclidean/geodesic)
%
% inputs:
%    shape, struct containing the following fields
%           X, Y, Z, shape coordinates 
%           TRIV, triangle mesh connectivity
%           geods [optional], geodesic distances
%    params, struct containing the following fields
%            q, number of desired samples
%            flag_dist, desired metric
%                         possible choiches: Eucl or geod
%            flag_random, if 1 the sampling starts from a random vertex,
%                         otherwise a random seed is fixed
%
% output:
%    idxs, indices of the farthest vertices on the input shape
%

if ~params.flag_random
    rng(42,'twister');
end

n = size(shape.X,1);
idxs = zeros(params.q,1);
idxs(1) = floor(rand*(n-1))+1;

if strcmp(params.flag_dist,'Eucl')
    dists_Eucl = L2_distance([shape.X,shape.Y,shape.Z]',[shape.X,shape.Y,shape.Z]');
end

for i = 2:params.q
    
    if strcmp(params.flag_dist,'Eucl')
        
        dists = min(dists_Eucl(idxs(idxs~=0),:),[],1);
        
    elseif strcmp(params.flag_dist,'geod')
        
        if isfield(shape,'geods')
            dists = min(shape.geods(idxs(idxs~=0),:),[],1);
        else
            params.thresh = 1e+12;
            params.n_dists = 1;
            dists = compute_geods(shape,idxs(idxs~=0),params);
        end
        
    end
    
    [~,idxs(i)] = max(dists);
    
end

function shape_sub = compute_subsampling(shape,n,params)
%
% shape_sub = compute_subsampling(shape,n,params)
%    computes the subsampling ... 
%
% inputs:
%    shape,
%    n,
%    params,
% output:
%    shape_sub,
%

if nargin < 3
    params.verbose   = 1;
    params.placement = 0;
    params.penalty   = 1;
end    

params.vertices  = n;
[shape_sub.TRIV,shape_sub.X,shape_sub.Y,shape_sub.Z] = remesh(shape,params);
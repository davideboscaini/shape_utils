function shape_out = compute_subsampling(shape_in,params)
%
% shape_out = compute_subsampling(shape_in,n,params)
%    subsample the input shape to the given amount of vertices
%
% inputs:
%    shape_in, original shape
%              struct containing the following fields: 
%              X, Y, Z, shape coordinates (arrays of size |vertices| x 1)
%              TRIV, triangular mesh connectivity (matrix of size |vertices| x 3)
%    
%    params, struct containing the following fields:
%       n, target number of vertices
%       verbose, boolean
%                if 1 (default), display info
%                if 0, otherwise
%       placement, scalar value among 0, 1, 2, 3
%                  if 0 (default), force the subsampling to choose vertices only among the original vertices
%                  if 1, force the subsampling to choose vertices among the original vertices and edge midpoints
%                  if 2, force the subsampling to choose vertices along the original edge
%                  if 3, optimal vertices positioning
%       penalty, boolean
%                if 1 (default), add penalty for bad meshes
%                if 0, otherwise
% output:
%    shape_out, subsampled shape
%               struct containing the following fields:
%               X, Y, Z, shape coordinates (arrays of size |vertices| x 1)
%               TRIV, triangular mesh connectivity (matrix of size |vertices| x 3)
%

if nargin < 2
    params.n         = 1000;
    params.verbose   = 1;
    params.placement = 0;
    params.penalty   = 1;
end    

if strcmp(params.method,'qslim')
    
    if ~isfield(params,'n')
        params.n = 1000;
    end
    if ~isfield(params,'verbose')
        params.verbose   = 1;
    end
    if ~isfield(params,'placement')
        params.placement = 0;
    end
    if ~isfield(params,'penalty')
        params.penalty   = 1;
    end
    [TRIV,X,Y,Z] = remesh(shape_in,params);
    shape_out      = struct;
    shape_out.TRIV = TRIV;
    shape_out.X    = X;
    shape_out.Y    = Y;
    shape_out.Z    = Z;

elseif strcmp(params.method,'matlab')
    
    tmp.vertices     = [shape_in.X,shape_in.Y,shape_in.Z];
    tmp.faces        = shape_in.TRIV;
    [faces,vertices] = reducepatch(tmp,params.n); % floor(params.perc*length(shape_in.X)/100)
    shape_out.TRIV   = faces;
    shape_out.X      = vertices(:,1);
    shape_out.Y      = vertices(:,2);
    shape_out.Z      = vertices(:,3); 
    
end



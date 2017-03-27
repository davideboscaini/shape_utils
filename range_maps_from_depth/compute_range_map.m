function [shape_out,depth,idxs] = compute_range_map(shape_in,params)

S.VERT = [shape_in.X,shape_in.Y,shape_in.Z];
S.TRIV = shape_in.TRIV;

% uncomment the following line to obtain the original code:
% S.VERT = S.VERT - repmat(mean(S.VERT),size(S.VERT,1),1);

S.VERT = S.VERT * [1 0 0; 0 0 -1; 0 1 0];

% current version:
if params.width == 100 && params.height == 180
    shift = 90;
elseif params.width == 480 && params.height == 640
    shift = 100;
else
    shift = 0;
end
S.VERT(:,2) = S.VERT(:,2) - shift;

% uncomment the following line to obtain the original code:
% coef = 20 / range(S.VERT(:,1));

% current version:
if params.width == 100 && params.height == 180
    coef = 0.25;
elseif params.width == 480 && params.height == 640
    coef = 0.18;
else
    coef = 0.25;
end
S.VERT = coef .* S.VERT;

[M,depth,matches] = create_rangemap(S,params.width,params.height);

% uncomment the following line to obtain the original code:
% M.VERT = M.VERT - repmat(mean(M.VERT),M.n,1);

M.VERT = M.VERT ./ coef;

shape.X    = M.VERT(:,1);
shape.Y    = M.VERT(:,2);
shape.Z    = M.VERT(:,3);
shape.TRIV = M.TRIV;

% [w] comment the following four lines to obtain the original code:
% assemble the output shape by proper rescaling and reordering of the coordinates
shape_out.X    =  shape.Y ./ params.scale_factor;
shape_out.Y    =  shape.X ./ params.scale_factor;
shape_out.Z    = -shape.Z ./ params.scale_factor;
shape_out.TRIV =  shape.TRIV;

% groud truth indices
idxs = matches;

function [M,depth,matches] = compute_range_map(shape,params)

S.VERT = [shape.X,shape.Y,shape.Z];
S.TRIV = shape.TRIV;

view_angle = params.view_angle;

S.VERT = S.VERT - repmat(mean(S.VERT),size(S.VERT,1),1);
S.VERT = S.VERT * [1 0 0; 0 0 -1; 0 1 0];
coef = 20 / range(S.VERT(:,1));
S.VERT = coef .* S.VERT;

S.VERT = S.VERT * [cos(view_angle),0,-sin(view_angle);0,1,0;sin(view_angle),0,cos(view_angle)];

[M,depth,matches] = create_rangemap(S,params.width,params.height);

M.VERT = M.VERT - repmat(mean(M.VERT),M.n,1);
M.VERT = M.VERT ./ coef;


function shape_out = add_noise_along_normals(shape_in,params)
%
% shape_in,
%
% params,
%    rho,
%

normals = compute_normal([shape_in.X,shape_in.Y,shape_in.Z],shape_in.TRIV);
normals = normals';

normals = bsxfun(@rdivide,normals,sqrt(sum(normals.^2,2)));

shape_out = struct;
shape_out.X = shape_in.X + params.rho * rand(length(shape_in.X),1) .* normals(:,1);
shape_out.Y = shape_in.Y + params.rho * rand(length(shape_in.Y),1) .* normals(:,2);
shape_out.Z = shape_in.Z + params.rho * rand(length(shape_in.Z),1) .* normals(:,3);
shape_out.TRIV = shape_in.TRIV;
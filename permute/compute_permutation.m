function shape_out = compute_permutation(shape_in)

n = length(shape_in.X);

idxs = randperm(n)';

shape_out = struct;
shape_out.X = zeros(size(shape_in.X));
shape_out.Y = zeros(size(shape_in.Y));
shape_out.Z = zeros(size(shape_in.Z));
tmp = zeros(size(shape_in.TRIV));

for i = 1:length(idxs)
    shape_out.X(idxs(i)) = shape_in.X(i);
    shape_out.Y(idxs(i)) = shape_in.Y(i);
    shape_out.Z(idxs(i)) = shape_in.Z(i);
    tmp(shape_in.TRIV(:,1)==i,1) = idxs(i);
    tmp(shape_in.TRIV(:,2)==i,2) = idxs(i);
    tmp(shape_in.TRIV(:,3)==i,3) = idxs(i);
end
shape_out.TRIV = tmp;

shape_out.idxs = idxs;
function A = compute_1ring_barycentric_area(shape)

vertices = [shape.X,shape.Y,shape.Z];
faces = shape.TRIV;
n = size(vertices,1);
m = size(faces,1);
S_tri = zeros(m,1);
for k=1:m
    e1 = vertices(faces(k,3),:) - vertices(faces(k,1),:);
    e2 = vertices(faces(k,2),:) - vertices(faces(k,1),:);
    S_tri(k) = 0.5*norm(cross(e1,e2));
end
A = zeros(n,1);
for i=1:m
    A(faces(i,1)) = A(faces(i,1)) + S_tri(i)/3;
    A(faces(i,2)) = A(faces(i,2)) + S_tri(i)/3;
    A(faces(i,3)) = A(faces(i,3)) + S_tri(i)/3;
end
A = sparse(1:n,1:n,A);

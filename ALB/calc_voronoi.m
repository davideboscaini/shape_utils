function [A] = calc_voronoi(vertices, faces)
%   compute_Voronoi computes the normalized Voronoi area around each vertex of a 3D
%   shape according to the algorithm described in
%   Discrete Differential-Geometry Operators for Triangulated 2-Manifolds,
%   Mark Meyer, Mathieu Desbrun, Peter Schroeder and Alan H. Barr, VisMath 2002.
%
%   INPUT :
%   vertices is a (number of vertices)*3 matrix
%   faces is a (number of faces)*3 matrix
%
%   OUTPUT .
%   A is a (number of vertices)*1 vector

num_vertices = size(vertices,1);
num_faces = size(faces,1);
angles = 0*faces;
squared_edge_length = 0*faces;

for i=1:3
    i1 = mod(i-1,3)+1;
    i2 = mod(i  ,3)+1;
    i3 = mod(i+1,3)+1;
    pp = vertices(faces(:,i2),:) - vertices(faces(:,i1),:);
    qq = vertices(faces(:,i3),:) - vertices(faces(:,i1),:);
    % normalize the vectors
    pp = pp ./ repmat( max(sqrt(sum(pp.^2,2)),eps), [1 3] );
    qq = qq ./ repmat( max(sqrt(sum(qq.^2,2)),eps), [1 3] );
    % compute angles
    angles(:,i1) = acos(sum(pp.*qq,2));
    squared_edge_length(:,i1) = sum((vertices(faces(:,i2)) - vertices(faces(:,i3))).^2,2);
end

% compute area of triangles
faces_area = zeros(num_faces,1);
for i = 1:3
    faces_area = faces_area + 1/4 * (squared_edge_length(:,i).*1./tan(angles(:,i)));
end

% compute area of Voronoi cells
A = zeros(num_vertices,1);
for j = 1:num_vertices
    for i = 1:3
        i1 = mod(i-1,3)+1;
        i2 = mod(i,3)+1;
        i3 = mod(i+1,3)+1;
        ind_j = find(faces(:,i1) == j);
        for l = 1:size(ind_j,1)
            face_index = ind_j(l);
            if (max(angles(face_index,:)) <= pi/2)
                A(j) = A(j) + 1/8 * (1/tan(angles(face_index,i2))* ...
                    squared_edge_length(face_index,i2) + ...
                    1/tan(angles(face_index,i3))*...
                    squared_edge_length(face_index,i3));
            elseif angles(face_index,i1) > pi/2
                A(j) = A(j) + faces_area(face_index)/2;
            else
                A(j) = A(j) + faces_area(face_index)/4;
            end
        end
    end
end

A = max(A,1e-8);

area = sum(A);
A = A/area;

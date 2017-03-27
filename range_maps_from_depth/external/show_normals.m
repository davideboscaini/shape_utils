function show_normals(S)

e12 = S.VERT(S.TRIV(:,2),:) - S.VERT(S.TRIV(:,1),:);
e13 = S.VERT(S.TRIV(:,3),:) - S.VERT(S.TRIV(:,1),:);
normals = cross(e12,e13);
normals = normals ./ repmat(sqrt(sum(normals.^2,2)), 1, 3);
centroids = (S.VERT(S.TRIV(:,1),:) + S.VERT(S.TRIV(:,2),:) + S.VERT(S.TRIV(:,3),:)) ./ 3;

figure
trisurf(S.TRIV,S.VERT(:,1),S.VERT(:,2),S.VERT(:,3),zeros(size(S.VERT,1),1))
axis equal
hold on
quiver3(centroids(:,1),centroids(:,2),centroids(:,3),normals(:,1),normals(:,2),normals(:,3), 1, 'b')

end

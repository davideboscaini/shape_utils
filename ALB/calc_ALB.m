function [W,A] = calc_ALB(shape,angle,params)

vertices = [shape.X,shape.Y,shape.Z];
faces = shape.TRIV;

n = size(vertices,1);
m = size(faces,1);

% Reorient mesh faces if they are inconsistent

adjacency_matrix = sparse([faces(:,1); faces(:,2); faces(:,3)], ...
    [faces(:,2); faces(:,3); faces(:,1)], ...
    ones(3 * m, 1), ...
    n, n, 3 * m);
if any(any(adjacency_matrix > 1))
    params.method = 'slow';
    warning('Inconsistent face orientation. The mesh will be reoriented.')
    faces = transpose(perform_faces_reorientation(vertices,faces,params));
end
clear adjacency_matrix;

[U1, U2, D] = avg_diffusion_tensor(vertices,faces,params.alpha,params.curv_smooth,angle);

% Construct the (anisotropic) stiffness matrix

W = sparse(n,n);

angles = zeros(size(faces));
for i=1:3
    i1 = mod(i-1,3)+1;
    i2 = mod(i  ,3)+1;
    i3 = mod(i+1,3)+1;
    pp = vertices(faces(:,i2),:) - vertices(faces(:,i1),:);
    qq = vertices(faces(:,i3),:) - vertices(faces(:,i1),:);
    pp = pp ./ repmat( max(sqrt(sum(pp.^2,2)),eps), [1 3] );
    qq = qq ./ repmat( max(sqrt(sum(qq.^2,2)),eps), [1 3] );
    angles(:,i1) = acos(sum(pp.*qq,2));
end

for i=1:3
    i1 = mod(i-1,3)+1;
    i2 = mod(i  ,3)+1;
    i3 = mod(i+1,3)+1;
    % we only focus on (i1,i1) and on (i1,i2)
    e1 = vertices(faces(:,i3),:)-vertices(faces(:,i2),:);
    e2 = vertices(faces(:,i1),:)-vertices(faces(:,i3),:);
    e1 = e1./repmat(sqrt(sum(e1.^2,2)),[1 3]);
    e2 = e2./repmat(sqrt(sum(e2.^2,2)),[1 3]);
    % edge factor
    factore = -(1/2)*(D(:,1).*(sum(e1.*U1(:,:),2)).*(sum(e2.*U1(:,:),2)) +...
        D(:,2).*(sum(e1.*U2(:,:),2)).*(sum(e2.*U2(:,:),2)))...
        ./sin(angles(:,i3));
    % diagonal factor
    factord = -(1/2)*(D(:,1).*(sum(e1.*U1(:,:),2).^2) + ...
        D(:,2).*(sum(e1.*U2(:,:),2).^2)).*(cot(angles(:,i2))+cot(angles(:,i3)));
    W = W + sparse([faces(:,i1); faces(:,i2); faces(:,i1)],...
        [faces(:,i2); faces(:,i1); faces(:,i1)],[factore; factore; factord],...
        n, n);
end

% Construct the mass matrix

A = sparse(1:n, 1:n, calc_voronoi(vertices, faces));
% A = calcVoronoiRegsCircCent (faces,vertices); % modified it in order to have compatible results with calc_LB

end

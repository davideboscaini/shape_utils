function [U1, U2, D] = avg_diffusion_tensor(vertices, faces, alpha, curvature_smoothing, angle)

% Compute curvature
curv_options.curvature_smoothing = curvature_smoothing;
curv_options.verb = 0;
[Umin, Umax, Cmin, Cmax, ~, ~, normals] = compute_curvature(vertices', faces', curv_options);
Umin = Umin';
Umax = Umax';
normals = normals';

% Compute per-face basis in global coordinates (R^3)
% The basis vectors are just the principal curvature directions
[V1, V2] = interpolate_basis(Umin, Umax, normals, faces);

% Rotate the basis by the desired angle
N = cross(V1,V2);
N = N./repmat(sqrt(sum(N.^2,2)), 1, 3);
ca = cos(angle);
sa = sin(angle);
for ii=1:size(N,1)
    u = N(ii,:)';
    Rot = ...
        ca*eye(3) + ...
        sa*[0 -u(3) u(2) ; u(3) 0 -u(1) ; -u(2) u(1) 0] + ...
        (1-ca)*(u*u');
    V1(ii,:) = V1(ii,:)*Rot;
    V2(ii,:) = V2(ii,:)*Rot;
end

% Build per-face basis using triangle edges
edge1 = vertices(faces(:,2),:)-vertices(faces(:,1),:);
edge2 = vertices(faces(:,3),:)-vertices(faces(:,1),:);
edge1 = edge1./repmat(sqrt(sum(edge1.^2,2)),[1 3]);
edge2 = edge2./repmat(sqrt(sum(edge2.^2,2)),[1 3]);
edge2 = edge2 - repmat(sum(edge1.*edge2,2),[1 3]).*edge1;

% Project [V1,V2] onto this basis and orthonormalize them
U1 = repmat(sum(V1.*edge1,2),[1 3]).*edge1 + repmat(sum(V1.*edge2,2),[1 3]).*edge2;
U2 = repmat(sum(V2.*edge1,2),[1 3]).*edge1 + repmat(sum(V2.*edge2,2),[1 3]).*edge2;
U1 = U1./repmat(sqrt(sum(U1.^2,2)),[1 3]);
U2 = U2-repmat(sum(U2.*U1,2),[1 3]).*U1;
U2 = U2./repmat(sqrt(sum(U2.^2,2)),[1 3]);

% Construct 2x2 matrix D
D = zeros(size(faces,1),2);
D(:,1) = (1./(1+alpha));
D(:,2) = 1;

end

% old code:
% function y = psi(x,coef)
%     % according to the NORDIA 2014 paper:
%     y = (1./(1+repmat(coef,size(x)).*abs(x)));
%     % what they instead used:
%     y = (1./(1+repmat(coef,size(x)).*abs(x))).*(x<=0) + (1+repmat(coef,size(x)).*x).*(x>0);
% end
% Cminmean = (1/3)*(Cmin(faces(:,1))+Cmin(faces(:,2))+Cmin(faces(:,3)));
% Cmaxmean = (1/3)*(Cmax(faces(:,1))+Cmax(faces(:,2))+Cmax(faces(:,3)));
% D = zeros(size(faces,1),2);
% D(:,1) = psi(Cminmean,alpha);
% D(:,2) = psi(Cmaxmean,alpha);

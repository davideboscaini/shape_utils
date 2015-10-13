function [W,A] = calc_LB(shape)

% compute the cotangent weigths matrix W
W = calcCotMatrixM1([shape.X, shape.Y, shape.Z], shape.TRIV);

% compute the area terms
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

end

% auxiliary functions
function [M] = calcCotMatrixM1(Vertices, Tri)

N = size(Vertices, 1);
M = sparse(N, N);

v1 = Vertices(Tri(:, 2), :) - Vertices(Tri(:, 1), :); %v1 = v1./repmat(normVec(v1), 1, 3);
v2 = Vertices(Tri(:, 3), :) - Vertices(Tri(:, 1), :); %v2 = v2./repmat(normVec(v2), 1, 3);
v3 = Vertices(Tri(:, 3), :) - Vertices(Tri(:, 2), :); %v3 = v3./repmat(normVec(v3), 1, 3);

% cot1 = dot( v1, v2, 2)./normVec(cross( v1, v2, 2)); %cot1(cot1 < 0) = 0;
% cot2 = dot(-v1, v3, 2)./normVec(cross(-v1, v3, 2)); %cot2(cot2 < 0) = 0;
% cot3 = dot(-v2, -v3, 2)./normVec(cross(-v2, -v3, 2)); %cot3(cot3 < 0) = 0;
tmp1 = dot( v1,  v2, 2); cot1 = tmp1./sqrt(normVec(v1).^2.*normVec(v2).^2 - (tmp1).^2); clear tmp1;
tmp2 = dot(-v1,  v3, 2); cot2 = tmp2./sqrt(normVec(v1).^2.*normVec(v3).^2 - (tmp2).^2); clear tmp2;
tmp3 = dot(-v2, -v3, 2); cot3 = tmp3./sqrt(normVec(v2).^2.*normVec(v3).^2 - (tmp3).^2); clear tmp3;

for k = 1:size(Tri, 1)
    M(Tri(k, 1), Tri(k, 2)) = M(Tri(k, 1), Tri(k, 2)) + cot3(k);
    M(Tri(k, 1), Tri(k, 3)) = M(Tri(k, 1), Tri(k, 3)) + cot2(k);
    M(Tri(k, 2), Tri(k, 3)) = M(Tri(k, 2), Tri(k, 3)) + cot1(k);
end
M = 0.5*(M + M'); % here she does the normalization (comment - Artiom)
    
% inds = sub2ind([N, N], [Tri(:, 2); Tri(:, 1); Tri(:, 1)], [Tri(:, 3); Tri(:, 3); Tri(:, 2)]);
% M(inds) = M(inds) + [cot1; cot2; cot3];
% inds = sub2ind([N, N], [Tri(:, 3); Tri(:, 3); Tri(:, 2)], [Tri(:, 2); Tri(:, 1); Tri(:, 1)]);
% M(inds) = M(inds) + [cot1; cot2; cot3];
% M = 0.5*(M + M');
% % M(M < 0) = 0;

M = M - diag(sum(M, 2)); % making it Laplacian

    function normV = normVec(vec)
        normV = sqrt(sum(vec.^2, 2));
    end
%     function normalV = normalizeVec(vec)
%         normalV = vec./repmat(normVec(vec), 1, 3);
%     end

end


function [Phi,Lambda] = compute_eigendec(W,A,params)

% compute the eigendecomposition
[Phi,Lambda] = eigs(W,A,params.k,params.shift);

% re-order the eigenvectors according to the eigenvalues
Lambda = diag(abs(Lambda));
[Lambda,idxs] = sort(Lambda);
Phi = Phi(:,idxs);
    
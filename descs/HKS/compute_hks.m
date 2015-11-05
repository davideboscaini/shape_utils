function desc = compute_hks(Phi,Lambda,tvals)
%
% desc = compute_hks(shape,params)
%    computes HKS descriptors for the input shape according to the paper
%    "Sun et al., A Concise and Provably Informative Multi-Scale Signature Based on Heat Diffusion, CGF (Proc. SGP), 28(5), pp. 1383-1392, 2009"
%
% inputs:
%    Phi, Laplace-Beltrami eigenvectors 
%         matrix of size n x k, where n is the number of shape vertices and k is the eigenvectors number
%    Lambda, Laplace-Beltrami eigenvalues
%            vector of size k
%    tvals, time values at which compute the heat kernel signatures
%       
% output:
%    desc, heat kernel signature (HKS) descriptor
%

n_vertices = size(Phi,1);
n_desc = length(tvals);
desc = zeros(n_vertices,n_desc);

for idx_tval = 1:length(tvals)
    desc(:,idx_tval) = sum((Phi.^2).*repmat(exp(-tvals(idx_tval)*Lambda(:))',[n_vertices,1]),2);
end

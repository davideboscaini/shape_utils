function desc = compute_wks(Phi,Lambda,n_desc)
%
% desc = compute_wks(shape,params)
%    computes WKS descriptors for the input shape according to the paper
%    "Aubry et al., The wave kernel signature: A quantum mechanical approach to shape analysis, Proc. ICCV, pp. 1626-1633, 2011"
%
% inputs:
%    Phi, Laplace-Beltrami eigenvectors 
%         matrix of size n x k, where n is the number of shape vertices and k is the eigenvectors number
%    Lambda, Laplace-Beltrami eigenvalues
%            vector of size k
%    n_desc, number of wave kernel signature dimensions
%       
% output:
%    desc, wave kernel signature (WKS) descriptor
%

% % official implementation available at "http://www.di.ens.fr/~aubry/code/compute_wks.m"
% n_vertices = size(Phi,1);
% desc       = zeros(n_vertices,n_desc);
% 
% log_Lambda  = log(max(abs(Lambda),1e-6))';
% grid_Lambda = linspace(log_Lambda(2),(max(log_Lambda))/1.02,n_desc);  
% % sigma       = (grid_Lambda(2)-grid_Lambda(1)) * params.variance;
% sigma       = 7 * (max(grid_Lambda)-min(grid_Lambda)) / n_desc;
% 
% C = zeros(1,n_desc); % weights used for the normalization of f_E
% 
% for i = 1:n_desc
%     desc(:,i) = sum(Phi.^2 .* repmat( exp((-(grid_Lambda(i) - log_Lambda).^2) ./ (2*sigma.^2)),n_vertices,1),2);
%     C(i) = sum(exp((-(grid_Lambda(i)-log_Lambda).^2)/(2*sigma.^2)));
% end
% 
% % normalization
% desc(:,:) = desc(:,:)./repmat(C,n_vertices,1);

% Yonathan Pokrass implementation
Lambda     = abs(Lambda);
Lambda_min = log(abs(Lambda(2)));
Lambda_max = log(abs(Lambda(end)));
s          = 7 * (Lambda_max - Lambda_min) / n_desc;
Lambda_min = Lambda_min + 2*s;
Lamdba_max = Lambda_max - 2*s;
tn         = linspace(Lambda_min, Lamdba_max, n_desc);

ce        = sum(exp(-((bsxfun(@minus, log(Lambda(:)), tn(:)')).^2)./(2*s*s)));
ce(ce==0) = 1;
ce        = 1./ce;

tmp     = bsxfun(@minus, log(Lambda(:)), tn(:)');
lognorm = (Phi.^2)*exp(-(tmp.^2)./(2*s*s));

desc = lognorm * diag(ce);
   
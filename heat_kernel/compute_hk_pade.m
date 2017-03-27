function hk = compute_hk_pade(idx,tval,r,W,A)

% convert to partial fraction
% exp(-x) ~ k + sum_i a_i/(x-b_i)
[a,b,k] = compute_hk_pade_coeff(r);

% f = spalloc(size(W,1),length(idx),length(idx));
% for ii = 1:length(idx)
%     f(idx(ii),ii) = 1;
% end
f = sparse(idx,1,1,size(W,1),1);

hk = k*f;
for idx_r = 1:length(a)
    hk = hk + (tval * W + b(idx_r) * A) \ (-a(idx_r) * A * f); 
end
hk = real(hk);
 
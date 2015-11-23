function hk = compute_hk(idx,tval,Phi,Lambda,A)

%hk = Phi * ( diag(exp(-tval.*Lambda))*Phi' );

f = zeros(size(Phi,1),1);
f(idx) = 1;
hk = Phi * diag(exp(-tval*Lambda)) * Phi' * A * f;
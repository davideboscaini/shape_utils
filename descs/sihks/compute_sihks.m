function desc = compute_sihks(Phi,Lambda,params)

tmp = zeros(size(Phi,1),length(params.tvals));

for k = 1:length(params.tvals)
    tmp(:,k) =  - log(params.alpha)*sum(Phi.^2 .* repmat(params.alpha^params.tvals(k)*Lambda(:)'.*exp(-params.alpha^params.tvals(k)*Lambda(:))',[size(Phi,1) 1]),2) ./ ...
        sum(Phi.^2 .* repmat(exp(-params.alpha^params.tvals(k)*Lambda(:))',[size(Phi,1) 1]),2);
end

desc = abs(fft(tmp,[],2));
desc = desc(:,params.omega);

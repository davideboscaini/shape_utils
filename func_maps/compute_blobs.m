function blobs = compute_blobs(shape,idxs,params)

n = length(shape.X);
m = length(idxs);

blobs = zeros(n,m);

for i = 1:m
    
    src = Inf(n,1);
    
    idx = idxs(i);
    src(idx) = 0;

    f = fastmarchmex('init', int32(shape.TRIV-1), double(shape.X(:)), double(shape.Y(:)), double(shape.Z(:)));

    d = fastmarchmex('march', f, double(src));

    fastmarchmex('deinit', f);

    blobs(:,i) = exp(-((d.^2)/(2*params.sigma^2)));
    
end
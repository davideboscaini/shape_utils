function map = redblue_(len, lims)

map = [0.142 0 0.850; 0.097 0.112 0.970; 0.160 0.342 1;...
       0.24 0.531 1; 0.34 0.692 1; 0.46 0.829 1;...
       0.6 0.92 1; 0.74 0.978 1; 0.92 1 1; 1 1 0.92;...
       1 0.948 0.74; 1 0.84 0.6; 1 0.676 0.46; 1 0.472 0.34;...
       1 0.24 0.24; 0.97 0.155 0.21; 0.85 0.085 0.187;...
       0.65 0 0.13];

if nargin < 1
   len = size(get(gcf, 'Colormap'), 1);
end
if isscalar(len)
    if len == Inf
        % Return the concise colormap table
        return
    end
    len = 1:len;
    sz = numel(len);
    lims = [1 sz];
else
    sz = size(len);
    if nargin < 3
        lims = [];
    end
end
map = reshape(real2rgb(len(:), map, lims), [sz 3]);

function patches = compute_aniso_patches_pade(name,angles,tvals,paths,params)
%
% patches = compute_patches(tvals,angles,paths,params)
%    computes the ...
%
% inputs:
%    name,
%    angles,
%    tvals,
%    paths,
%    params,
% outputs:
%    patches, cell of size |tvals| x |angles|
%
% TODO:
%    add abs
%    put 0s instead of the negative values
%

% tabulated coeffs for exp(-x) ~ p_5(x)/q_5(x)
q = [1;...
    7.5017443629508826484e-1;...
    2.6991013134417674897e-1;...
    6.7668626041566587102e-2;...
    6.9346135560032124409e-3;...
    2.3446790106210413736e-3];

p = [1;...
    -2.5023100706418111745e-1;...
    2.2480613306965212876e-2;...
    -8.3363085734239059333e-4;...
    1.0779810679092561383e-5;...
    -2.1912697469186570498e-8];

% convert to partial fraction
% exp(-x) ~ k + sum_i a_i/(x-b_i)
[a,b,k] = residue(p(end:-1:1),q(end:-1:1));

% initialize
patches = cell(length(angles),length(tvals));

% loop over the angles
for idx_angle = 1:length(angles)
    
    % current angle
    angle = angles(idx_angle);
    
    tmp = load(fullfile(paths.albo,sprintf('alpha=%03.0f',params.alpha),sprintf('angle=%03.0f',rad2deg(angle)),[name,'.mat']));
    W = tmp.W;
    A = tmp.A;
    
    % load anisotropic Laplace-Beltrami operator
    tmp = load(fullfile(paths.eigendec,sprintf('alpha=%03.0f',params.alpha),sprintf('angle=%03.0f',rad2deg(angle)),[name,'.mat']));
    Phi = tmp.Phi;
    Lambda = tmp.Lambda;
    
    % loop over the time values
    for idx_tval = 1:length(tvals)
        
        tval = tvals(idx_tval);
        
        % compute anisotropic heat kernel
        % patches_ = Phi * ( diag(exp(-tval.*Lambda))*Phi' );
        
        %         patches_ = cell(size(Phi,1),1);
        %         parfor idx_vertex = 1:size(Phi,1)
        %             f = zeros(size(Phi,1),1);
        %             f(idx_vertex) = 1;
        %             g = k * f;
        %             for r = 1:length(a)
        %                 g = g + (tval * W + b(r) * A) \ (-a(r) * A * f);
        %             end
        %             g = real(g);
        %             patches_{idx_vertex} = g;
        %         end
        %         patches_ = reshape(cat(1,patches_{:}),size(Phi,1),size(Phi,1));
        
        patches_ = k*ones(size(W));
        for r = 1:length(a)
            patches_ = patches_ + (tval*W+b(r)*A) \ (-a(r)*A);
        end
        patches_ = real(patches_);
        
        % normalize each (directional) kernel in order to have unit norm
        if params.flag_unit_norm
            patches_ = bsxfun(@rdivide,patches_,sqrt(sum(patches_.^2,2)));
        end
        
        % threshold (enforce sparsity)
        if params.thresh > 0
            mask = bsxfun(@gt,patches_,prctile(patches_,params.thresh,2));
            patches_ = (patches_ .* mask);
        end
        
        % normalize each (directional) kernel in the range [0,1]
        if params.flag_between_0_and_1
            patches_ = bsxfun(@minus,patches_,min(patches_,[],2));
            patches_ = bsxfun(@rdivide,patches_,max(patches_,[],2));
        end
        
        % store in the data structure
        patches{idx_angle,idx_tval} = patches_;
        
        % % slower code:
        % [I,J] = ind2sub([size(Phi,1),size(Phi,1)],find(mask));
        % V = patches_(mask);
        % patches{idx_angle,idx_tval} = sparse(J,I,V,size(Phi,1),size(Phi,1));
        
    end
    
end

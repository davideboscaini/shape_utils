function patches = compute_patches(name,angles,tvals,paths,params)
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

% initialize
patches = cell(length(angles),length(tvals));

% loop over the angles
for idx_angle = 1:length(angles)
    
    % current angle
    angle = angles(idx_angle);
    
    % load anisotropic Laplace-Beltrami operator
    tmp = load(fullfile(paths.eigendec,sprintf('alpha=%03.0f',params.alpha),sprintf('angle=%03.0f',(180/pi) * angle),[name,'.mat']));
    Phi = tmp.Phi;
    Lambda = tmp.Lambda;
    
    % loop over the time values
    for idx_tval = 1:length(tvals)
        
        tval = tvals(idx_tval);
        
        % compute anisotropic heat kernel
        patches_ = Phi * ( diag(exp(-tval.*Lambda))*Phi' );
        
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

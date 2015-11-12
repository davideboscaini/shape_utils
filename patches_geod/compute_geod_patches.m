function M = compute_geod_patches(name,paths,params)

% parameters
rad       = params.rad; % radius used for descriptor construction
flag_dist = params.flag_dist;
nbinsr    = params.nbinsr; 
nbinsth   = params.nbinsth;
fhs       = params.fhs;
fha       = params.fha;

rr        = [1:nbinsr]/nbinsr*rad;
th        = [1:nbinsth]/nbinsth*2*pi;

tmp = load(fullfile(paths.input,[name,'.mat']));
shape = tmp.shape;

% compute the nearest-neighbors
%fprintf('[i] computing nearest-neighbor... ');
%start_time = tic;
shape.idxs = compute_vertex_face_ring(shape.TRIV');
%fprintf('%3.0fs\n',toc(start_time));

% loading the geodesic distances
%fprintf('[i] loading geodesic distances directly from shape... ');
%start_time = tic;
tmp = load(fullfile(paths.geods,[name,'.mat']));
geods = tmp.geods;
dists = geods;
%fprintf('%3.0fs\n',toc(start_time));

tmp = load(fullfile(paths.lbo,[name,'.mat']));
A = tmp.A;

tmp = load(fullfile(paths.desc,[name,'.mat']));
desc = tmp.desc;
%[desc,shape] = signature(shape,'wks');

% compute geodesic patch for each vertex
M = cell(size(shape.X,1),1);
fprintf('[i] computing geodesic patch...');
start_time = tic;
bad_disks = 0;

for i = 1:size(shape.X,1)
    
    %if mod(i,100) == 0
    %   fprintf('    %d/%d %2.0fs\n',i,size(shape.X,1),toc(start_time));
    %end
    
    %fprintf('%f\n',max(geods(i,:)));
    
    %
    shape.D = geods(i,:)';
    
    
    % make an empty disk in case it fails
    try
        [in_ray,in_ring,shape,geod,directions,ds] = ...
            compute_disk(shape,i,dists,flag_dist,'scales',[0,rr],'N_rays',length(th),'fhs',fhs,'fha',fha);

        % compute descriptor on disk
        areascaling = full(diag(A)); 
        [desc_net_,M_] = get_descriptor_from_net(in_ray,in_ring,desc,areascaling); 
    
        % sanity check with ISC
        % shuffle dimensions so that fastest index corresponds 
        % to bins and then to rings
        desc_net_shuffled = permute(desc_net_, [1,3,2]);
        desc_net = M_ * desc;
        if norm(reshape(desc_net_shuffled,size(desc,2),nbinsr*nbinsth)' - desc_net) > 1e-04
            error('[e] descriptors not matching');
        end
        
    catch
        
        warning('[w] something went wrong, making an empty disk...')
        M_ = sparse(zeros(80,size(shape.X,1)));
        bad_disks = bad_disks + 1;
        
    end
    
    M{i} = M_;
    clear M_;
    
end
fprintf('%3.0fs\n',toc(start_time));

% display info
fprintf('[i] number of bad disks: %i\n',bad_disks);

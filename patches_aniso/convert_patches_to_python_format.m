function patch_out = convert_patches_to_python_format(patch_in)

n_angles = size(patch_in,1);
n_tvals = size(patch_in,2);
n = size(patch_in{1,1},2);

patch_out = cat(1,patch_in{:});
patch_out = reshape(patch_out,n,n_angles,n_tvals,n);
patch_out = reshape(patch_out,n,n_angles*n_tvals*n)';

patch_out = permute(reshape(patch_out,n_angles*n_tvals,n,n),[1,3,2]);
patch_out = reshape(patch_out,n_angles*n_tvals*n,n,[]);

% obsolete:
% patch_out = zeros(n*n_angles*n_tvals,n);
% count = 1;
% for i = 1:n
%     % fprintf('vertex %04.0f (%2.0f%)... ',i,double(i/n));
%     % time_start = tic;
%     for idx_tval = 1:n_tvals
%         for idx_angle = 1:n_angles
%             patch_out(count,:) = patch_in{idx_angle,idx_tval}(i,:);
%             count = count + 1;
%         end
%     end
%     % fprintf('%3.2f\n',toc(time_start));
% end
% for idx_tval = 1:n_tvals
%     for idx_angle = 1:n_angles
%         P{idx_angle,idx_tval} = single(full(patch_in{idx_angle,idx_tval}));
%     end
% end

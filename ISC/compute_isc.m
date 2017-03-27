function desc = compute_isc(M,desc_in,n_angles, n_tvals,flag_abs_fft)

desc = M * desc_in;
desc = permute(reshape(desc', size(desc_in,2), n_angles, n_tvals, size(desc_in,1)), [4,1,3,2]);    
if flag_abs_fft
    desc = abs(fft(desc,[],4));
end
desc = reshape(desc,size(desc_in,1),size(desc_in,2)*n_tvals*n_angles);


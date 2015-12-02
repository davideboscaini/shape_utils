function C = compute_func_map(Phis,As,Fs,params)
%
% all the inputs are structs containing the follwing fields
%    query, 
%    target,
%
% C PhiX' AX FX = PhiY' AY FY
% FX' AX PhiX C' = FY' AY PhiY
% C = ( (FX' AX PhiX) \ (FY' AY PhiY) )'
% T = PhiY C PhiX' AX
%

Phis.query = Phis.query(:,1:params.k);
Phis.target = Phis.target(:,1:params.k);

if params.flag_area
    L = Fs.query' * As.query * Phis.query;
    R = Fs.target' * As.target * Phis.target; 
else
    L = Fs.query' * Phis.query;
    R = Fs.target' * Phis.target;
end

if strcmp(params.solver,'backslash')
    C = L \ R;
elseif strcmp(params.solver,'pinv')
    C = pinv(L) * R;
end

C = C';


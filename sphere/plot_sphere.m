function plot_sphere(center,params)

if nargin < 2
    params = struct;
end
if ~isfield(params,'refine')
    params.refine = 2;
end
if ~isfield(params,'radius')
    params.radius = 1;
end
if ~isfield(params,'rgb')
    params.rgb = [0,0,0];
end

tmp = sphere_tri('ico',params.refine,params.radius);

sphere.X    = tmp.vertices(:,1) + center(1);
sphere.Y    = tmp.vertices(:,2) + center(2);
sphere.Z    = tmp.vertices(:,3) + center(3);
sphere.TRIV = tmp.faces;

trisurf(sphere.TRIV,sphere.X,sphere.Y,sphere.Z,'facecolor',params.rgb,'edgecolor','none');

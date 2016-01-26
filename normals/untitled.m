clear;
close all;
clc;

tmp = load('/media/nas/learning_func_maps_data/datasets/FAUST_registrations/meshes/diam=001_keepdim/tr_reg_000.mat');
shape = tmp.shape;

rho = 0.005;

[normals,face_normals] = compute_normal([shape.X,shape.Y,shape.Z],shape.TRIV);
normals = normals';
face_normals = face_normals';

normals = bsxfun(@rdivide,normals,sqrt(sum(normals.^2,2)));

% normals = rho .* normals;
% 
% idxs = randi(length(shape.X),100);
% 
% figure;
% plot_shape(shape);
% hold on;
% for i = 1:length(idxs)
%     quiver3(shape.X(idxs(i)),shape.Y(idxs(i)),shape.Z(idxs(i)),...
%         normals(idxs(i),1),normals(idxs(i),2),normals(idxs(i),3),...
%         'autoscale','off','maxheadsize',1,'color',[0,0,0],'linewidth',1.5);
% end
% hold off;
% drawnow;

%
shape.X = shape.X + rho*rand(length(shape.X),1).*normals(:,1);
shape.Y = shape.Y + rho*rand(length(shape.Y),1).*normals(:,2);
shape.Z = shape.Z + rho*rand(length(shape.Z),1).*normals(:,3);

figure;
plot_shape(shape);
shading faceted;



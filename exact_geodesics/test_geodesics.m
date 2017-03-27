%%
clear all
clc, close all

addpath('./geodesic/')

global geodesic_library;
geodesic_library = 'geodesic';

method = 'exact'; % 'exact' or 'dijkstra'

M = load_off('./hedgehog.off');

% initialize
mesh = geodesic_new_mesh(M.VERT, M.TRIV);
algorithm = geodesic_new_algorithm(mesh, method);

src_id = 1;
source_points = {geodesic_create_surface_point('vertex',src_id,M.VERT(src_id,:))};

% propagate from source to all points (this is the slow part)
geodesic_propagate(algorithm, source_points);

% compute distance to all points
[source_id, distances] = geodesic_distance_and_source(algorithm);

% compute exact geodesic path to a vertex
dest_id = M.n;
destination = geodesic_create_surface_point('vertex',dest_id,M.VERT(dest_id,:));
path = geodesic_trace_back(algorithm, destination);

geodesic_delete;

%

figure, colormap(jet)
plot_scalar_map(M, distances), daspect([1 1 1]), shading faceted
axis off

hold on;
plot3(source_points{1}.x, source_points{1}.y, source_points{1}.z, '.r', 'MarkerSize',10);
plot3(destination.x, destination.y, destination.z, '.k', 'MarkerSize',10);

[x,y,z] = extract_coordinates_from_path(path);
h = plot3(x*1.001,y*1.001,z*1.001,'k-','LineWidth',2);

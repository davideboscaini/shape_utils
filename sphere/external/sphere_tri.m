function [FV] = sphere_tri(shape,maxlevel,r)

% SPHERE_TRI - generate a triangle mesh approximating a sphere
% 
% The function uses recursive subdivision.  The first
% approximation is an platonic solid, either an  icosahedron,
% octahedron or a tetrahedron.  Each level of refinement 
% subdivides each triangle face by a factor of 4 (see also 
% MESH_REFINE).  At each refinement, the vertices are 
% projected to the sphere surface (see SPHERE_PROJECT).
% 
% A recursion level of 3 or 4 is a good sphere surface, if
% gouraud shading is used for rendering.
% 
% Usage: FV = sphere_tri(shape,Nrecurse,r)
% 
%   shape is a string, either of the following:
%   'ico'   starts with icosahedron (most even, default)
%   'oct'   starts with octahedron
%   'tetra' starts with tetrahedron (least even)
%
%   Nrecurse is int >= 1, setting the recursions (default 1)
%
%   r is the radius of the sphere (default 1)
%
%   FV has fields FV.vertices and FV.faces.  The vertices 
%   should be triangulated in clockwise order, as viewed 
%   from the outside in a RHS coordinate system.
% 
% The returned struct can be used in the patch command, eg:
% 
% % create and plot, vertices: [2562x3] and faces: [5120x3]
% FV = sphere_tri('ico',4,1);
% lighting phong; shading interp; figure;
% patch('vertices',FV.vertices,'faces',FV.faces,...
%       'facecolor',[1 0 0],'edgecolor',[.2 .2 .6]);
% axis off; camlight infinite; camproj('perspective');
% 
% See also: MESH_REFINE, SPHERE_PROJECT


if ~exist('shape','var'),
    shape = 'ico';
elseif isempty(shape),
    shape = 'ico';
end

% uncomment the following line to increase verbosity
% fprintf('...creating sphere tesselation based on %s\n',shape);

shape = lower(shape);

switch shape,
case 'tetra',
    
    % Vertices of a tetrahedron
    sqrt_3 = 0.5773502692;
    
    tetra.v = [  sqrt_3,  sqrt_3,  sqrt_3 ;   % +X, +Y, +Z  - PPP
                -sqrt_3, -sqrt_3,  sqrt_3 ;   % -X, -Y, +Z  - MMP
                -sqrt_3,  sqrt_3, -sqrt_3 ;   % -X, +Y, -Z  - MPM
                 sqrt_3, -sqrt_3, -sqrt_3 ];  % +X, -Y, -Z  - PMM
	
    % Structure describing a tetrahedron
    tetra.f = [ 1, 2, 3;
                1, 4, 2;
                3, 2, 4;
                4, 1, 3 ];
    
    FV.vertices = tetra.v;
    FV.faces    = tetra.f;
    
case 'oct',
    
    % Six equidistant points lying on the unit sphere
    oct.v = [  1,  0,  0 ;  %  X
              -1,  0,  0 ; 	% -X
               0,  1,  0 ;  %  Y
               0, -1,  0 ; 	% -Y
               0,  0,  1 ; 	%  Z
               0,  0, -1 ];	% -Z
	
    % Join vertices to create a unit octahedron
    oct.f = [ 1 5 3 ;    %  X  Z  Y  -  First the top half
              3 5 2 ;    %  Y  Z -X
              2 5 4 ;    % -X  Z -Y
              4 5 1 ;    % -Y  Z  X
              1 3 6 ;    %  X  Y -Z  -  Now the bottom half
              3 2 6 ;    %  Y  Z -Z
              2 4 6 ;    % -X  Z -Z
              4 1 6 ];   % -Y  Z -Z
    
    FV.vertices = oct.v;
    FV.faces    = oct.f;
    
case 'ico',
    
    % Twelve vertices of icosahedron on unit sphere
    tau = 0.8506508084; % t=(1+sqrt(5))/2, tau=t/sqrt(1+t^2)
    one = 0.5257311121; % one=1/sqrt(1+t^2) , unit sphere
    
    ico.v( 1,:) = [  tau,  one,    0 ]; % ZA
    ico.v( 2,:) = [ -tau,  one,    0 ]; % ZB
    ico.v( 3,:) = [ -tau, -one,    0 ]; % ZC
    ico.v( 4,:) = [  tau, -one,    0 ]; % ZD
    ico.v( 5,:) = [  one,   0 ,  tau ]; % YA
    ico.v( 6,:) = [  one,   0 , -tau ]; % YB
    ico.v( 7,:) = [ -one,   0 , -tau ]; % YC
    ico.v( 8,:) = [ -one,   0 ,  tau ]; % YD
    ico.v( 9,:) = [   0 ,  tau,  one ]; % XA
    ico.v(10,:) = [   0 , -tau,  one ]; % XB
    ico.v(11,:) = [   0 , -tau, -one ]; % XC
    ico.v(12,:) = [   0 ,  tau, -one ]; % XD
    
    % Structure for unit icosahedron
    ico.f = [  5,  9,  8 ;
               5,  8, 10 ;
               6,  7, 12 ;
               6, 11,  7 ;
               1,  5,  4 ;
               1,  4,  6 ;
               3,  8,  2 ;
               3,  2,  7 ;
               9,  1, 12 ;
               9, 12,  2 ;
              10, 11,  4 ;
              10,  3, 11 ;
               9,  5,  1 ;
              12,  1,  6 ;
               5, 10,  4 ;
               6,  4, 11 ;
               8,  9,  2 ;
               7,  2, 12 ;
               8,  3, 10 ;
               7, 11,  3 ];
	
    FV.vertices = ico.v;
    FV.faces    = ico.f;
end


% default maximum subdivision level
if ~exist('maxlevel','var'),
    maxlevel = 1;
elseif maxlevel <= 0,
    maxlevel = 1;
end

% default radius
if ~exist('r','var'), r = 1; end

% Subdivide each starting triangle (maxlevel) times
for level = 1:maxlevel,
    
    % Subdivide each triangle and normalize the new points thus
    % generated to lie on the surface of a sphere radius r.
    FV = mesh_refine_tri4(FV);
    FV.vertices = sphere_project(FV.vertices,r);
    
    % An alternative might be to define a min distance
    % between vertices and recurse or use fminsearch
    
end

return

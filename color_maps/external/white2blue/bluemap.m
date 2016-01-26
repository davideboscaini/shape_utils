% @author Jonathan Pokrass
function [map] = bluemap(varargin) 
  map = [1 1 1; 0.5 0.5 0.5; 0 0 1];
  map = colormap_helper(map, varargin{:});
end
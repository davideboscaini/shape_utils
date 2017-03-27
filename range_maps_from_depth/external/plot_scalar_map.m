function plot_scalar_map(N, f)
    trisurf(N.TRIV,N.VERT(:,1),N.VERT(:,2),N.VERT(:,3),f)
    axis equal, shading interp
end

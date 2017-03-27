function demo_rangemaps_from_shape(full_model)

%full_model.X = full_model.VERT(:,1);
%full_model.Y = full_model.VERT(:,2);
%full_model.Z = full_model.VERT(:,3);

full_model = compute_rotation(full_model);
full_model = compute_translation(full_model);

full_model.VERT = [full_model.X full_model.Y full_model.Z];
full_model.n = size(full_model.VERT,1);
full_model.m = size(full_model.TRIV,1);

full_model.S_tri = calc_tri_areas(full_model);

figure
colors = create_colormap(full_model,full_model);
colormap(colors)
subplot(1,2,1), plot_scalar_map(full_model, 1:full_model.n), axis off; view([0 0]); shading faceted
subplot(1,2,2), plot_scalar_map(full_model, 1:full_model.n), axis off; view([0 0]); rotate3d

for a=linspace(0,2*pi,10)
    
    % ---------------------------------------------------------------------
    % Do not just call create_rangemap() on the FAUST model. Use the
    % following code instead.
    % ---------------------------------------------------------------------
    S = full_model;
    S.VERT = S.VERT - repmat(mean(S.VERT),S.n,1);
    S.VERT = S.VERT * [1 0 0 ; 0 0 -1 ; 0 1 0];
    coef = 20 / range(S.VERT(:,1));
    S.VERT = coef.*S.VERT;
    
    S.VERT = S.VERT * [cos(a) 0 -sin(a) ; 0 1 0 ; sin(a) 0 cos(a)];
    
    [M, depth, matches] = create_rangemap_from_shape(S, 100, 170);
    M.gt = matches;
    
    M.VERT = M.VERT - repmat(mean(M.VERT),M.n,1);
    M.VERT = M.VERT ./ coef;
    % ---------------------------------------------------------------------
    
    figure, imagesc(depth), axis equal, colormap(gray), colorbar, title(sprintf('angle %.4f',a))
        
    figure
    N2 = S; N2.VERT = full_model.VERT(matches,:);
    colors = create_colormap(N2,full_model);
    colormap(colors)
    subplot(1,2,1), plot_scalar_map(M, 1:M.n), axis off; view([90 -90]); shading faceted
    subplot(1,2,2), plot_scalar_map(M, 1:M.n), axis off; view([90 -90]); rotate3d
    
end

% NOTE: make sure the normal fields on full shape and rangemap point in the same directions:
show_normals(full_model)
show_normals(M)

function plot_shape(shape,varargin)
%
% plot_shape(shape,func,params)
%    plots the input shape
% input:
%    shape, shape in input
%    func, function defined on the shape
%    params,
%       flag_newfig,
%       flag_shading,
%       view_angle,
%       flag_isolines,
%       n_isolines,
%       n_rows,
%       flag_antialiasing,    
%

if nargin == 1
    func = [];
    params.flag_newfig = 0;
    params.flag_shading = 1;
	params.view_angle = [0,0];
	params.flag_isolines = 0;
    params.n_isolines = 0;
    params.n_rows = 1;
	params.flag_antialiasing = 0; 
elseif nargin == 2
    func = varargin{1};
    params.flag_newfig = 0;
    params.flag_shading = 1;
	params.view_angle = [0,0];
	params.flag_isolines = 0;
    params.n_isolines = 0;
    params.n_rows = 1;
	params.flag_antialiasing = 0;  
elseif nargin == 3
    func = varargin{1};
    params = varargin{2};
else
    error('[e] too many input arguments.');
end

if params.flag_newfig
    figure;
end

if isempty(func)
    
    trisurf(shape.TRIV,shape.X,shape.Y,shape.Z);
    camoscio = [240,220,130]./255;
    colormap(camoscio);
    axis image;
    view(params.view_angle);
    if params.flag_shading
        shading interp;
        lighting phong;
        camlight;
    end
    set(gcf,'color',[1,1,1]);
    set(gca,'visible','off');
    freezeColors;
    
else
    
    if size(func,2)>size(func,1)
        func = func';
    end
    
    if (size(func,2)==1)
        
        colormap('default');
        if params.flag_isolines
            % colormap(jet(n_isolines));
            trisurf(shape.TRIV,shape.X,shape.Y,shape.Z,'CData',func,'FaceColor','interp','FaceLighting','phong','EdgeColor','none');
            axis image;
            axis off;
            [LS,LD,I] = isolines([shape.X,shape.Y,shape.Z],shape.TRIV,func,linspace(min(func),max(func),n_isolines+1));
            hold on;
            plot3([LS(:,1) LD(:,1)]',[LS(:,2) LD(:,2)]',[LS(:,3) LD(:,3)]','k','LineWidth',2);
            hold off;
        else
            trisurf(shape.TRIV,shape.X,shape.Y,shape.Z,func);
        end
        % caxis( [-max(abs(err)), max(abs(err))] );
        % colormap(bluewhitered(256));
        % colormap(b2r(-max(abs(err)),max(abs(err))));
        % colorbar;
        axis image;
        view(params.view_angle);
        if params.flag_shading
            shading interp;
            lighting phong;
            camlight;
        end
        set(gcf,'color',[1,1,1]);
        set(gca,'visible','off');
        
    else % size(func,2)>1
        
        colormap('default');
        for i = 1:size(func,2)
            subplot(params.n_rows,ceil(size(func,2)/params.n_rows),i);
            if params.flag_isolines
                % colormap(jet(n_isolines));
                trisurf(shape.TRIV,shape.X,shape.Y,shape.Z,'CData',func(:,i),'FaceColor','interp','FaceLighting','phong','EdgeColor','none');
                axis image;
                axis off;
                [LS,LD,I] = isolines([shape.X,shape.Y,shape.Z],shape.TRIV,func(:,i),linspace(min(func(:,i)),max(func(:,i)),n_isolines+1));
                hold on;
                plot3([LS(:,1) LD(:,1)]',[LS(:,2) LD(:,2)]',[LS(:,3) LD(:,3)]','k','LineWidth',2);
                hold off;
            else
                trisurf(shape.TRIV,shape.X,shape.Y,shape.Z,func(:,i));
            end
            % caxis( [-max(abs(err(:,i))), max(abs(err(:,i)))] );
            % colormap(bluewhitered(256));
            % colormap(b2r(-max(abs(err(:,i))), max(abs(err(:,i)))));
            % colorbar;
            axis image;
            view(params.view_angle);
            if params.flag_shading
                shading interp;
                lighting phong;
                camlight;
            end
            set(gcf, 'Color', [1,1,1]);
            set(gca, 'visible', 'off');

        end
        
    end
    
end

% anti-aliasing
if params.flag_antialiasing
    myaa('publish');
end

function plot_shape(shape,varargin)
%
% plot_shape(shape,func,params)
%    plots the input shape
%
% input:
%    shape, input shape
%    func, scalar function/functions on the shape
%    params, struct containing the following fields
%       flag_newfig, if 1 open a new figure
%       flag_shading, if 1 turn on the shading
%       view_angle, specify the viewpoint as [azimuth,elevation]
%       flag_isolines, if 1 shows the isolines of the input function on the shape
%       n_isolines, specify how many isolines to plot
%       n_rows, in case of more than one function in input, specify the number of rows for the subplot
%       flag_antialiasing, if 1 the antialiasing is considered for the rendering 
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
    if ~isfield(params,'flag_newfig')
        params.flag_newfig = 0;
    end
    if ~isfield(params,'flag_shading')
        params.flag_shading = 1;
    end
    if ~isfield(params,'view_angle')
        params.view_angle = [0,0];
    end
    if ~isfield(params,'flag_isolines')
        params.flag_isolines = 0;
    end
    if ~isfield(params,'n_isolines')
        params.n_isolines = 0;
    end
    if ~isfield(params,'n_rows')
        params.n_rows = 1;
    end
    if ~isfield(params,'flag_antialiasing')
        params.flag_antialiasing = 0;
    end
    
else
    error('[e] too many input arguments');
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
    set(gcf,'color','white');
    set(gca,'visible','off');
    freezeColors;
    
else
    
    func = full(func);
    
    if size(func,2) > size(func,1)
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
        % colormap(redblue(256));
        % colormap(b2r(-max(abs(err)),max(abs(err))));
        % colorbar;
        axis image;
        view(params.view_angle);
        if params.flag_shading
            shading interp;
            lighting phong;
            camlight;
        end
        set(gcf,'color','white');
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

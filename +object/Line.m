classdef Line < object.Graphics3DObj
% Constructor
methods
    function obj = Line(varargin)
        p = inputParser;
        p.addOptional('pts', [], @(x) validateattributes(x, {'numeric'}, {'ncols', 3}));
        p.parse(varargin{:});

        obj.vtx = p.Results.pts;
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        vtx = obj.getWorldVtx();
        v_num = size(vtx, 1);
        args = cat(2, obj.material.getDrawArgs(), varargin);
        
        next_plot = get(gca, 'NextPlot');
        hold on;
        
        % Set point scale
        sphere_scale = -1;
        for i = 1:2:length(args)
            if strcmpi(args{i}, 'PointScale')
                sphere_scale = args{i+1};
            end
        end
        if sphere_scale > 0
            % Draw points
            surf_args = object.Graphics3DObj.filterArgs(args, {'PointScale'}, {'^Line'});
            for i = 1:length(surf_args)
                if strcmpi(surf_args{i}, 'Color')
                    surf_args{i} = 'FaceColor';
                end
            end
            [xx0, yy0, zz0] = sphere;
            [r, c] = size(xx0);
            xx = nan(v_num * (r + 1), c);
            yy = nan(v_num * (r + 1), c);
            zz = nan(v_num * (r + 1), c);
            for i = 1:v_num
                xx((i-1)*(r + 1)+(1:r), :) = xx0 * sphere_scale + vtx(i, 1);
                yy((i-1)*(r + 1)+(1:r), :) = yy0 * sphere_scale + vtx(i, 2);
                zz((i-1)*(r + 1)+(1:r), :) = zz0 * sphere_scale + vtx(i, 3);
            end
            surf(xx, yy, zz, surf_args{:}, 'EdgeColor', 'none');
        end

        line_args = object.Graphics3DObj.filterArgs(args, {'PointScale'});
        line(vtx(:, 1), vtx(:, 2), vtx(:, 3), line_args{:});

        set(gca, 'NextPlot', next_plot);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.Line;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
end
end
classdef Point < object.Graphics3DObj
% Constructor
methods
    function obj = Point(varargin)
        p = inputParser;
        p.addOptional('pts', [], @(x) validateattributes(x, {'numeric'}, {'ncols', 3}));
        p.parse(varargin{:});

        obj.vtx = p.Results.pts;
        [xx, yy, zz] = sphere();
        obj.sphere_obj = object.Surface(xx, yy, zz);
        obj.sphere_obj.scale = -1;
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        vtx = obj.vtx;
        args = cat(1, obj.draw_args(:), varargin(:));
        surf_args = object.Graphics3DObj.filterArgs(args, {'PointScale'});

        % Set arrow scale
        for i = 1:2:length(args)
            if strcmpi(args{i}, 'PointScale')
                obj.sphere_obj.scale = args{i+1};
            end
        end

        if obj.sphere_obj.scale < 0
            seg_len = sqrt(sum(diff(vtx).^2, 2));
            total_len = sum(seg_len);
            obj.sphere_obj.scale = total_len * obj.DEFAULT_SCALE;
        end

        next_plot = get(gca, 'NextPlot');
        hold on;
        for i = 1:size(vtx, 1)
            obj.sphere_obj.translation = vtx(i, :);
            obj.sphere_obj.draw(surf_args{:});
        end
        set(gca, 'NextPlot', next_plot);
    end
    
    function applyTransform(obj, t)
        obj.vtx = t.transform(obj.vtx);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.Point;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Graphics3DObj(from_obj);
        obj.sphere_obj = from_obj.sphere_obj.makeCopy();
        obj.sphere_obj.parent = obj;
    end
end

properties (Constant)
    DEFAULT_SCALE = 0.04;
end

properties
    sphere_obj = [];
end
end
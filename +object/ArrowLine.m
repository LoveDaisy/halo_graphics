classdef ArrowLine < object.Graphics3DObj
% Constructor
methods
    function obj = ArrowLine(varargin)
        p = inputParser;
        p.addOptional('pts', [], @(x) validateattributes(x, {'numeric'}, {'ncols', 3}));
        p.addOptional('StartArrow', [], @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'}));
        p.addOptional('EndArrow', [], @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'}));
        p.parse(varargin{:});

        obj.vtx = p.Results.pts;
        obj.arrow_obj = obj.makeArrowCone(0.3);
        if isempty(p.Results.pts)
            obj.line_obj = object.Line;
        else
            obj.line_obj = object.Line(p.Results.pts);
        end
        obj.start_arrow = p.Results.StartArrow;
        obj.end_arrow = p.Results.EndArrow;
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        args = cat(2, obj.material.getDrawArgs(), varargin);

        next_plot = get(gca, 'NextPlot');
        hold on;
        vtx = obj.getWorldVtx();
        line_args = object.Graphics3DObj.filterArgs(args, {'ArrowScale'});
        obj.line_obj.draw(line_args{:});
        
        % Set arrow scale
        scale_set = false;
        for i = 1:2:length(args)
            if strcmpi(args{i}, 'ArrowScale')
                obj.arrow_obj.scale.s = args{i+1};
                scale_set = true;
            end
        end
        if ~scale_set
            seg_len = sqrt(sum(diff(vtx).^2, 2));
            total_len = sum(seg_len);
            obj.arrow_obj.scale = total_len * obj.DEFAULT_CONE_SCALE;
        end
        
        % Set arrow pose and position, then draw
        vtx = obj.vtx;
        if ~isempty(obj.end_arrow)
            if obj.end_arrow < 0
                v0 = vtx(end, :);
                v1 = vtx(end-1, :);
            else
                v0 = vtx(end-1, :);
                v1 = vtx(end, :);
            end
            obj.drawCone(v0, v1, obj.end_arrow, varargin{:});
        end
        
        if ~isempty(obj.start_arrow)
            if obj.start_arrow < 0
                v0 = vtx(2, :);
                v1 = vtx(1, :);
            else
                v0 = vtx(1, :);
                v1 = vtx(2, :);
            end
            obj.drawCone(v0, v1, obj.start_arrow, varargin{:});
        end

        set(gca, 'NextPlot', next_plot);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.ArrowLine;
        new_obj.copyFrom(obj);
    end

    function applyTransform(obj, t)
        if nargin == 2
            obj.applyTransform@object.Graphics3DObj(t);
            obj.line_obj.applyTransform(t);
        else
            obj.applyTransform@object.Graphics3DObj();
            obj.line_obj.applyTransform();
        end
    end
    
    % ========== Other public methods ==========
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Graphics3DObj(from_obj);

        obj.arrow_obj = from_obj.arrow_obj.makeCopy();
        obj.line_obj = from_obj.line_obj.makeCopy();
        obj.start_arrow = from_obj.start_arrow;
        obj.end_arrow = from_obj.end_arrow;

        obj.arrow_obj.parent = obj;
        obj.line_obj.parent = obj;
    end
    
    % ========== Other public methods ==========
    function drawCone(obj, v0, v1, x, varargin)
        d = v1 - v0;
        obj.arrow_obj.rotation = transform.Rotation('from', [0, 0, 1], 'to', d);
        obj.arrow_obj.translation = transform.Translation(v0 + d * abs(x));
        args = cat(2, obj.material.getDrawArgs(), varargin);
        args = object.Graphics3DObj.filterArgs(args, {'ArrowScale', 'PointScale'}, {'^Edge'});
        obj.arrow_obj.draw(args{:});
    end
end

methods (Static)
    function obj = makeArrowCone(varargin)
        p = inputParser;
        p.addOptional('r', 0.5, @(x) validateattributes(x, {'numeric'}, {'positive'}));
        p.parse(varargin{:});

        % Make cone
        circ = [cosd(0:30:360); sind(0:30:360)];
        num = size(circ, 2);

        xx = [zeros(1, num); circ(1, :) * p.Results.r; zeros(1, num)];
        yy = [zeros(1, num); circ(2, :) * p.Results.r; zeros(1, num)];
        zz = [zeros(1, num); -ones(2, num)];

        cone = object.Surface(xx, yy, zz);
        cone.setMaterial(render.Material('FaceColor', 'w', 'EdgeColor', 'none'));

        % Make strides
        x = [-1:.25:-.1, -.02];
        strides = cell(1, length(x));
        for i = 1:length(x)
            strides{i} = object.Line([circ' * p.Results.r * (-x(i)) * 1.1, ones(num, 1) * x(i)]);
        end

        obj = object.ComplexObj(cone, strides{:});
    end
end

properties (Constant)
    DEFAULT_CONE_SCALE = 0.04;
end

properties
    arrow_obj;
    line_obj;
    start_arrow;
    end_arrow;
end
end
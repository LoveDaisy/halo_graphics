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
        next_plot = get(gca, 'NextPlot');
        hold on;
        vtx = obj.getWorldVtx();
        line(vtx(:, 1), vtx(:, 2), vtx(:, 3), ...
            obj.draw_args{:}, ...
            varargin{:});
        
        % Set arrow scale
        if obj.arrow_scale > 0
            obj.arrow_obj.scale = obj.arrow_scale;
        else
            seg_len = sqrt(sum(diff(vtx).^2, 2));
            total_len = sum(seg_len);
            obj.arrow_obj.scale = total_len * obj.DEFAULT_SCALE;
        end
        
        % Set arrow pose and position, then draw
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
    
    function applyTransform(obj, t)
        obj.vtx = t.transform(obj.vtx);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.ArrowLine;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
    function setArrowScale(obj, s)
        % Scale to actual size.
        obj.arrow_scale = s;
    end
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
        t = transform.Rotation('from', [0, 0, 1], 'to', d);
        obj.arrow_obj.rotation = t.mat;
        obj.arrow_obj.translation = (v0 + d * abs(x))';
        args = cat(1, obj.draw_args(:), varargin(:));
        args = object.Graphics3DObj.fileterArgs(args, {}, {'^Edge'});
        obj.arrow_obj.draw(args{:});
    end
end

properties (Constant)
    DEFAULT_SCALE = 0.04;
end

properties
    arrow_obj = object.makeArrowCone(0.3);
    arrow_scale = -1;
    line_obj = object.Line;
    start_arrow = [];
    end_arrow = [];
end
end
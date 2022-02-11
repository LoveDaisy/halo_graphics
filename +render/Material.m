classdef Material < handle
methods
    function obj = Material(varargin)
        num = length(varargin);
        if ~mod(num, 2) == 0
            error('Arguments must be even');
        end
        
        obj = obj.reset();
        
        unused_idx = true(1, num);
        for i = 1:2:num
            if ~ischar(varargin{i})
                unused_idx(i:i+1) = false;
                continue;
            end
            if strcmpi(varargin{i}, 'LineWidth') || strcmpi(varargin{i}, 'EdgeWidth')
                obj.line_width = varargin{i+1};
                unused_idx(i:i+1) = false;
            elseif strcmpi(varargin{i}, 'LineStyle') || strcmpi(varargin{i}, 'EdgeStyle')
                obj.line_style = varargin{i+1};
                unused_idx(i:i+1) = false;
            elseif strcmpi(varargin{i}, 'LineColor') || strcmpi(varargin{i}, 'EdgeColor')
                obj.line_color = varargin{i+1};
                unused_idx(i:i+1) = false;
            elseif strcmpi(varargin{i}, 'FaceColor')
                obj.face_color = varargin{i+1};
                unused_idx(i:i+1) = false;
            elseif strcmpi(varargin{i}, 'FaceAlpha')
                obj.face_alpha = varargin{i+1};
                unused_idx(i:i+1) = false;
            end
        end
        obj.other_args = varargin(unused_idx);
    end

    function args = getDrawArgs(obj)
        idx = 1;
        args = {};
        if ~isempty(obj.line_width)
            args(idx:idx+1) = {'LineWidth', obj.line_width};
            idx = idx + 2;
        end
        if ~isempty(obj.line_style)
            args(idx:idx+1) = {'LineStyle', obj.line_style};
            idx = idx + 2;
        end
        if ~isempty(obj.line_color)
            args(idx:idx+3) = {'EdgeColor', obj.line_color, 'Color', obj.line_color};
            idx = idx + 4;
        end
        if ~isempty(obj.face_color)
            args(idx:idx+1) = {'FaceColor', obj.face_color};
            idx = idx + 2;
        end
        if ~isempty(obj.face_alpha)
            args(idx:idx+1) = {'FaceAlpha', obj.face_alpha};
            idx = idx + 2;
        end
        num = length(obj.other_args);
        args(idx:idx+num-1) = obj.other_args;
    end
    
    function setLineWidth(obj, w)
        obj.line_width = w;
    end
    
    function setLineStyle(obj, s)
        obj.line_style = s;
    end
    
    function setLineColor(obj, c)
        obj.line_color = c;
    end
    
    function setFaceColor(obj, c)
        obj.face_color = c;
    end
    
    function setFaceAlpha(obj, a)
        obj.face_alpha = a;
    end
    
    function setDrawArgs(obj, args)
        obj.other_args = args;
    end
end

methods (Access = protected)
    function obj = reset(obj)
        obj.line_width = [];
        obj.line_style = [];
        obj.line_color = [];
        obj.face_color = [];
        obj.face_alpha = [];
        obj.other_args = {};
    end
end

properties (GetAccess = public)
    line_width
    line_style
    line_color
    face_color
    face_alpha
    other_args
end
end
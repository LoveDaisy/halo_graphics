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
        line(vtx(:, 1), vtx(:, 2), vtx(:, 3), ...
            obj.draw_args{:}, ...
            varargin{:});
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.Line;
        new_obj.copyFrom(obj);
    end
    
    % ========== Other public methods ==========
end
end
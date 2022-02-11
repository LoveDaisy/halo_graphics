classdef Scale < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@minus, vtx, obj.o) * obj.s;
        vtx = bsxfun(@plus, vtx, obj.o);
    end
end

methods
    function obj = Scale(varargin)
        obj.s = 1;
        obj.o = [0, 0, 0];
        if isempty(varargin)
            return;
        end
        p = inputParser;
        p.addOptional('s', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'}));
        p.addOptional('o', [0, 0, 0], @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});

        obj.s = p.Results.s;
        obj.o = p.Results.o;
    end
end

properties
    s
    o
end
end
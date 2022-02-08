classdef Scale < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * obj.s;
    end
end

methods
    function obj = Scale(varargin)
        p = inputParser;
        p.addOptional('s', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'}));
        p.parse(varargin{:});

        obj.s = p.Results.s;
    end
end

properties
    s = 1;
end
end
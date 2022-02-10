classdef Scale < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * obj.s;
    end

    function t = makeCopy(obj)
        t = transform.Scale;
        t.copyFrom(obj);
    end

    function merge(obj, t)
        obj.s = obj.s * t.s;
    end
end

methods
    function obj = Scale(varargin)
        obj.s = 1;
        if isempty(varargin)
            return;
        end
        p = inputParser;
        p.addOptional('s', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'}));
        p.parse(varargin{:});

        obj.s = p.Results.s;
    end
end

methods (Access = protected)
    function copyFrom(obj, from_obj)
        obj.copyFrom@transform.Transform(from_obj);
        obj.s = from_obj.s;
    end
end

properties
    s
end
end
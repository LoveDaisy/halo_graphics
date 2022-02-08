classdef SimpleReflection < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * (eye(3) - 2 * obj.n' * obj.n);
    end

    function t = makeCopy(obj, from_obj)
        t = transform.SimpleReflection;
        t.copyFrom(from_obj);
    end
end

methods
    function obj = SimpleReflection(varargin)
        p = inputParser;
        p.addOptional('normal', zeros(1, 3), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});

        obj.n = p.Results.normal(:)';
    end
end

methods (Access = protected)
    function copyFrom(obj, from_obj)
        obj.copyFrom@transform.Transform(from_obj);
        obj.n = from_obj.n;
    end
end

properties
    n
end
end
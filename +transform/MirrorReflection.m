classdef MirrorReflection < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@minus, vtx, obj.p) * (eye(3) - 2 * obj.n' * obj.n);
        vtx = bsxfun(@plus, vtx, obj.p);
    end

    function t = makeCopy(obj)
        t = transform.MirrorReflection;
        t.copyFrom(obj);
    end
end

methods
    function obj = MirrorReflection(varargin)
        p = inputParser;
        p.addOptional('normal', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addOptional('p0', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});

        obj.n = p.Results.normal(:)';
        obj.p = p.Results.p0(:)';
    end
end

methods (Access = protected)
    function copyFrom(obj, from_obj)
        obj.copyFrom@transform.Transform(from_obj);
        obj.n = from_obj.n;
        obj.p = from_obj.p;
    end
end

properties
    n
    p
end
end
classdef MirrorReflection < transform.RigidTransform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@minus, vtx, obj.p) * (eye(3) - 2 * obj.n' * obj.n);
        vtx = bsxfun(@plus, vtx, obj.p);
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

properties
    n = zeros(1, 3);
    p = zeros(1, 3);
end
end
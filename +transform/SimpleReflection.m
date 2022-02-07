classdef SimpleReflection < transform.RigidTransform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * (eye(3) - 2 * obj.n' * obj.n);
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

properties
    n = zeros(1, 3);
end
end
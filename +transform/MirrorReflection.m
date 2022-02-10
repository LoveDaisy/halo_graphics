classdef MirrorReflection < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@minus, vtx, obj.p) * (eye(3) - 2 * obj.n' * obj.n);
        vtx = bsxfun(@plus, vtx, obj.p);
    end
end

methods
    function obj = MirrorReflection(varargin)
        obj.n = zeros(1, 3);
        obj.p = zeros(1, 3);
        if isempty(varargin)
            return;
        end
        p = inputParser;
        p.addOptional('normal', zeros(1, 3), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addOptional('p0', zeros(1, 3), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});

        obj.n = p.Results.normal(:)';
        obj.p = p.Results.p0(:)';
    end
end

properties
    n
    p
end
end
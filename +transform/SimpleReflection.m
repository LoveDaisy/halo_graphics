classdef SimpleReflection < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * (eye(3) - 2 * obj.n' * obj.n);
    end
end

methods
    function obj = SimpleReflection(varargin)
        obj.n = zeros(1, 3);
        if isempty(varargin)
            return;
        end
        p = inputParser;
        p.addOptional('normal', zeros(1, 3), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});

        obj.n = p.Results.normal(:)';
    end
end

properties
    n
end
end
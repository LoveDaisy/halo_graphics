classdef Translation < transform.RigidTransform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@plus, vtx, obj.v');
    end
end

methods
    function obj = Translation(varargin)
        p = inputParser;
        p.addOptional('v', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel' 3}));
        p.parse(varargin{:});

        obj.v = p.Results.v(:);
    end
end

properties
    v = zeros(3, 1);
end
end
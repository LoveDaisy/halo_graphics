classdef Translation < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@plus, vtx, obj.v);
    end
end

methods
    function obj = Translation(varargin)
        p = inputParser;
        p.addOptional('v', zeros(1, 3), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel' 3}));
        p.parse(varargin{:});

        obj.v = p.Results.v(:)';
    end
end

properties
    v = zeros(1, 3);
end
end
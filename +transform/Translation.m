classdef Translation < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@plus, vtx, obj.v);
    end

    function t = makeCopy(obj)
        t = transform.Translation;
        t.copyFrom(obj);
    end

    function merge(obj, t)
        obj.v = obj.v + t.v;
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

methods (Access = protected)
    function copyFrom(obj, from_obj)
        obj.copyFrom@transform.Transform(from_obj);
        obj.v = from_obj.v;
    end
end

properties
    v
end
end
classdef CompositeTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        for i = 1:length(obj.transforms)
            vtx = obj.transforms{i}.transform(vtx);
        end
    end
end

methods
    function obj = CompositeTransform(varargin)
        obj.transforms = varargin;
    end
end

properties
    transforms
end
end
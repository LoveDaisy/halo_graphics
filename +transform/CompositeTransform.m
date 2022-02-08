classdef CompositeTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        for i = 1:length(obj.transforms)
            vtx = obj.transfomrs{i}.transform(vtx);
        end
    end
end

methods
    function obj = CompositeTransform(varargin)
        for i = 1:length(varargin)
            if ~isa(varargin{i}, 'transform.Transform')
                error('All arguments must be transform.Transform');
            end
        end

        obj.transforms = varargin;
    end
end

properties
    transforms = {};
end
end
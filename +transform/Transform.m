classdef (Abstract) Transform < handle
methods (Abstract)
    vtx = transform(obj, vtx);

    t = makeCopy(obj);
end

methods
    function t = chain(obj, varargin)
        for i = 1:length(varargin)
            if ~isa(varargin{i}, 'transform.Transform')
                error('All arguments must be transform.Transform');
            end
        end
        t = transform.CompositeTransform(obj, varargin{:});
    end

    function merge(obj, t)
        error('This transform cannot be merged!');
    end
end

methods (Access = protected)
    function copyFrom(obj, from_obj)
    end
end
end
classdef (Abstract) Transform
methods (Abstract)
    vtx = transform(obj, vtx);
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

    function obj = merge(obj, t)
        error('This transform cannot be merged!');
    end
end

end
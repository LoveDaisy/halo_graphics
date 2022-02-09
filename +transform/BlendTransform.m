classdef BlendTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx_t = 0;
        for i = 1:length(obj.transforms)
            vtx_t = vtx_t + obj.transforms{i}.transform(vtx) * obj.weights(i);
        end
        vtx = vtx_t;
    end

    function t = makeCopy(obj)
        t = transform.BlendTransform;
        t.copyFrom(obj);
    end
end

methods
    function obj = BlendTransform(varargin)
        t_num = length(varargin);
        for i = 1:t_num
            if ~isa(varargin{i}, 'transform.Transform')
                error('All arguments must be transform.Transform');
            end
        end

        obj.transforms = cell(1, t_num);
        for i = 1:t_num
            obj.transforms{i} = varargin{i}.makeCopy();
        end
        obj.weights = ones(1, t_num) / t_num;
    end
    
    function setWeights(obj, weights)
        t_num = length(obj.transforms);
        w_num = length(weights(:));
        if w_num ~= t_num
            error('weights must be same length of transforms (here is %d)', t_num);
        end
        obj.weights = weights(:)' / sum(weights(:));
    end
end

methods (Access = protected)
    function copyFrom(obj, from_obj)
        obj.copyFrom@transform.Transform(from_obj);
        t_num = length(from_obj.transforms);
        obj.transforms = cell(1, t_num);
        for i = 1:t_num
            obj.transforms{i} = from_obj.transforms{i}.makeCopy();
        end
        obj.weights = from_obj.weights;
    end
end

properties
    transforms
    weights
end
end
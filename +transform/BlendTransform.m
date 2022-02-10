classdef BlendTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx_t = 0;
        for i = 1:length(obj.transforms)
            vtx_t = vtx_t + obj.transforms{i}.transform(vtx) * obj.weights(i);
        end
        vtx = vtx_t;
    end
end

methods
    function obj = BlendTransform(varargin)
        t_num = length(varargin);
        if mod(t_num, 2) ~= 0
            error('Arguments number must be even');
        end
        for i = 1:2:t_num
            if ~isa(varargin{i}, 'transform.Transform')
                error('Argument at odd location must be transform.Transform');
            end
            if ~isreal(varargin{i+1})
                error('Argument at even location must be a real number');
            end
        end

        obj.transforms = cell(1, t_num/2);
        obj.weights = zeros(1, t_num/2);
        for i = 1:2:t_num
            obj.transforms{(i+1)/2} = varargin{i};
            obj.weights((i+1)/2) = varargin{i+1};
        end
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

properties
    transforms
    weights
end
end
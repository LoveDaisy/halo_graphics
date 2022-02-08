classdef CompositeTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        for i = 1:length(obj.transforms)
            vtx = obj.transforms{i}.transform(vtx);
        end
    end

    function t = makeCopy(obj)
        t = transform.CompositeTransform;
        t.copyFrom(obj);
    end

    function merge(obj, t)
        t_num = length(obj.transforms);
        if t_num > 0
            class_t = class(obj.transforms{t_num});
            if strcmpi(class_t, 'transform.Scale') || strcmpi(class_t, 'transform.Rotation') || ...
                strcmpi(class_t, 'transform.Translation')
                obj.transforms{t_num}.merge(t);
            end
        else
            obj.transforms{t_num+1} = t.makeCopy();
        end
    end
end

methods
    function obj = CompositeTransform(varargin)
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
    end
end

properties
    transforms
end
end
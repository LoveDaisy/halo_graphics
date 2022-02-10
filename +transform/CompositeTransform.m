classdef CompositeTransform < transform.Transform
methods
    function vtx = transform(obj, vtx)
        for i = 1:length(obj.transforms)
            vtx = obj.transforms{i}.transform(vtx);
        end
    end

    function obj = merge(obj, t)
        t_num = length(obj.transforms);
        if t_num > 0
            class_t = class(obj.transforms{t_num});
            if strcmpi(class_t, 'transform.Scale') || strcmpi(class_t, 'transform.Rotation') || ...
                strcmpi(class_t, 'transform.Translation')
                obj.transforms{t_num} = obj.transforms{t_num}.merge(t);
            end
        else
            obj.transforms{t_num+1} = t;
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
classdef ComplexObj < object.Graphics3DObj
% Constructor
methods
    function obj = ComplexObj(varargin)
        for i = 1:length(varargin)
            if ~isa(varargin{i}, 'object.Graphics3DObj')
                error('All objects must be Graphics3DObj!');
            end
        end

        obj.objects = cell(size(varargin));
        for i = 1:length(varargin)
            obj.objects{i} = varargin{i}.makeCopy();
            obj.objects{i}.parent = obj;
        end
    end
end

% Public methods
methods
    % ========== Override methods ==========
    function draw(obj, varargin)
        next_plot = get(gca, 'NextPlot');
        hold on;
        for i = 1:length(obj.objects)
            obj.objects{i}.draw(varargin{:});
        end
        set(gca, 'NextPlot', next_plot);
    end
    
    function new_obj = makeCopy(obj)
        new_obj = object.ComplexObj;
        new_obj.copyFrom(obj);
    end

    function applyTransform(obj)
        t = transform.CompositeTransform(obj.scale, obj.rotation, obj.translation, obj.other_transforms);
        for i = 1:length(obj.objects)
            obj.objects{i}.applyTransform(t);
        end
        obj.resetTransform();
    end
    
    % ========== Other public methods ==========
    function addObj(obj, other_obj)
        if ~isa(other_obj, 'object.Graphics3DObj')
            error('Objects must be Graphics3DObj!');
        end
        num = length(obj.objects);
        obj.objects{num + 1} = other_obj.makeCopy();
        obj.objects{num + 1}.parent = obj;
    end
end

% Protected methods
methods (Access = protected)
    % ========== Override methods ==========
    function copyFrom(obj, from_obj)
        obj.copyFrom@object.Graphics3DObj(from_obj);
        obj_cnt = length(from_obj.objects);
        obj.objects = cell(1, obj_cnt);
        for i = 1:obj_cnt
            obj.objects{i} = from_obj.objects{i}.makeCopy();
            obj.objects{i}.parent = obj;
        end
    end
end

properties
    objects
end
end
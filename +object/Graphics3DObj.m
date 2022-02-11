classdef (Abstract) Graphics3DObj < handle
methods (Abstract)
    draw(obj, varargin);
    
    new_obj = makeCopy(obj);
end

methods
    function setMaterial(obj, m)
        obj.material = m;
    end
    
    function dynamicTransform(obj, t)
        class_t = class(t);
        if strcmpi(class_t, 'transform.Scale')
            obj.scale = t;
        elseif strcmpi(class_t, 'transform.Rotation')
            obj.rotation = t;
        elseif strcmpi(class_t, 'transform.Translation')
            obj.translation = t;
        else
            obj.other_transforms = t;
        end
    end

    function applyTransform(obj, t)
        if nargin == 1
            t = transform.CompositeTransform(obj.scale, obj.rotation, obj.translation, obj.other_transforms);
        end
        obj.vtx = t.transform(obj.vtx);
        obj.resetTransform();
    end
    
    function resetTransform(obj)
        obj.rotation = transform.Rotation;
        obj.scale = transform.Scale;
        obj.translation = transform.Translation;
        obj.other_transforms = transform.CompositeTransform;
    end
end

methods (Access = protected)
    function obj = Graphics3DObj()
        obj.vtx = [];
        obj.rotation = transform.Rotation;
        obj.scale = transform.Scale;
        obj.translation = transform.Translation;
        obj.other_transforms = transform.CompositeTransform;
        obj.parent = [];
        obj.material = render.Material;
    end

    function vtx = getWorldVtx(obj)
        if isempty(obj.vtx)
            vtx = [];
            return;
        end
        t0 = obj.getWorldTransform();
        vtx = t0.transform(obj.vtx);
    end

    function t0 = getWorldTransform(obj)
        t0 = transform.CompositeTransform(obj.scale, obj.rotation, obj.translation, obj.other_transforms);
        if ~isempty(obj.parent)
            t0 = t0.chain(obj.parent.getWorldTransform());
        end
    end
    
    function copyFrom(obj, from_obj)
        obj.vtx = from_obj.vtx;
        obj.rotation = from_obj.rotation;
        obj.scale = from_obj.scale;
        obj.translation = from_obj.translation;
        obj.other_transforms = from_obj.other_transforms;
        obj.parent = from_obj.parent;
        obj.material = from_obj.material;
    end
end

methods (Static)
    function args = filterArgs(args, key_str, key_regexp)
        if nargin == 2
            key_regexp = [];
        end
        num = length(args);
        valid_idx = true(size(args));
        for i = 1:2:num
            % Check strcmpi
            for j = 1:length(key_str)
                if strcmpi(args{i}, key_str{j})
                    valid_idx(i:i+1) = false;
                end
            end
            
            % Check regexp
            for j = 1:length(key_regexp)
                if ~isempty(regexp(args{i}, key_regexp{j}, 'once'))
                    valid_idx(i:i+1) = false;
                end
            end
        end
        args = args(valid_idx);
    end
    
    function args = keepArgs(args, key_str, key_regexp)
        if nargin == 2
            key_regexp = [];
        end
        num = length(args);
        valid_idx = false(size(args));
        for i = 1:2:num
            % Check strcmpi
            for j = 1:length(key_str)
                if strcmpi(args{i}, key_str{j})
                    valid_idx(i:i+1) = true;
                end
            end
            
            % Check regexp
            for j = 1:length(key_regexp)
                if ~isempty(regexp(args{i}, key_regexp{j}, 'once'))
                    valid_idx(i:i+1) = true;
                end
            end
        end
        args = args(valid_idx);
    end
end

properties (Access = protected)
    vtx
    rotation
    scale
    translation
    other_transforms
    parent
    material
end
end
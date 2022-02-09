classdef (Abstract) Graphics3DObj < handle
methods (Abstract)
    draw(obj, varargin);
    
    new_obj = makeCopy(obj);
end

methods
    function setDrawArgs(obj, varargin)
        obj.draw_args = varargin;
    end
    
    function previewTransform(obj, t)
        class_t = class(t);
        if strcmpi(class_t, 'transform.Scale')
            obj.scale.merge(t);
        elseif strcmpi(class_t, 'transform.Rotation')
            obj.rotation.merge(t);
        elseif strcmpi(class_t, 'transform.Translation')
            obj.translation.merge(t);
        else
            obj.other_transforms.merge(t);
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
        obj.draw_args = {};
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
        obj.rotation = from_obj.rotation.makeCopy();
        obj.scale = from_obj.scale.makeCopy();
        obj.translation = from_obj.translation.makeCopy();
        obj.other_transforms = from_obj.other_transforms.makeCopy();
        obj.parent = from_obj.parent;
        obj.draw_args = from_obj.draw_args;
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

properties (Access = public)
    vtx
    rotation
    scale
    translation
    other_transforms
    parent
    draw_args
end
end
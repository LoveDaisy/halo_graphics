classdef (Abstract) Graphics3DObj < handle
methods (Abstract)
    draw(obj, varargin);
    
    applyTransform(obj, t);
    
    new_obj = makeCopy(obj);
end

methods
    function setDrawArgs(obj, varargin)
        obj.draw_args = varargin;
    end
end

methods (Access = protected)
    function obj = Graphics3DObj()
    end

    function vtx = getWorldVtx(obj)
        if isempty(obj.vtx)
            vtx = [];
            return;
        end
        [t, r, s] = obj.getWorldTransform();
        vtx = bsxfun(@plus, obj.vtx * r' * s, t');
    end

    function [t0, r0, s0] = getWorldTransform(obj)
        t0 = obj.translation;
        r0 = obj.rotation;
        s0 = obj.scale;
        if ~isempty(obj.parent)
            [t, r, s] = obj.parent.getWorldTransform();
            r0 = r * r0;
            t0 = r * t0 + t;
            s0 = s * s0;
        end
    end
    
    function copyFrom(obj, from_obj)
        obj.vtx = from_obj.vtx;
        obj.rotation = from_obj.rotation;
        obj.translation = from_obj.translation;
        obj.parent = from_obj.parent;
        obj.draw_args = from_obj.draw_args;
    end
end

methods (Static)
    function args = fileterArgs(args, key_str, key_regexp)
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
    vtx = [];
    rotation = eye(3);
    translation = zeros(3, 1);
    scale = 1;
    parent = [];
    draw_args = {};
end
end
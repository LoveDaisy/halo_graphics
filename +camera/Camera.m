classdef Camera < handle
methods
    function obj = Camera(varargin)
        arg_num = length(varargin);
        if mod(arg_num, 2) ~= 0
            error('Arguments must be even');
        end
        
        obj.cam_pos = [];
        obj.cam_target = [];
        obj.cam_view_angle = [];
        obj.other_axes_args = {};
        
        unused_idx = false(1, arg_num);
        for i = 1:2:arg_num
            if strcmpi(varargin{i}, 'CameraPosition')
                obj.cam_pos = varargin{i+1};
            elseif strcmpi(varargin{i}, 'CameraTarget')
                obj.cam_target = varargin{i+1};
            elseif strcmpi(varargin{i}, 'CameraViewAngle')
                obj.cam_view_angle = varargin{i+1};
            else
                unused_idx(i:i+1) = true;
            end
        end
        obj.other_axes_args = varargin(unused_idx);
    end
    
    function render(obj, scene_obj)
        scene_obj.draw();
        obj.update();
    end
    
    function update(obj)
        axes_args = {};
        idx = 1;
        if ~isempty(obj.cam_pos)
            axes_args(idx:idx+1) = {'CameraPosition', obj.cam_pos};
            idx = idx + 2;
        end
        if ~isempty(obj.cam_target)
            axes_args(idx:idx+1) = {'CameraTarget', obj.cam_target};
            idx = idx + 2;
        end
        if ~isempty(obj.cam_view_angle)
            axes_args(idx:idx+1) = {'CameraViewAngle', obj.cam_view_angle};
        end
        set(gca, axes_args{:}, obj.other_axes_args{:});
    end
end

properties
    cam_pos;
    cam_target;
    cam_view_angle;
    other_axes_args;
end
end
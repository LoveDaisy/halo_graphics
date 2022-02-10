classdef Camera < handle
methods
    function obj = Camera(varargin)
        arg_num = length(varargin);
        if mod(arg_num, 2) ~= 0
            error('Arguments must be even');
        end
        
        obj.cam_pos = [];
        obj.cam_target = [];
        obj.other_axes_args = {};
        
        unused_idx = false(1, arg_num);
        for i = 1:2:arg_num
            if strcmpi(varargin{i}, 'CameraPosition')
                obj.cam_pos = varargin{i+1};
            elseif strcmpi(varargin{i}, 'CameraTarget')
                obj.cam_target = varargin{i+1};
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
        end

        set(gca, axes_args{:}, obj.other_axes_args{:});
    end
    
    function setCamPosition(obj, p)
        obj.cam_pos = p;
    end
    
    function setCamPose(obj, p)
        % [lon, h, r, target_xyz]
        pos = [cosd(p(1)), sind(p(1)), p(2)] * p(3) + p(4:6);
        obj.cam_pos = pos;
        obj.cam_target = p(4:6);
    end
    
    function setCamTarget(obj, t)
        obj.cam_target = t;
    end
end

properties (Access = protected)
    cam_pos;
    cam_target;
    other_axes_args;
end
end
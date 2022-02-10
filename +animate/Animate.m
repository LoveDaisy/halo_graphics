classdef (Abstract) Animate < handle
methods
    function obj = Animate(varargin)
        obj.reset();
    end
    
    function addAction(obj, action, start_param, end_param)
        act_num = length(obj.actions);
        obj.actions{act_num+1} = {action, start_param, end_param};
    end
    
    function addPostActions(obj, action, varargin)
        act_num = length(obj.post_actions);
        obj.post_actions{act_num+1} = {action, varargin};
    end
    
    function setTickStep(obj, s)
        obj.step = s;
    end
    
    function setDuration(obj, d)
        obj.duration = d;
    end
    
    function tick(obj)
        if obj.finished()
            return
        end

        s = obj.parameter();
        
        % Perform actions
        act_num = length(obj.actions);
        for i = 1:act_num
            curr_act = obj.actions{i};
            if isa(curr_act{2}, 'transform.Transform')
                curr_act{1}(transform.BlendTransform(curr_act{2}, 1 - s, curr_act{3}, s));
            else
                curr_act{1}(curr_act{2} * (1 - s) + curr_act{3} * s);
            end
        end
        
        % Do post-actions
        act_num = length(obj.post_actions);
        for i = 1:act_num
            curr_act = obj.post_actions{i};
            curr_act{1}(curr_act{2}{:});
        end
        obj.t = obj.t + obj.step;
    end
    
    function play(obj)
        while ~obj.finished()
            obj.tick();
        end
    end
    
    function f = finished(obj)
        f = obj.t >= obj.duration + obj.step / 2;
    end
    
    function reset(obj)
        obj.t = 0;
        obj.step = 0.1;
        obj.duration = 1;
        obj.actions = {};
        obj.post_actions = {};
    end
end

methods (Abstract, Access = protected)
    s = parameter(obj)
end

properties (Access = protected)
    t
    step
    duration
    actions
    post_actions
end
end
classdef (Abstract) Animate < handle
methods
    function obj = Animate(varargin)
        obj.actions = {};
        obj.t = 0;
        obj.step = 0.1;
        obj.duration = 1;
    end
    
    function addAction(obj, action, start_param, end_param)
        act_num = length(obj.actions);
        obj.actions{act_num+1} = {action, start_param, end_param};
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

        act_num = length(obj.actions);
        s = obj.parameter();
        for i = 1:act_num
            curr_act = obj.actions{i};
            if isa(curr_act{2}, 'transform.Transform')
                curr_act{1}(transform.BlendTransform(curr_act{2}, 1 - s, curr_act{3}, s));
            else
                curr_act{1}(curr_act{2} * (1 - s) + curr_act{3} * s);
            end
        end
        obj.t = obj.t + obj.step;
    end
    
    function f = finished(obj)
        f = obj.t >= obj.duration + obj.step / 2;
    end
    
    function reset(obj)
        obj.actions = {};
        obj.t = 0;
        obj.step = 0.1;
        obj.duration = 1;
    end
end

methods (Abstract, Access = protected)
    s = parameter(obj)
end

properties (Access = protected)
    actions
    t
    step
    duration
end
end
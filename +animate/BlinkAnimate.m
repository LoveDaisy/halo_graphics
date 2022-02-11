classdef BlinkAnimate < animate.Animate
methods
    function obj = BlinkAnimate(varargin)
    end
    
    function setRepeatTimes(obj, n)
        obj.n = n;
    end
end

methods (Access = protected)
    function s = parameter(obj)
        s = mod(obj.t / obj.duration * obj.n, 1);
        s = s^2;
    end
end

properties (Access = private)
    n
end
end
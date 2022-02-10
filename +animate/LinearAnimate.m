classdef LinearAnimate < animate.Animate
methods
    function obj = LinearAnimate(varargin)
    end
end

methods (Access = protected)
    function s = parameter(obj)
        s = obj.t / obj.duration;
    end
end
end
classdef SimpleSmoothAnimate < animate.Animate
methods
    function obj = SimpleSmoothAnimate(varargin)
    end
end

methods (Access = protected)
    function s = parameter(obj)
        s = sin(pi * (obj.t - 0.5)) * 0.5 + 0.5;
    end
end
end
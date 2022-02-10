classdef Rotation < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = vtx * obj.matt;
    end

    function obj = merge(obj, t)
        obj.matt = obj.matt * t.matt;
    end
end

methods
    function obj = Rotation(varargin)
        obj.matt = eye(3);
        if isempty(varargin)
            return;
        end
        p = inputParser;
        p.addParameter('from', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('to', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('axis', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('theta', 0, @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.parse(varargin{:});
        
        if norm(p.Results.from) > 1e-4 && norm(p.Results.to) > 1e-4
            from = p.Results.from;
            from = from / norm(from);
            to = p.Results.to;
            to = to / norm(to);
            axis = cross(from, to);
            s = norm(axis);
            c = dot(from, to);
            theta = atan2d(s, c);
            axis = axis / norm(axis);
        elseif norm(p.Results.axis) > 1e-4
            axis = p.Results.axis;
            axis = axis / norm(axis);
            theta = p.Results.theta;
        else
            axis = [1, 0, 0];
            theta = 0;
        end

        obj.matt = quatrotate([cosd(theta/2), -sind(theta/2) * axis(:)'], eye(3));
    end
end

properties
    matt
end
end
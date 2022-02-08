classdef Rotation < transform.Transform
methods
    function vtx = transform(obj, vtx)
        vtx = bsxfun(@minus, vtx, obj.anchor) * obj.matt;
        vtx = bsxfun(@plus, vtx, obj.anchor);
    end
end

methods
    function obj = Rotation(varargin)
        p = inputParser;
        p.addParameter('from', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('to', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('axis', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('theta', 0, @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
        p.addParameter('anchor', zeros(3, 1), @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 3}));
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
        elseif norm(p.Results.axis > 1e-4)
            axis = p.Results.axis;
            axis = axis / norm(axis);
            theta = p.Results.theta;
        else
            error('Either use from-to form or use axis-theta form!');
        end

        obj.matt = quatrotate([cosd(theta/2), -sind(theta/2) * axis(:)'], eye(3));
        obj.anchor = p.Results.anchor(:)';
    end
end

properties
    matt = eye(3);
    anchor = zeros(1, 3);
end
end
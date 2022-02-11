function obj = makeArrowCone(varargin)
p = inputParser;
p.addOptional('r', 0.5, @(x) validateattributes(x, {'numeric'}, {'positive'}));
p.parse(varargin{:});

% Make cone
circ = [cosd(0:30:360); sind(0:30:360)];
num = size(circ, 2);

xx = [zeros(1, num); circ(1, :) * p.Results.r; zeros(1, num)];
yy = [zeros(1, num); circ(2, :) * p.Results.r; zeros(1, num)];
zz = [zeros(1, num); -ones(2, num)];

cone = object.Surface(xx, yy, zz);
cone.setMaterial(render.Material('FaceColor', 'w', 'EdgeColor', 'none'));

% Make strides
x = [-1:.25:-.1, -.02];
strides = cell(1, length(x));
for i = 1:length(x)
    strides{i} = object.Line([circ' * p.Results.r * (-x(i)) * 1.1, ones(num, 1) * x(i)]);
end

obj = object.ComplexObj(cone, strides{:});
end
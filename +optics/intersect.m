function p = intersect(p, r, vtx)
% Find intersection point of a ray and a surface.
%
% INPUT
%   p:      n*3
%   r:      n*3
%   vtx:    m*3, (m >= 3), if more than 3 vertices are given, only first 3 are used.

% It is to solve the equation:
%   p_i + r_i * t_i = (v1 - v0) * u_i + (v2 - v0) * v_i + v0
% reform as:
%   [v1 - v0, v2 - v0, -r_i] * [u; v; t]_i = p_i - v0

pts_num = size(p, 1);
for i = 1:pts_num
    A = [vtx(2, :) - vtx(1, :); vtx(3, :) - vtx(1, :); -r(i, :)];
    b = p(i, :) - vtx(1, :);
    x = b / A;
    p(i, :) = p(i, :) + r(i, :) * x(3);
end
end
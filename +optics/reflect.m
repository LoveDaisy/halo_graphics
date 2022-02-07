function ray_out = reflect(ray_in, face_normal)
% INPUT
%  ray_in:       n*3, [dx, dy, dz], ray direction. Normalized to unit.
%  face_normal:  1*3, face normal. Normalized to unit.

ray_n = size(ray_in, 1);

ray_out = nan(ray_n, 3);
valid_ind = sum(abs(ray_in), 2) > 1e-4;
valid_cnt = sum(valid_ind);

if valid_cnt <= 0
    return;
end

r = ray_in(valid_ind, :) - 2 * (ray_in(valid_ind, :) * face_normal') * face_normal;
ray_out(valid_ind, :) = r;
end

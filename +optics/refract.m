function ray_out = refract(ray_in, face_normal, n0, n1)
% INPUT
%  ray_in:       n*3, [dx, dy, dz], input ray direction. Normalized to unit.
%  face_normal:  1*3, face normal. Normalized to unit.
%  n0, n1:       refractive index

ray_n = size(ray_in, 1);

ray_out = nan(ray_n, 3);
valid_ind = sum(abs(ray_in), 2) > 1e-4;

cos_alpha = ray_in * face_normal';
delta = cos_alpha.^2 - 1 + (n1 / n0)^2;

valid_delta = delta > 0;
valid_ind = valid_ind & valid_delta;
if ~any(valid_ind)
    return;
end

valid_ind = find(valid_ind);
a = cos_alpha(valid_ind) - sign(cos_alpha(valid_ind)) .* sqrt(delta(valid_ind));

r = ray_in(valid_ind, :) - a * face_normal;
r = optics.normalize_vector(r);

ray_out(valid_ind, :) = r;
end

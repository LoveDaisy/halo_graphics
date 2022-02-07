function raypath = trace_ray(p0, r0, crystal, fid)
% Trace a ray through given crystal
%
% INPUT
%   p0:         1*3, [x, y, z]
%   r0:         1*3, [dx, dy, dz]
%   crystal:    struct
%   fid:        1*m
%
% OUTPUT
%   rp:         m*6, [x, y, z, dx, dy, dx]

rp_len = length(fid);
raypath = nan(rp_len, 6);

% First refraction
r = optics.refract(r0, crystal.face_norm(fid(1), :), 1, crystal.n);

% Inner reflection
p = p0;
raypath(1, :) = [p, r];
for i = 2:rp_len-1
    p = optics.intersect(p, r, crystal.vtx(crystal.face{fid(i)}, :));
    r = optics.reflect(r, crystal.face_norm(fid(i), :));
    raypath(i, :) = [p, r];
end

% Last refraction
p = optics.intersect(p, r, crystal.vtx(crystal.face{fid(end)}, :));
r = optics.refract(r, crystal.face_norm(fid(end), :), crystal.n, 1);
raypath(end, :) = [p, r];
end
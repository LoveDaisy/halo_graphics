clear all; close all; clc;

% Style for crystals
crystal_style = {'FaceColor', 'w', 'FaceAlpha', 0.6, 'LineWidth', 2, 'EdgeColor', 'k'};
expand_crystal_style = {'FaceColor', 'w', 'FaceAlpha', 0.6, 'LineStyle', ':', ...
    'LineWidth', 1, 'EdgeColor', 'k'};
hit_crystal_style = {'FaceColor', 'none', 'LineWidth', 1, 'LineStyle', ':', 'EdgeColor', [1, 1, 1] * 0.7};

% Style for faces
mirror_face_style = {'FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none'};
hit_face_style = {'FaceColor', [255, 252, 180]/255, 'FaceAlpha', 0.75, 'LineStyle', '-', ...
    'LineWidth', 1.2, 'EdgeColor', 'k'};

% Style for rays
arrow_scale = 0.2;
point_scale = 0.02;
ray_color = [252, 93, 83]/255;
expand_ray_color = 'b';
ray_style = {'LineWidth', 2, 'Color', ray_color, 'ArrowScale', arrow_scale};
expand_ray_style = {'LineWidth', 1.3, 'Color', expand_ray_color, 'ArrowScale', arrow_scale};
ray_pts_style = {'PointScale', point_scale, 'FaceColor', ray_color};
expand_ray_pts_style = {'PointScale', point_scale, 'FaceColor', expand_ray_color};

crystal_h = 2;
crystal = optics.make_prism_crystal(crystal_h);

raypath = [3, 1, 5, 7, 4];
p0 = [.3, .00, .20, .5] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([-0.85, 0.65, 1.6]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];
expand_raypath_pts = raypath_pts;

c0 = object.makePrismCrystal(crystal_h);
c0.setDrawArgs(crystal_style{:});

fig_all = object.ComplexObj(c0);
fig_mirror_face = object.ComplexObj;
fig_expand_hit_face = object.ComplexObj;

curr_face = c0.getPatch(raypath(1));
curr_face.setDrawArgs(hit_face_style{:});
fig_expand_hit_face.addObj(curr_face);

curr_c = c0;
for i = 2:length(raypath)-1
    curr_fid = raypath(i);
    curr_t = transform.MirrorReflection(curr_c.getFaceNormal(curr_fid), ...
        mean(curr_c.getFaceVertices(curr_fid)));
    curr_c.applyTransform(curr_t);
    curr_c.setDrawArgs(expand_crystal_style{:});
    fig_all.addObj(curr_c);
    
    curr_mirror_face = curr_c.getPatch(curr_fid);
    curr_mirror_face.setDrawArgs(mirror_face_style{:});
    fig_mirror_face.addObj(curr_mirror_face);
    
    curr_mirror_face.setDrawArgs(hit_face_style{:});
    fig_expand_hit_face.addObj(curr_mirror_face);
    curr_c.setDrawArgs(hit_crystal_style{:});
    fig_expand_hit_face.addObj(curr_c);
    
    expand_raypath_pts(i+1:end, :) = curr_t.transform(expand_raypath_pts(i+1:end, :));
end
curr_face = curr_c.getPatch(raypath(end));
curr_face.setDrawArgs(hit_face_style{:});
fig_expand_hit_face.addObj(curr_face);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.02, 'StartArrow', 0.5);
curr_line.setDrawArgs(ray_style{:});
fig_all.addObj(curr_line);

curr_line = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.02);
curr_line.setDrawArgs(expand_ray_style{:});
fig_all.addObj(curr_line);

ray_pts = object.Point(raypath_pts(2:end-1, :));
ray_pts.setDrawArgs(ray_pts_style{:});
fig_all.addObj(ray_pts);

ray_pts = object.Point(expand_raypath_pts(4:end-1, :));
ray_pts.setDrawArgs(expand_ray_pts_style{:});
fig_all.addObj(ray_pts);

curr_line = object.ArrowLine(expand_raypath_pts(2:end-1, :));
curr_line.setDrawArgs(ray_style{:});
fig_expand_hit_face.addObj(curr_line);
clear curr_* c0

% Make final transformation
final_t = transform.Rotation('from', [0, 0, -1], 'to', [1, 0, 0]);
fig_all.applyTransform(final_t);
fig_mirror_face.applyTransform(final_t);
fig_expand_hit_face.applyTransform(final_t);

%%
axes_args = {'Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.2] * 15, 'CameraTarget', [-1, 0.38, -0.65], ...
    'CameraViewAngle', 12, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]};

figure(1); clf;
set(gcf, 'Color', 'w');
fig_all.draw();
set(gca, axes_args{:});

figure(2); clf;
set(gcf, 'Color', 'w');
fig_mirror_face.draw();
set(gca, axes_args{:});

figure(3); clf;
set(gcf, 'Color', 'w');
fig_expand_hit_face.draw();
set(gca, axes_args{:});

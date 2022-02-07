clear all; close all; clc;

crystal_h = 2;
raypath = [3, 1, 5, 7, 4];
face_alpha = 0.6;
crystal_style = {'FaceColor', 'w', 'FaceAlpha', face_alpha, 'LineWidth', 2, 'EdgeColor', 'k'};
mirror_crystal_style = {'FaceColor', 'w', 'FaceAlpha', face_alpha, 'LineStyle', ':', ...
    'LineWidth', 1, 'EdgeColor', 'k'};
mirror_face_style = {'FaceColor', [1, 1, 1] * 0.1, 'EdgeColor', 'none'};
hit_face_style = {'FaceColor', 'y', 'FaceAlpha', face_alpha, 'LineStyle', ':', ...
    'LineWidth', 1, 'EdgeColor', 'k'};

arrow_scale = 0.2;
ray_style = {'LineWidth', 2, 'Color', 'r', 'ArrowScale', arrow_scale};
expand_ray_style = {'LineWidth', 1.3, 'Color', 'b', 'ArrowScale', arrow_scale};

crystal = optics.make_prism_crystal(crystal_h);

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

curr_face = object.Patch(crystal.vtx(crystal.face{raypath(1)}, :));

curr_c = c0;
for i = 2:length(raypath)-1
    curr_t = transform.MirrorReflection(curr_c.getFaceNormal(raypath(i)), ...
        mean(curr_c.getFaceVertices(raypath(i))));
    curr_c.applyTransform(curr_t);
    curr_c.setDrawArgs(mirror_crystal_style{:});
    fig_all.addObj(curr_c);
    
    curr_mirror_face = object.Patch(curr_c.getFaceVertices(raypath(i)));
    curr_mirror_face.setDrawArgs(mirror_face_style{:});
    fig_mirror_face.addObj(curr_mirror_face);
    
    expand_raypath_pts(i+1:end, :) = curr_t.transform(expand_raypath_pts(i+1:end, :));
end
clear c0 curr_c curr_t;

line1 = object.ArrowLine(raypath_pts, 'EndArrow', 1.02, 'StartArrow', 0.5);
line1.setDrawArgs(ray_style{:});
fig_all.addObj(line1);

line2 = object.ArrowLine(expand_raypath_pts(3:end, :), 'EndArrow', 1.02);
line2.setDrawArgs(expand_ray_style{:});
fig_all.addObj(line2);

final_t = transform.Rotation('from', [0, 0, -1], 'to', [1, 0, 0]);
fig_all.applyTransform(final_t);
fig_mirror_face.applyTransform(final_t);

%%
figure(1); clf;
set(gcf, 'Color', 'w');
hold on;
fig_all.draw();
set(gca, 'Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(40), sind(40), 0.25] * 15, 'CameraTarget', [-1, 0.38, -0.65], ...
    'CameraViewAngle', 12);
axis equal;
axis off;

figure(2); clf;
set(gcf, 'Color', 'w');
hold on;
fig_mirror_face.draw();
set(gca, 'Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(40), sind(40), 0.25] * 15, 'CameraTarget', [-1, 0.38, -0.65], ...
    'CameraViewAngle', 12);
axis equal;
axis off;

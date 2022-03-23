clear; close all; clc;

figure_size = [1920, 1080] * 0.4;
size_factor = 1.5;

% Style for crystals
crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0.8, 'LineStyle', '-', ...
    'LineWidth', 2 * size_factor, 'EdgeColor', [1, 1, 1] * 0.2, 'NumberColor', [1, 1, 1] * 0.7, 'NumberScale', 1);
expand_crystal_material = render.Material('FaceColor', 'w', 'FaceAlpha', 0., 'LineStyle', ':', ...
    'LineWidth', 1 * size_factor, 'EdgeColor', [1, 1, 1] * 0.5, ...
    'NumberColor', [1, 1, 1] * 0.82, 'NumberScale', 1);

% Style for faces
mirror_face_material = render.Material('FaceColor', [246, 224, 75]/255, ...
    'EdgeColor', 'none', 'FaceAlpha', 0.6);

% Style for rays
arrow_scale = 0.14;
point_scale = 0.014;
ray_color = [252, 93, 83]/255;
expand_ray_color = [51, 122, 202]/255;
ray_style = render.Material('LineWidth', 1.5 * size_factor, 'Color', ray_color, 'LineStyle', '-', ...
    'ArrowScale', arrow_scale, ...
    'PointScale', point_scale);
expand_ray_style = render.Material('LineWidth', 2 * size_factor, 'LineStyle', ':', 'Color', expand_ray_color, ...
    'ArrowScale', arrow_scale, 'PointScale', point_scale);

% Make crystal
crystal_h = 1;
crystal = optics.make_prism_crystal(crystal_h);

% Trace a ray
raypath = [3, 1, 5, 7, 4];
p0 = [.35, .15, .15, .35] * crystal.vtx(crystal.face{raypath(1)}, :);
r0 = optics.normalize_vector([-1.3, 0.85, 1.0]);
ray_trace_res = optics.trace_ray(p0, r0, crystal, raypath);
raypath_pts = [p0 - r0; ray_trace_res(:, 1:3); ray_trace_res(end, 1:3) + ray_trace_res(end, 4:6)];

%%
% Start compose figures
c0 = object.CrystalObj(crystal_h);
c0.setMaterial(crystal_material);

fig_all = object.ComplexObj(c0);

curr_line = object.ArrowLine(raypath_pts, 'EndArrow', 1.05, 'StartArrow', 0.5);
curr_line.setMaterial(ray_style);
fig_all.addObj(curr_line);

curr_mirror = c0.getPatch(raypath(1));
curr_mirror.setMaterial(mirror_face_material);
fig_all.addObj(curr_mirror);

c0.setMaterial(expand_crystal_material);
expand_raypath_pts = raypath_pts;
for i = 2:length(raypath)-1
    curr_mirror = c0.getPatch(raypath(i));
    curr_mirror.setMaterial(mirror_face_material);
    fig_all.addObj(curr_mirror);
    
    curr_vtx = c0.getFaceVertices(raypath(i));
    curr_normal = c0.getFaceNormal(raypath(i));
    curr_t = transform.MirrorReflection('normal', curr_normal, 'p0', mean(curr_vtx));
    c0.applyTransform(curr_t);
    fig_all.addObj(c0);
    
    expand_raypath_pts(i+2:end, :) = curr_t.transform(expand_raypath_pts(i+2:end, :));
end
expand_raypath_pts = expand_raypath_pts(3:end, :);
curr_mirror = c0.getPatch(raypath(i+1));
curr_mirror.setMaterial(mirror_face_material);
fig_all.addObj(curr_mirror);
    
curr_line = object.ArrowLine(expand_raypath_pts, 'EndArrow', 1.1);
curr_line.setMaterial(expand_ray_style);
fig_all.addObj(curr_line);

clear curr_*

%%
% Make final transformation
final_t = transform.Rotation('axis', [0, 0, 1], 'theta', 90).chain(...
    transform.Rotation('from', [0, 0, 1], 'to', [1, 0, 0]));
fig_all.dynamicTransform(final_t);

% Set some animation parameters
cam = render.Camera('Position', [0, 0, 1, 1], 'Projection', 'Perspective', ...
    'CameraPosition', [cosd(50), sind(50), 0.4] * 15, 'CameraTarget', [0, 0, 0], ...
    'CameraViewAngle', 11, 'Visible', 'off', 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatio', [3, 4, 4]);
cam.setOutputFmt('output/ch3_expand_rp31574_%03d.png');

canvas_fig = figure(1); clf;
set(canvas_fig, 'Color', 'w', 'Position', [0, 400, figure_size * size_factor]);

% Side view
cam.setCamPose([-165, 0.4, 15, 0, -0.7, 0.5]);
cam.render(fig_all);


